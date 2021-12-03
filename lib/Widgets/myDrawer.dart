import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Authentication/profile.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Address/addAddress.dart';
import 'package:e_shop/Orders/addCard.dart';
import 'package:e_shop/Store/Search.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Orders/myOrders.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent,
            ),
            accountName: Text(
              EcommerceApp.sharedPreferences.getString(
                            EcommerceApp.userName,
                          ) !=
                          null &&
                      EcommerceApp.sharedPreferences.getString(
                            EcommerceApp.userName,
                          ) !=
                          ""
                  ? EcommerceApp.sharedPreferences.getString(
                      EcommerceApp.userName,
                    )
                  : "No hay un nombre guardado",
            ),
            accountEmail: Text(
              EcommerceApp.sharedPreferences.getString(
                            EcommerceApp.userEmail,
                          ) !=
                          null &&
                      EcommerceApp.sharedPreferences.getString(
                            EcommerceApp.userEmail,
                          ) !=
                          ""
                  ? EcommerceApp.sharedPreferences.getString(
                      EcommerceApp.userEmail,
                    )
                  : "No hay un email guardado",
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.lightGreenAccent
                  : Colors.white,
              backgroundImage: _hasUserImageUrl()
                  ? NetworkImage(
                      EcommerceApp.sharedPreferences.getString(
                        EcommerceApp.userAvatarUrl,
                      ),
                    )
                  : null,
              child: _hasUserImageUrl()
                  ? null
                  : Text(
                      EcommerceApp.sharedPreferences.getString(
                                    EcommerceApp.userName,
                                  ) !=
                                  null &&
                              EcommerceApp.sharedPreferences.getString(
                                    EcommerceApp.userName,
                                  ) !=
                                  ""
                          ? EcommerceApp.sharedPreferences.getString(
                              EcommerceApp.userName,
                            )[0]
                          : "N",
                      style: TextStyle(fontSize: 40.0),
                    ),
            ),
          ),
          ListTile(
            trailing: Icon(
              Icons.home,
            ),
            title: Text(
              "Inicio",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => StoreHome(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.reorder,
            ),
            title: Text(
              "Mis órdenes",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => MyOrders(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.shopping_cart,
            ),
            title: Text(
              "Carrito de compras",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => CartPage(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.search,
            ),
            title: Text(
              "Buscar productos",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => SearchProduct(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.add_location,
            ),
            title: Text(
              "Agregar nueva dirección",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => AddAddress(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.credit_card,
            ),
            title: Text(
              "Agregar tarjeta",
            ),
            onTap: () async {
              Route route = MaterialPageRoute(
                builder: (context) => AddCard(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.person,
            ),
            title: Text(
              "Perfil",
            ),
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          ListTile(
            trailing: Icon(
              Icons.exit_to_app,
            ),
            title: Text(
              "Salir",
            ),
            onTap: () async {
              await EcommerceApp.auth.signOut();
              Route route = MaterialPageRoute(
                builder: (context) => AuthenticScreen(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
          /*Container(
            padding: EdgeInsets.only(
              top: 25.0,
              bottom: 10.0,
            ),
            decoration: new BoxDecoration(
              color: Colors.lightGreenAccent,
            ),
            child: Column(
              children: [
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      80.0,
                    ),
                  ),
                  elevation: 8.0,
                  child: Container(
                    height: 160.0,
                    width: 160.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: _hasUserImageUrl()
                          ? NetworkImage(
                              EcommerceApp.sharedPreferences.getString(
                                EcommerceApp.userAvatarUrl,
                              ),
                            )
                          : null,
                      child: _hasUserImageUrl()
                          ? null
                          : Icon(
                              Icons.person,
                              size: 160.0,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  EcommerceApp.sharedPreferences.getString(
                    EcommerceApp.userName,
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.0,
                    fontFamily: "Signatra",
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Container(
            padding: EdgeInsets.only(
              top: 10.0,
            ),
            decoration: new BoxDecoration(
              color: Colors.lightGreenAccent,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Inicio",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => StoreHome(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.reorder,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Mis órdenes",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => MyOrders(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Carrito de compras",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => CartPage(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Buscar productos",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => SearchProduct(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.add_location,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Agregar nueva dirección",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => AddAddress(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Agregar tarjeta",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    Route route = MaterialPageRoute(
                      builder: (context) => AddCard(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Perfil",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Route route = MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Salir",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    await EcommerceApp.auth.signOut();
                    Route route = MaterialPageRoute(
                      builder: (context) => AuthenticScreen(),
                    );
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(
                  height: 10.0,
                  color: Colors.white,
                  thickness: 6.0,
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  bool _hasUserImageUrl() {
    String evalString = EcommerceApp.sharedPreferences.getString(
      EcommerceApp.userAvatarUrl,
    );
    if (evalString == null) {
      return false;
    } else if (evalString == "") {
      return false;
    } else {
      return true;
    }
  }
}
