import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  final Widget leadingWidget;
  final bool showCart;
  MyAppBar({
    this.bottom,
    this.leadingWidget,
    this.showCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leadingWidget == null ? null : leadingWidget,
      iconTheme: IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: new BoxDecoration(
          color: Colors.lightGreenAccent,
        ),
      ),
      centerTitle: true,
      title: Text(
        "Tic Tac Food",
        style: TextStyle(
          fontSize: 55.0,
          color: Colors.white,
          fontFamily: "Signatra",
        ),
      ),
      bottom: bottom,
      actions: showCart
          ? [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      Route route = MaterialPageRoute(
                        builder: (context) => CartPage(),
                      );
                      Navigator.pushReplacement(context, route);
                    },
                  ),
                  Positioned(
                    child: Stack(
                      children: [
                        Icon(
                          Icons.brightness_1,
                          size: 20.0,
                          color: Colors.pink,
                        ),
                        Positioned(
                          top: 3.0,
                          bottom: 4.0,
                          left: 4.0,
                          child: Text(
                            Provider.of<ShoppingCart>(context)
                                .shoppingCartCount()
                                .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : [],
    );
  }

  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
