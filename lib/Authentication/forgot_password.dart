import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Config/config.dart';
import '../DialogBox/errorDialog.dart';
import '../DialogBox/loadingDialog.dart';
import 'package:e_shop/Config/config.dart';
import 'package:email_validator/email_validator.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailTextEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(
              builder: (context) => AuthenticScreen(),
            );
            Navigator.pushReplacement(
              context,
              route,
            );
          },
        ),
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
      body: Container(
        decoration: new BoxDecoration(
          color: Colors.white10,
        ),
        child: SingleChildScrollView(
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
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _emailTextEditingController.text.isNotEmpty
                          ? _loginUser()
                          : showDialog(
                              context: context,
                              builder: (c) {
                                return ErrorAlertDialog(
                                  message: "Por favor llena todos los campos",
                                );
                              },
                            );
                    }
                  },
                  color: Colors.pink,
                  child: Text(
                    'Reestablecer contraseña',
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
              ],
            ),
          ),
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
      await EcommerceApp.auth.sendPasswordResetEmail(
        email: _emailTextEditingController.text.trim(),
      );
      Fluttertoast.showToast(
        msg: "'Se ha mandado un correo para reestablecer tu contraseña.",
      );
      Navigator.pop(context);
      Route route = MaterialPageRoute(
        builder: (context) => AuthenticScreen(),
      );
      Navigator.pushReplacement(
        context,
        route,
      );
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
}
