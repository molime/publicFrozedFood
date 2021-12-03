import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/forgot_password.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Config/config.dart';
import '../DialogBox/errorDialog.dart';
import '../DialogBox/loadingDialog.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

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
              height: 15.0,
            ),
            ElevatedButton(
              onPressed: () async {
                print("before testing firebase connection");
                QuerySnapshot query =
                    await EcommerceApp.firestore.collection("categories").get();
                print("after testing firebase connection");
                print({'query': query.docs[0].id});
              },
              child: Text(
                'Test firebase connection',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: SignInButton(
                Buttons.Google,
                onPressed: () async {
                  print("Signing in with Google");
                  showDialog(
                    context: context,
                    builder: (c) {
                      return LoadingAlertDialog();
                    },
                  );
                  print("About to try");
                  try {
                    print("before signinResult");
                    GoogleSignInAccount signInResult =
                        await googleSignInLocal.signIn();
                    print("after signinResult");

                    if (signInResult != null) {
                      print("signInResult != null");
                      bool resultRegister =
                          await _saveGoogleUserInfoToFirestore(signInResult);
                      print("after resultRegister");
                      if (resultRegister) {
                        print("resultRegister == true");
                        Navigator.pop(context);
                        Route route = MaterialPageRoute(
                          builder: (context) => StoreHome(),
                        );
                        Navigator.pushReplacement(context, route);
                      } else {
                        print("resultRegister == false");
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (c) {
                            return ErrorAlertDialog(
                              message:
                                  "Hubo un error en tu registro, lo sentimos. Inténtalo nuevamente",
                            );
                          },
                        );
                      }
                    } else {
                      print("signinResult == null");
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Hubo un error en tu registro, lo sentimos. Inténtalo nuevamente",
                          );
                        },
                      );
                    }
                  } catch (error) {
                    print("error signing in");
                    print({'error': error});
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (c) {
                        return ErrorAlertDialog(
                          message: error.toString(),
                        );
                      },
                    );
                    return;
                  }
                },
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

  Future<bool> _saveGoogleUserInfoToFirestore(
      GoogleSignInAccount googleSignInAccount) async {
    print("trying to get user from firebase");
    DocumentSnapshot findUser = await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .doc(googleSignInAccount.id)
        .get();
    print("after trying to get user from firebase");

    if (findUser.exists) {
      print("findUser.exists");
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userUID, googleSignInAccount.id);
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userEmail, googleSignInAccount.email);
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userName, googleSignInAccount.displayName);
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userAvatarUrl, "");
      await EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
      await EcommerceApp.sharedPreferences.setString(
        EcommerceApp.userStripeId,
        (findUser.data() as Map)[EcommerceApp.userStripeId] != null
            ? (findUser.data() as Map)[EcommerceApp.userStripeId]
            : "",
      );
      return true;
    } else {
      print("findUser does not exist");
      dynamic stripeCustomer =
          await _registerUserStripe(email: googleSignInAccount.email);
      String stripeId = stripeCustomer["id"];
      print("after creating stripe customer");

      if (stripeId != null) {
        print("stripeId != null");
        await EcommerceApp.firestore
            .collection(EcommerceApp.collectionUser)
            .doc(googleSignInAccount.id)
            .set({
          EcommerceApp.userUID: googleSignInAccount.id,
          EcommerceApp.userEmail: googleSignInAccount.email,
          EcommerceApp.userName: googleSignInAccount.displayName,
          EcommerceApp.userAvatarUrl: null,
          EcommerceApp.userCartList: ["garbageValue"],
          EcommerceApp.userStripeId: stripeId,
        });
        print("after creating the user in firebase");

        await EcommerceApp.sharedPreferences
            .setString(EcommerceApp.userUID, googleSignInAccount.id);
        print("after sh uid");
        await EcommerceApp.sharedPreferences
            .setString(EcommerceApp.userEmail, googleSignInAccount.email);
        print("after sh email");
        await EcommerceApp.sharedPreferences
            .setString(EcommerceApp.userName, googleSignInAccount.displayName);
        print("after sh name");
        await EcommerceApp.sharedPreferences
            .setString(EcommerceApp.userAvatarUrl, "");
        print("after sh avatar");
        await EcommerceApp.sharedPreferences
            .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
        print("after sh list");
        await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userStripeId,
          stripeId,
        );
        print("after setting the variables");
        return true;
      } else {
        print("stripeId == null");
        return false;
      }
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
        (documentSnapshot.data() as Map)[EcommerceApp.userName] != null
            ? (documentSnapshot.data() as Map)[EcommerceApp.userName]
            : "");
    await EcommerceApp.sharedPreferences.setString(
      EcommerceApp.userAvatarUrl,
      (documentSnapshot.data() as Map)[EcommerceApp.userAvatarUrl] != null
          ? (documentSnapshot.data() as Map)[EcommerceApp.userAvatarUrl]
          : "",
    );

    await EcommerceApp.sharedPreferences.setString(
      EcommerceApp.userStripeId,
      (documentSnapshot.data() as Map)[EcommerceApp.userStripeId] != null
          ? (documentSnapshot.data() as Map)[EcommerceApp.userStripeId]
          : "",
    );

    List<String> cartList =
        (documentSnapshot.data() as Map)[EcommerceApp.userCartList]
            .cast<String>();
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, cartList);
  }

  Future<dynamic> _registerUserStripe({String email}) async {
    String chargeUrl =
        "https://us-central1-restaurantes-223b1.cloudfunctions.net/stripeCreateCustomer";

    var body = json.encode({'email': email});
    http.Response response;

    try {
      response = await http.post(
        Uri.parse(chargeUrl),
        body: body,
        headers: {
          "content-type": 'text/plain',
        },
      );
    } catch (err) {
      print(err.toString());
    }

    dynamic responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      return null;
    }
  }
}
