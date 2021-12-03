import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/push_notification_provider.dart';
import 'package:e_shop/Counters/ItemQuantity.dart';
import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/authenication.dart';
import 'package:e_shop/Config/config.dart';
import 'Authentication/authenication.dart';
import 'Config/config.dart';
import 'Counters/cartitemcounter.dart';
import 'Counters/changeAddresss.dart';
import 'Counters/totalMoney.dart';
import 'Store/storehome.dart';
import 'Store/storehome.dart';
import 'package:e_shop/appConfig.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<Widget> mainBuild(AppConfig appConfig) async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await Firebase.initializeApp();
  EcommerceApp.auth = FirebaseAuth.instance;
  EcommerceApp.sharedPreferences = await SharedPreferences.getInstance();
  EcommerceApp.firestore = FirebaseFirestore.instance;
  return MyApp(appConfig: appConfig);
  //runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final AppConfig appConfig;

  MyApp({
    Key key,
    this.appConfig,
  }) : super(
          key: key,
        );
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _flavorBanner(Widget child) {
    return Banner(
      child: child,
      location: BannerLocation.topEnd,
      message: widget.appConfig.flavor,
      color: widget.appConfig.flavor == 'dev'
          ? Colors.red.withOpacity(0.6)
          : Colors.green.withOpacity(0.6),
      textStyle: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 14.0, letterSpacing: 1.0),
      //textDirection: TextDirection.ltr,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
        navigatorKey: navigatorKey,
        title: 'e-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
        ),
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          OrderDetails.id: (context) => OrderDetails(),
        },
        //initialRoute: SplashScreen.id,
        home: _flavorBanner(
          SplashScreen(),
        ),
        //home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  static const String id = "splash_screen";

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
    bool isGoogleSignIn = await googleSignInLocal.isSignedIn();
    Timer(Duration(seconds: 5), () async {
      if (EcommerceApp.auth.currentUser != null) {
        if (EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userStripeId) ==
                null ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userStripeId) ==
                "" ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) ==
                null ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userUID) ==
                "" ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userName) ==
                null ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userName) ==
                "" ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userEmail) ==
                null ||
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userEmail) ==
                "" ||
            EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userAvatarUrl) ==
                null) {
          DocumentSnapshot documentSnapshot = await EcommerceApp.firestore
              .collection(EcommerceApp.collectionUser)
              .doc(EcommerceApp.auth.currentUser.uid)
              .get();
          await EcommerceApp.sharedPreferences.setString(
            EcommerceApp.userStripeId,
            (documentSnapshot.data() as Map)[EcommerceApp.userStripeId] != null
                ? (documentSnapshot.data() as Map)[EcommerceApp.userStripeId]
                : "",
          );
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userUID, EcommerceApp.auth.currentUser.uid);
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userEmail, EcommerceApp.auth.currentUser.email);
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userName,
              (documentSnapshot.data() as Map)[EcommerceApp.userName] != null
                  ? (documentSnapshot.data() as Map)[EcommerceApp.userName]
                  : "");
          await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userAvatarUrl,
              (documentSnapshot.data() as Map)[EcommerceApp.userAvatarUrl] !=
                      null
                  ? (documentSnapshot.data() as Map)[EcommerceApp.userAvatarUrl]
                  : "");
        }
        Route route = MaterialPageRoute(
          builder: (_) => StoreHome(),
        );
        Navigator.pushReplacement(
          context,
          route,
        );
      } else if (isGoogleSignIn) {
        try {
          GoogleSignInAccount signInAccount =
              await googleSignInLocal.signInSilently(suppressErrors: false);
          if (EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userStripeId) ==
                  null ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userStripeId) ==
                  "" ||
              EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) ==
                  null ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userUID) ==
                  "" ||
              EcommerceApp.sharedPreferences.getString(EcommerceApp.userName) ==
                  null ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userName) ==
                  "" ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userEmail) ==
                  null ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userEmail) ==
                  "" ||
              EcommerceApp.sharedPreferences
                      .getString(EcommerceApp.userAvatarUrl) ==
                  null) {
            DocumentSnapshot documentSnapshot = await EcommerceApp.firestore
                .collection(EcommerceApp.collectionUser)
                .doc(signInAccount.id)
                .get();
            await EcommerceApp.sharedPreferences.setString(
              EcommerceApp.userStripeId,
              (documentSnapshot.data() as Map)[EcommerceApp.userStripeId] !=
                      null
                  ? (documentSnapshot.data() as Map)[EcommerceApp.userStripeId]
                  : "",
            );
            await EcommerceApp.sharedPreferences
                .setString(EcommerceApp.userUID, signInAccount.id);
            await EcommerceApp.sharedPreferences
                .setString(EcommerceApp.userEmail, signInAccount.email);
            await EcommerceApp.sharedPreferences.setString(
                EcommerceApp.userName,
                (documentSnapshot.data() as Map)[EcommerceApp.userName] != null
                    ? (documentSnapshot.data() as Map)[EcommerceApp.userName]
                    : "");
            await EcommerceApp.sharedPreferences.setString(
                EcommerceApp.userAvatarUrl,
                (documentSnapshot.data() as Map)[EcommerceApp.userAvatarUrl] !=
                        null
                    ? (documentSnapshot.data()
                        as Map)[EcommerceApp.userAvatarUrl]
                    : "");
          }
          Route route = MaterialPageRoute(
            builder: (_) => StoreHome(),
          );
          Navigator.pushReplacement(
            context,
            route,
          );
        } catch (error) {
          await googleSignInLocal.signOut();
          Route route = MaterialPageRoute(
            builder: (_) => AuthenticScreen(),
          );
          Navigator.pushReplacement(
            context,
            route,
          );
        }
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
