import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            color: Colors.lightGreenAccent,
          ),
        ),
        title: Text(
          "Tic Tac Food",
          style: TextStyle(
            fontSize: 55.0,
            color: Colors.white,
            fontFamily: "Signatra",
          ),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  TextEditingController _adminIdTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/admin.png",
                width: 240.0,
                height: 240.0,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Padding(
              padding: EdgeInsets.all(
                8.0,
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIdTextEditingController,
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
            SizedBox(
              height: 25.0,
            ),
            RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _adminIdTextEditingController.text.isNotEmpty &&
                          _passwordTextEditingController.text.isNotEmpty
                      ? _loginAdmin()
                      : showDialog(
                          context: context,
                          builder: (c) {
                            return ErrorAlertDialog(
                              message: "Por favor llena todos los campos",
                            );
                          });
                }
              },
              color: Colors.pink,
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
            FlatButton.icon(
              onPressed: () {
                Route route = MaterialPageRoute(
                  builder: (context) => AuthenticScreen(),
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
                "No soy un administrador",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginAdmin() async {
    /*QuerySnapshot querySnapshot =
        await EcommerceApp.firestore.collection('admins').get();

    querySnapshot.docs.forEach((doc) {});*/
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog();
      },
    );

    User firebaseUser;

    try {
      UserCredential userCredential =
          await EcommerceApp.auth.signInWithEmailAndPassword(
        email: _adminIdTextEditingController.text.trim(),
        password: _passwordTextEditingController.text.trim(),
      );
      firebaseUser = userCredential.user;
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
      return;
    }

    if (firebaseUser != null) {
      bool result = await _readData(firebaseUser);

      if (result) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(
          builder: (context) => UploadPage(),
        );
        Navigator.pushReplacement(context, route);
      } else {
        await EcommerceApp.auth.signOut();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(
                message: "No tienes permitido entrar aquí.",
              );
            });
      }
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: "Hubo un error, inténtalo nuevamente.",
            );
          });
    }
  }

  Future<bool> _readData(User firebaseUser) async {
    DocumentSnapshot documentSnapshot = await EcommerceApp.firestore
        .collection(EcommerceApp.collectionAdmin)
        .doc(firebaseUser.uid)
        .get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
    /*await EcommerceApp.sharedPreferences
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

    List<String> cartList =
        documentSnapshot.data()[EcommerceApp.userCartList].cast<String>();
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, cartList);*/
  }
}
