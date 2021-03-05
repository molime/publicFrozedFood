import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Counters/ItemQuantity.dart';
import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/authenication.dart';
import 'package:e_shop/Config/config.dart';
import 'Authentication/authenication.dart';
import 'Config/config.dart';
import 'Config/config.dart';
import 'Config/config.dart';
import 'Config/config.dart';
import 'Counters/cartitemcounter.dart';
import 'Counters/changeAddresss.dart';
import 'Counters/totalMoney.dart';
import 'Store/storehome.dart';
import 'Store/storehome.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await Firebase.initializeApp();
  EcommerceApp.auth = FirebaseAuth.instance;
  EcommerceApp.sharedPreferences = await SharedPreferences.getInstance();
  EcommerceApp.firestore = FirebaseFirestore.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartItemCounter(),
        ),
        ChangeNotifierProvider(
          create: (context) => ItemQuantity(),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressChanger(),
        ),
        ChangeNotifierProvider(
          create: (context) => TotalAmount(),
        ),
        ChangeNotifierProvider<ShoppingCart>(
          create: (context) => ShoppingCart(),
        ),
        ChangeNotifierProvider<CreditCardData>(
          create: (context) => CreditCardData(),
        ),
        ChangeNotifierProvider<CategoryData>(
          create: (context) => CategoryData(),
        ),
      ],
      child: MaterialApp(
        title: 'e-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    displaySplash();
  }

  Future<void> displaySplash() async {
    Timer(Duration(seconds: 5), () async {
      if (EcommerceApp.auth.currentUser != null) {
        if (EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userStripeId) ==
                null ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) ==
                null ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userName) ==
                null ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userEmail) ==
                null ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userAvatarUrl) ==
                null) {
          DocumentSnapshot documentSnapshot = await EcommerceApp.firestore
              .collection(EcommerceApp.collectionUser)
              .doc(EcommerceApp.auth.currentUser.uid)
              .get();
          await EcommerceApp.sharedPreferences.setString(
            EcommerceApp.userStripeId,
            documentSnapshot.data()[EcommerceApp.userStripeId] != null
                ? documentSnapshot.data()[EcommerceApp.userStripeId]
                : null,
          );
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userUID, EcommerceApp.auth.currentUser.uid);
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userEmail, EcommerceApp.auth.currentUser.email);
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userName,
              documentSnapshot.data()[EcommerceApp.userName] != null
                  ? documentSnapshot.data()[EcommerceApp.userName]
                  : null);
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userAvatarUrl,
              documentSnapshot.data()[EcommerceApp.userAvatarUrl] != null
                  ? documentSnapshot.data()[EcommerceApp.userAvatarUrl]
                  : null);
        }
        Route route = MaterialPageRoute(
          builder: (_) => StoreHome(),
        );
        Navigator.pushReplacement(
          context,
          route,
        );
      } else {
        Route route = MaterialPageRoute(
          builder: (_) => AuthenticScreen(),
        );
        Navigator.pushReplacement(
          context,
          route,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.lightGreenAccent,
          /*gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.lightGreenAccent,
            ],
            begin: const FractionalOffset(
              0.0,
              0.0,
            ),
            end: const FractionalOffset(
              1.0,
              0.0,
            ),
            stops: [
              0.0,
              1.0,
            ],
            tileMode: TileMode.clamp,
          ),*/
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/welcome.png',
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Bienvenido a Tic Tac Food. Agradecemos tu confianza.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
