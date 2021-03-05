import 'package:e_shop/Config/config.dart';
import 'package:flutter/material.dart';

Future showChangeNameDialog(
    {BuildContext context, TextEditingController nameController}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        //String name;
        return AlertDialog(
          title: Text(
            'Cambiar nombre',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextFormField(
                  onChanged: (newName) {
                    setState(() {});
                  },
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'NOMBRE',
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                'cerrar',
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              //color: Colors.red,
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed:
                  nameController.text == null || nameController.text == ''
                      ? () {}
                      : () => Navigator.pop(
                            context,
                            nameController.text,
                          ),
              style: TextButton.styleFrom(
                backgroundColor:
                    nameController.text == null || nameController.text == ''
                        ? Colors.grey
                        : Colors.green,
              ),
              /*color: nameController.text == null || nameController.text == ''
                  ? Colors.grey
                  : Colors.green,*/
              child: Text(
                'Actualizar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      });
    },
  ).then((value) async {
    if (value != 'cerrar') {
      await EcommerceApp.firestore
          .collection(
            EcommerceApp.collectionUser,
          )
          .doc(
            EcommerceApp.sharedPreferences.getString(
              EcommerceApp.userUID,
            ),
          )
          .update({
        EcommerceApp.userName: value,
      });
      await EcommerceApp.sharedPreferences.setString(
        EcommerceApp.userName,
        value,
      );
    }
  });
}
