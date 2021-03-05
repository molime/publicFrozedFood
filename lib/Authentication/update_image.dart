import 'dart:io';
import 'dart:math';

import 'package:e_shop/Config/config.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

Scaffold updateProfileImage({
  @required File imageFile,
  @required Function goBack,
  @required double screenWidth,
  @required BuildContext context,
  @required bool inAsyncCall,
  @required Function changeAsyncCall,
  @required GlobalKey<ScaffoldState> scaffoldKey,
}) {
  return Scaffold(
    key: scaffoldKey,
    appBar: AppBar(
      backgroundColor: Colors.lightGreenAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: goBack,
      ),
    ),
    body: ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      child: ListView(
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
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: screenWidth * 0.15,
                    backgroundImage: FileImage(
                      imageFile,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    changeAsyncCall(
                      true,
                    );
                    bool result = await uploadPhotoStorage(
                      context: context,
                      imageFile: imageFile,
                    );
                    changeAsyncCall(
                      false,
                    );
                    if (result) {
                      SnackBar snackbar = SnackBar(
                        content: Text(
                            'Tu foto de perfil se ha actualizado con éxito.'),
                        duration: Duration(
                          seconds: 5,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      goBack();
                    } else {
                      SnackBar snackbar = SnackBar(
                        content: Text(
                            'Hubo un error actualizando tu foto de perfil, lo sentimos.'),
                        duration: Duration(
                          seconds: 5,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      goBack();
                    }
                  },
                  child: Text(
                    'ACTUALIZAR FOTO',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent,
                    onPrimary: Colors.white,
                  ),
                  //color: Colors.white,
                  /*shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                    side: BorderSide(
                      color: Color(0xFFe2b13c),
                    ),
                  ),*/
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<bool> uploadPhotoStorage({
  BuildContext context,
  File imageFile,
}) async {
  String downloadPhotoUrl;

  if (imageFile != null) {
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Random random = new Random();
    int randomNumber = random.nextInt(1001);
    imageFileName = '$imageFileName-$randomNumber';

    firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance
            .ref()
            .child(
              EcommerceApp.sharedPreferences.getString(
                EcommerceApp.userUID,
              ),
            )
            .child(imageFileName);
    firebase_storage.UploadTask storageUploadTask =
        storageReference.putFile(imageFile);

    await storageUploadTask.whenComplete(() async {
      try {
        downloadPhotoUrl = await storageReference.getDownloadURL();
      } catch (err) {
        print(err);
      }
    });

    if (downloadPhotoUrl != null) {
      await EcommerceApp.firestore
          .collection(EcommerceApp.collectionUser)
          .doc(
            EcommerceApp.sharedPreferences.getString(
              EcommerceApp.userUID,
            ),
          )
          .update({
        EcommerceApp.userAvatarUrl: downloadPhotoUrl,
      });
      await EcommerceApp.sharedPreferences.setString(
        EcommerceApp.userAvatarUrl,
        downloadPhotoUrl,
      );
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
