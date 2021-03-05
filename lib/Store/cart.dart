import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/constants.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/Store/category_products.dart';
import 'package:e_shop/Store/daily_menus.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Counters/totalMoney.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class CartPage extends StatefulWidget {
  final bool comesFromStore;

  CartPage({
    Key key,
    this.comesFromStore = true,
  }) : super(
          key: key,
        );

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalAmount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: MyAppBar(
          showCart: false,
          leadingWidget: IconButton(
            icon: Icon(
              Icons.chevron_left,
            ),
            onPressed: () {
              if (widget.comesFromStore) {
                Route route = MaterialPageRoute(
                  builder: (context) => StoreHome(),
                );
                Navigator.pushReplacement(
                  context,
                  route,
                );
              } else {
                Route route = MaterialPageRoute(
                  builder: (context) => CategoryProducts(),
                );
                Navigator.pushReplacement(
                  context,
                  route,
                );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (Provider.of<ShoppingCart>(context, listen: false)
                        .itemsCart
                        .toList()
                        .length ==
                    0 &&
                Provider.of<ShoppingCart>(context, listen: false)
                        .dailyItems
                        .toList()
                        .length ==
                    0) {
              Fluttertoast.showToast(msg: "El carrito está vacío");
            } else {
              Route route = MaterialPageRoute(
                builder: (context) => AddressScreen(
                  totalAmount: Provider.of<ShoppingCart>(context, listen: false)
                      .getTotalAmount(),
                ),
              );
              Navigator.pushReplacement(context, route);
            }
          },
          label: Text(
            "Continuar",
          ),
          backgroundColor: Colors.pinkAccent,
          icon: Icon(
            Icons.navigate_next,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(
                  8.0,
                ),
                child: Center(
                  child:
                      Provider.of<ShoppingCart>(context).shoppingCartCount() ==
                              0
                          ? Container()
                          : Text(
                              "Total por pagar: \$ ${Provider.of<ShoppingCart>(context).getTotalAmount()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                ),
              ),
            ),
            if (Provider.of<ShoppingCart>(context).shoppingCartCount() ==
                0) ...[
              beginBuildingCart(),
            ],
            if (Provider.of<ShoppingCart>(context).shoppingCartCount() > 0) ...[
              if (Provider.of<ShoppingCart>(context).itemsCart.length > 0) ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return sourceInfoCart(
                        model:
                            Provider.of<ShoppingCart>(context).itemsCart[index],
                        context: context,
                        removeCartFunction: () {
                          Provider.of<ShoppingCart>(context, listen: false)
                              .removeFromCart(
                            itemModelRemove: Provider.of<ShoppingCart>(context)
                                .itemsCart[index],
                          );
                        },
                      );
                    },
                    childCount:
                        Provider.of<ShoppingCart>(context).itemsCart.length,
                  ),
                ),
              ],
              if (Provider.of<ShoppingCart>(context).dailyItems.length > 0) ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return sourceInfoDaily(
                        model: Provider.of<ShoppingCart>(context)
                            .dailyItems[index],
                        context: context,
                        removeCartFunction: () {
                          Provider.of<ShoppingCart>(context, listen: false)
                              .removeFromDaily(
                            itemModelRemove: Provider.of<ShoppingCart>(context)
                                .dailyItems[index],
                          );
                        },
                      );
                    },
                    childCount:
                        Provider.of<ShoppingCart>(context).dailyItems.length,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Padding sourceInfoCart({
    ItemModel model,
    BuildContext context,
    Color background,
    removeCartFunction,
  }) {
    return Padding(
      padding: EdgeInsets.all(
        6.0,
      ),
      child: Container(
        height: 190,
        width: width,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: model.thumbnailUrl,
              width: 140.0,
              height: 140.0,
              placeholder: (context, url) => circularProgress(),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
              ),
            ),
            /*Image.network(
            model.thumbnailUrl,
            width: 140.0,
            height: 140.0,
          ),*/
            SizedBox(
              width: 4.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            '\$${discountedPrice(
                              price: model.price,
                              discount: model.discount,
                            )}',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.shortInfo,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.options != null &&
                              model.options.length > 0) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: displayOptions(
                                model,
                              ),
                            ),
                          ],
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Total: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "\$ ",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "${Provider.of<ShoppingCart>(context).getItemTotal(
                                    itemModel: model,
                                  )}",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(),
                  ),
                  //TODO: implement the cart item remove feature
                  Align(
                    alignment: Alignment.centerRight,
                    child: !Provider.of<ShoppingCart>(context)
                            .isInCart(itemModelCheck: model)
                        ? IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              addItemModelToCart(
                                context: context,
                                itemModel: model,
                              );
                            },
                          )
                        : modifyQuantity(
                            context: context,
                            itemModelModify:
                                Provider.of<ShoppingCart>(context).getItemModel(
                              itemModelCheck: model,
                            ),
                          ),
                  ),
                  Divider(
                    height: 5.0,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding sourceInfoDaily({
    ItemModel model,
    BuildContext context,
    Color background,
    removeCartFunction,
  }) {
    return Padding(
      padding: EdgeInsets.all(
        6.0,
      ),
      child: Container(
        height: 250,
        width: width,
        child: Row(
          children: [
            Icon(
              Icons.food_bank_outlined,
              size: 140.0,
            ),
            /*CachedNetworkImage(
              imageUrl: model.thumbnailUrl,
              width: 140.0,
              height: 140.0,
              placeholder: (context, url) => circularProgress(),
              errorWidget: (context, url, error) => Icon(
                Icons.error,
              ),
            ),*/
            SizedBox(
              width: 4.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            '\$${discountedPrice(
                              price: model.price,
                              discount: model.discount,
                            )}',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.shortInfo,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.optionsDaily != null &&
                              model.optionsDaily.length > 0) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: displayOptionsDaily(
                                model,
                              ),
                            ),
                          ],
                          model.sopas.length > 0
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Sopa: ",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${model.sopas[0]['name']}",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          model.entremeses.length > 0
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Entremés: ",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${model.entremeses[0]['name']}",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          model.postres.length > 0
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: 5.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Postre: ",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${model.postres[0]['name']}",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Total: ",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "\$ ",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "${Provider.of<ShoppingCart>(context).getItemDailyTotal(
                                    itemModel: model,
                                  )}",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(),
                  ),
                  //TODO: implement the cart item remove feature
                  Align(
                    alignment: Alignment.centerRight,
                    child: !Provider.of<ShoppingCart>(context)
                            .isInDaily(itemModelCheck: model)
                        ? IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              addItemModelDailyToCart(
                                context: context,
                                itemModel: model,
                              );
                            },
                          )
                        : modifyQuantityDaily(
                            context: context,
                            itemModelModify: Provider.of<ShoppingCart>(context)
                                .getDailyModel(
                              itemModel: model,
                            ),
                          ),
                  ),
                  Divider(
                    height: 5.0,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Padding> displayOptions(ItemModel itemModelDisplay) {
    List<Padding> optionsDisplay = [];
    for (Map option in itemModelDisplay.options) {
      Padding optionDisplay = Padding(
        padding: EdgeInsets.only(
          top: 5.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '+ ${option['name']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '(${option['qty']} ${option['qtyUnit']}) ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              '\$ ${option['price']}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      optionsDisplay.add(optionDisplay);
    }
    return optionsDisplay;
  }

  List<Padding> displayOptionsDaily(ItemModel itemModelDisplay) {
    List<Padding> optionsDisplay = [];
    for (Map option in itemModelDisplay.options) {
      Padding optionDisplay = Padding(
        padding: EdgeInsets.only(
          top: 5.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '+ ${option['name']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              '\$ ${option['price']}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      optionsDisplay.add(optionDisplay);
    }
    return optionsDisplay;
  }

  SliverToBoxAdapter beginBuildingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(
              0.5,
            ),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_emoticon,
                color: Colors.white,
              ),
              Text(
                "El carrito está vacío",
              ),
              Text(
                "Empieza a agregar artículos a tu carrito",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
