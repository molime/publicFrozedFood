import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _displayAdminHomeScreen();
  }

  Scaffold _displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            color: Colors.lightGreenAccent,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.border_color,
            color: Colors.white,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(
              builder: (context) => AdminShiftOrders(),
            );
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
            onPressed: () async {
              await EcommerceApp.auth.signOut();
              Route route = MaterialPageRoute(
                builder: (context) => SplashScreen(),
              );
              Navigator.pushReplacement(context, route);
            },
            child: Text(
              'Salir',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _getAdminHomeScreenBody(),
    );
  }

  Container _getAdminHomeScreenBody() {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shop_two,
              color: Colors.grey,
              size: 200.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    9.0,
                  ),
                ),
                child: Text(
                  "Agregar nuevos artículos",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
