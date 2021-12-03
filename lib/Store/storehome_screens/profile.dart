import 'dart:io';

import 'package:e_shop/Authentication/update_image.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/changeNameDialog.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/profileCard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreenSubScreen extends StatefulWidget {
  @override
  _ProfileScreenSubScreenState createState() => _ProfileScreenSubScreenState();
}

class _ProfileScreenSubScreenState extends State<ProfileScreenSubScreen> {
  bool changePassword = false;
  bool changeName = false;
  String password;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldPhotoKey = GlobalKey<ScaffoldState>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  File _imageFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _imageFile != null
        ? updateProfileImage(
            imageFile: _imageFile,
            goBack: () {
              setState(() {
                _imageFile = null;
              });
            },
            screenWidth: MediaQuery.of(context).size.width,
            context: context,
            inAsyncCall: isLoading,
            changeAsyncCall: (bool value) {
              setState(() {
                isLoading = value;
              });
            },
            scaffoldKey: _scaffoldPhotoKey,
          )
        : SafeArea(
            child: Scaffold(
              key: _scaffoldKey,
              appBar: MyAppBar(
                showCart: true,
              ),
              drawer: MyDrawer(),
              body: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: InkWell(
                            onTap: selectImage,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: MediaQuery.of(context).size.width * 0.15,
                              backgroundImage: EcommerceApp.sharedPreferences
                                              .getString(
                                                  EcommerceApp.userAvatarUrl) ==
                                          null ||
                                      EcommerceApp.sharedPreferences.getString(
                                              EcommerceApp.userAvatarUrl) ==
                                          ""
                                  ? null
                                  : NetworkImage(
                                      EcommerceApp.sharedPreferences.getString(
                                          EcommerceApp.userAvatarUrl),
                                    ),
                              child: EcommerceApp.sharedPreferences.getString(
                                              EcommerceApp.userAvatarUrl) ==
                                          null ||
                                      EcommerceApp.sharedPreferences.getString(
                                              EcommerceApp.userAvatarUrl) ==
                                          ""
                                  ? Icon(
                                      Icons.person,
                                      size: MediaQuery.of(context).size.width *
                                          0.15,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (!changePassword && !changeName) ...[
                          Padding(
                            padding: EdgeInsets.all(
                              16.0,
                            ),
                            child: Column(
                              children: [
                                ProfileCard(
                                  text:
                                      EcommerceApp.sharedPreferences.getString(
                                    EcommerceApp.userEmail,
                                  ),
                                  icon: Icons.alternate_email,
                                ),
                                ProfileCard(
                                  text:
                                      EcommerceApp.sharedPreferences.getString(
                                                    EcommerceApp.userName,
                                                  ) !=
                                                  null &&
                                              EcommerceApp.sharedPreferences
                                                      .getString(
                                                    EcommerceApp.userName,
                                                  ) !=
                                                  ""
                                          ? EcommerceApp.sharedPreferences
                                              .getString(
                                              EcommerceApp.userName,
                                            )
                                          : 'Nombre vacío',
                                  icon: Icons.person,
                                  onPressed: () async {
                                    await showChangeNameDialog(
                                        context: context,
                                        nameController: TextEditingController(
                                          text: EcommerceApp.sharedPreferences
                                                          .getString(
                                                        EcommerceApp.userName,
                                                      ) !=
                                                      null &&
                                                  EcommerceApp.sharedPreferences
                                                          .getString(
                                                        EcommerceApp.userName,
                                                      ) !=
                                                      ""
                                              ? EcommerceApp.sharedPreferences
                                                  .getString(
                                                  EcommerceApp.userName,
                                                )
                                              : '',
                                        ));
                                  },
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                changePassword = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              /*shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20.0,
                                ),
                                side: BorderSide(
                                  color: Color(0xFFe2b13c),
                                ),
                              ),*/
                              primary: Colors.pink,
                              onPrimary: Colors.white,
                            ),
                            /*shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ),
                              side: BorderSide(
                                color: Color(0xFFe2b13c),
                              ),
                            ),
                            color: Colors.white,*/
                            child: Text(
                              'CAMBIA DE CONTRASEÑA',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (changePassword) ...[
                          Form(
                            key: _formKey,
                            child: Flex(
                              direction: Axis.vertical,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: TextFormField(
                                    obscureText: true,
                                    controller: currentPasswordController,
                                    validator: (val) => val.length < 6
                                        ? 'La contraseña debe tener al menos 6 caracteres'
                                        : null,
                                    decoration: InputDecoration(
                                      labelText: 'CONTRASEÑA ACTUAL',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.lightGreenAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: TextFormField(
                                        onChanged: (newPassword) {
                                          setState(() {
                                            password = newPassword;
                                          });
                                        },
                                        obscureText: true,
                                        controller: passwordController,
                                        validator: (val) => val.length < 6
                                            ? 'La contraseña debe tener al menos 6 caracteres'
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: 'NUEVA CONTRASEÑA',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.lightGreenAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    passwordController.text ==
                                                passwordConfirmController
                                                    .text &&
                                            passwordController.text.length >
                                                0 &&
                                            passwordConfirmController
                                                    .text.length >
                                                0
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.lightGreenAccent,
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: passwordConfirmController,
                                        validator: (val) => val !=
                                                passwordController.text
                                            ? 'Las contraseñas deben ser iguales'
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: 'CONFIRMA CONTRASEÑA',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.lightGreenAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    passwordController.text ==
                                                passwordConfirmController
                                                    .text &&
                                            passwordController.text.length >
                                                0 &&
                                            passwordConfirmController
                                                    .text.length >
                                                0
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.lightGreenAccent,
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          try {
                                            final userSignIn =
                                                await EcommerceApp.auth
                                                    .signInWithEmailAndPassword(
                                              email: EcommerceApp
                                                  .sharedPreferences
                                                  .getString(
                                                EcommerceApp.userEmail,
                                              ),
                                              password:
                                                  currentPasswordController
                                                      .text,
                                            );
                                            try {
                                              await userSignIn.user
                                                  .updatePassword(password);
                                              SnackBar snackbar = SnackBar(
                                                  content: Text(
                                                      "¡Contraseña cambiada con éxito!"));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                              setState(() {
                                                _formKey.currentState.reset();
                                                passwordController.clear();
                                                passwordConfirmController
                                                    .clear();
                                                password = null;
                                                currentPasswordController
                                                    .clear();
                                                changePassword = false;
                                              });
                                            } catch (errorChange) {
                                              SnackBar snackbar = SnackBar(
                                                  content: Text(
                                                      "Hubo un error cambiando la contraseña."));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                              setState(() {
                                                _formKey.currentState.reset();
                                                passwordController.clear();
                                                passwordConfirmController
                                                    .clear();
                                                password = null;
                                                currentPasswordController
                                                    .clear();
                                                changePassword = false;
                                              });
                                            }
                                          } catch (errorSignIn) {
                                            SnackBar snackbar = SnackBar(
                                              content: Text(
                                                'Hubo un error con tu contraseña actual',
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackbar);
                                            setState(() {
                                              _formKey.currentState.reset();
                                              passwordController.clear();
                                              passwordConfirmController.clear();
                                              password = null;
                                              currentPasswordController.clear();
                                              changePassword = false;
                                            });
                                          }
                                        }
                                      },
                                      /*shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        side: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),*/
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.pink,
                                        onPrimary: Colors.white,
                                      ),
                                      //color: Colors.white,
                                      child: Text(
                                        'CONFIRMAR',
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          changePassword = false;
                                        });
                                      },
                                      /* shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        side: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),*/
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.pink,
                                        onPrimary: Colors.white,
                                      ),
                                      //color: Colors.white,
                                      child: Text(
                                        'CANCELAR',
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> selectImage() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
}
