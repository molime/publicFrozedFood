import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Authentication/forgot_password.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../Config/config.dart';
import '../DialogBox/errorDialog.dart';
import '../DialogBox/loadingDialog.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';

import '../Store/storehome.dart';
import '../Widgets/customTextField.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();
  TextEditingController _cPasswordTextEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 10.0,
            ),
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenWidth * 0.15,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile == null
                    ? null
                    : FileImage(
                        _imageFile,
                      ),
                child: _imageFile == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: _screenWidth * 0.15,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameTextEditingController,
                    data: Icons.person,
                    hintText: "Nombre completo",
                    isObsecure: false,
                    validator: (String val) => val.length < 1
                        ? 'El nombre no puede estar vacío'
                        : null,
                  ),
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
                  CustomTextField(
                    controller: _cPasswordTextEditingController,
                    data: Icons.security,
                    hintText: "Confirmar contraseña",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(),
                    ),
                  );
                },
                padding: EdgeInsets.only(right: 0.0),
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
            RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  uploadAndSaveImage();
                }
              },
              color: Colors.pink,
              child: Text(
                'Registrarse',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Center(
              child: SignInButton(
                Buttons.Google,
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return LoadingAlertDialog();
                    },
                  );
                  try {
                    GoogleSignInAccount signInResult =
                        await googleSignInLocal.signIn();

                    if (signInResult != null) {
                      bool resultRegister =
                          await _saveGoogleUserInfoToFirestore(signInResult);
                      if (resultRegister) {
                        Navigator.pop(context);
                        Route route = MaterialPageRoute(
                          builder: (context) => StoreHome(),
                        );
                        Navigator.pushReplacement(context, route);
                      } else {
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
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageFile = File(
        pickedFile.path,
      );
    });
  }

  Future<void> uploadAndSaveImage() async {
    _passwordTextEditingController.text == _cPasswordTextEditingController.text
        ? _emailTextEditingController.text.isNotEmpty &&
                _passwordTextEditingController.text.isNotEmpty &&
                _cPasswordTextEditingController.text.isNotEmpty &&
                _nameTextEditingController.text.isNotEmpty
            ? uploadToStorage()
            : displayDialog(
                "Por favor llena todos los campos.",
              )
        : displayDialog(
            "Las contraseñas no coinciden.",
          );
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message: msg,
          );
        });
  }

  Future<void> uploadToStorage() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog();
      },
    );

    if (_imageFile != null) {
      String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Random random = new Random();
      int randomNumber = random.nextInt(1001);
      imageFileName = '$imageFileName-$randomNumber';

      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(imageFileName);
      firebase_storage.UploadTask storageUploadTask =
          storageReference.putFile(_imageFile);
      await storageUploadTask.whenComplete(() async {
        try {
          userImageUrl = await storageReference.getDownloadURL();
        } catch (err) {
          print(err);
        }
      });
    }

    _registerUser();
  }

  Future<void> _registerUser() async {
    User firebaseUser;

    try {
      UserCredential userCredential =
          await EcommerceApp.auth.createUserWithEmailAndPassword(
        email: _emailTextEditingController.text.trim(),
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
      bool resultRegister = await _saveUserInfoToFirestore(firebaseUser);
      if (resultRegister) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(
          builder: (context) => StoreHome(),
        );
        Navigator.pushReplacement(context, route);
      } else {
        await firebaseUser.delete();
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
  }

  Future<bool> _saveUserInfoToFirestore(User firebaseUser) async {
    dynamic stripeCustomer =
        await _registerUserStripe(email: firebaseUser.email);
    String stripeId = stripeCustomer["id"];

    if (stripeId != null) {
      await EcommerceApp.firestore
          .collection(EcommerceApp.collectionUser)
          .doc(firebaseUser.uid)
          .set({
        EcommerceApp.userUID: firebaseUser.uid,
        EcommerceApp.userEmail: firebaseUser.email,
        EcommerceApp.userName: _nameTextEditingController.text.trim(),
        EcommerceApp.userAvatarUrl: userImageUrl,
        EcommerceApp.userCartList: ["garbageValue"],
        EcommerceApp.userStripeId: stripeId,
      });

      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userUID, firebaseUser.uid);
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userEmail, firebaseUser.email);
      await EcommerceApp.sharedPreferences.setString(
          EcommerceApp.userName, _nameTextEditingController.text.trim());
      await EcommerceApp.sharedPreferences
          .setString(EcommerceApp.userAvatarUrl, userImageUrl);
      await EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
      await EcommerceApp.sharedPreferences.setString(
        EcommerceApp.userStripeId,
        stripeId,
      );
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _saveGoogleUserInfoToFirestore(
      GoogleSignInAccount googleSignInAccount) async {
    DocumentSnapshot findUser = await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .doc(googleSignInAccount.id)
        .get();

    if (findUser.exists) {
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
      dynamic stripeCustomer =
          await _registerUserStripe(email: googleSignInAccount.email);
      String stripeId = stripeCustomer["id"];

      if (stripeId != null) {
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
          stripeId,
        );
        return true;
      } else {
        return false;
      }
    }
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
