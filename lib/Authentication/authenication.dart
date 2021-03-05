import 'package:flutter/material.dart';
import 'package:e_shop/Config/config.dart';

import 'login.dart';
import 'register.dart';

class AuthenticScreen extends StatefulWidget {
  @override
  _AuthenticScreenState createState() => _AuthenticScreenState();
}

class _AuthenticScreenState extends State<AuthenticScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                text: "Entrar",
              ),
              Tab(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                text: "Registro",
              ),
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 5.0,
          ),
        ),
        body: Container(
          decoration: new BoxDecoration(
            color: Colors.white10,
            /*gradient: new LinearGradient(
              colors: [
                Colors.white,
                Colors.lightGreenAccent,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),*/
          ),
          child: TabBarView(
            children: [
              Login(),
              Register(),
            ],
          ),
        ),
      ),
    );
  }
}
