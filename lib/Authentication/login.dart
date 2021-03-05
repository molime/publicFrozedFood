import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/forgot_password.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Config/config.dart';
import '../DialogBox/errorDialog.dart';
import '../DialogBox/loadingDialog.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';
import 'package:email_validator/email_validator.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/login.png",
                width: 240.0,
                height: 240.0,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            /*Padding(
              padding: EdgeInsets.all(
                8.0,
              ),
              child: Text(
                'Entra a tu cuenta',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),*/
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Correo electrónico",
                    isObsecure: false,
                    inputType: TextInputType.emailAddress,
                    validator: (String val) =>
                        !EmailValidator.validate(val, true)
                            ? 'Email no válido'
                            : null,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.security,
                    hintText: "Contraseña",
                    isObsecure: true,
                    validator: (String val) => val.length < 6
                        ? 'La contraseña debe tener 6 caracteres mínimo'
                        : null,
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.only(right: 0.0),
                ),
                //padding: EdgeInsets.only(right: 0.0),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _emailTextEditingController.text.isNotEmpty &&
                          _passwordTextEditingController.text.isNotEmpty
                      ? _loginUser()
                      : showDialog(
                          context: context,
                          builder: (c) {
                            return ErrorAlertDialog(
                              message: "Por favor llena todos los campos",
                            );
                          });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
                onPrimary: Colors.white,
              ),
              //color: Colors.pink,
              child: Text(
                'Entrar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 10.0,
            ),
            /*FlatButton.icon(
              onPressed: () {
                Route route = MaterialPageRoute(
                  builder: (context) => AdminSignInPage(),
                );
                Navigator.push(
                  context,
                  route,
                );
              },
              icon: Icon(
                Icons.nature_people,
                color: Colors.pink,
              ),
              label: Text(
                "Soy un administrador",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog();
      },
    );

    try {
      User firebaseUser;
      UserCredential userCredential =
          await EcommerceApp.auth.signInWithEmailAndPassword(
        email: _emailTextEditingController.text.trim(),
        password: _passwordTextEditingController.text.trim(),
      );
      firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await _readData(firebaseUser);
        Navigator.pop(context);
        Route route = MaterialPageRoute(
          builder: (context) => StoreHome(),
        );
        Navigator.pushReplacement(context, route);
      }
    } catch (err) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message: err.toString(),
          );
        },
      );
    }
  }

  Future<void> _readData(User firebaseUser) async {
    DocumentSnapshot documentSnapshot = await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .doc(firebaseUser.uid)
        .get();
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userUID, firebaseUser.uid);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userEmail, firebaseUser.email);
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

    await EcommerceApp.sharedPreferences.setString(
      EcommerceApp.userStripeId,
      documentSnapshot.data()[EcommerceApp.userStripeId] != null
          ? documentSnapshot.data()[EcommerceApp.userStripeId]
          : null,
    );

    List<String> cartList =
        documentSnapshot.data()[EcommerceApp.userCartList].cast<String>();
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, cartList);
  }
}
