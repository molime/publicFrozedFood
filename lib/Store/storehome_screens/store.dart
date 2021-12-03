import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/constants.dart';
import 'package:e_shop/Config/push_notification_provider.dart';
import 'package:e_shop/Data/category_data.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Orders/myOrders.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/categories_page.dart';
import 'package:e_shop/Store/daily_menus.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Widgets/categoryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/searchBox.dart';
import 'package:e_shop/Models/item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

double width;

class StoreSubScreen extends StatefulWidget {
  @override
  _StoreSubScreenState createState() => _StoreSubScreenState();
}

class _StoreSubScreenState extends State<StoreSubScreen>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    final pushProvider = new PushNotificationsProvider();
    pushProvider.initNotifications();

    /*pushProvider.messagesStream.listen((argumento) {
      print('argumento desde home: $argumento');
      Fluttertoast.showToast(msg: argumento['message']);
    });*/

    _tabController = TabController(length: 2, vsync: this);
    startCategories();
  }

  Future<void> startCategories() async {
    await Provider.of<CategoryData>(
      context,
      listen: false,
    ).initCategories();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  Icons.category,
                  color: Colors.white,
                ),
                text: "Categorías",
              ),
              Tab(
                icon: Icon(
                  Icons.fastfood,
                  color: Colors.white,
                ),
                text: "Lo del día",
              ),
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 5.0,
            isScrollable: true,
            controller: _tabController,
          ),
          actions: [
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
                    Navigator.push(context, route);
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
          ],
        ),
        drawer: MyDrawer(),
        body: Container(
          child: TabBarView(
            controller: _tabController,
            children: [
              CategoriesScreen(),
              DailyMenus(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget sourceInfo({
  ItemModel model,
  BuildContext context,
  Color background,
  removeCartFunction,
}) {
  return InkWell(
    onTap: () {
      Route route = MaterialPageRoute(
        builder: (context) => ProductPage(
          itemModel: model,
        ),
      );
      Navigator.pushReplacement(context, route);
    },
    splashColor: Colors.pink,
    child: Padding(
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
                  if (model.discount != null && model.discount > 0) ...[
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.pink,
                          ),
                          alignment: Alignment.topLeft,
                          width: 40.0,
                          height: 43.0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "50%",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  "OFF",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 0.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Precio original: \$ ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    "${model.price}",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Precio nuevo: ",
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
                                    "${discountedPrice(
                                      price: model.price,
                                      discount: model.discount,
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
                  ],
                  if (model.discount == null || model.discount == 0) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Precio: ",
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
                                    "${model.price}",
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
                  ],
                  Flexible(
                    child: Container(),
                  ),
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
    ),
  );
}

Widget card({Color primaryColor = Colors.redAccent, String imgPath}) {
  return Container(
    height: 150.0,
    width: width * 0.34,
    margin: EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 10.0,
    ),
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.all(
        Radius.circular(
          20.0,
        ),
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          offset: Offset(
            0,
            5,
          ),
          blurRadius: 10.0,
          color: Colors.grey[200],
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(
          20.0,
        ),
      ),
      child: Image.network(
        imgPath,
        height: 150.0,
        width: width * 0.34,
        fit: BoxFit.fill,
      ),
    ),
  );
}

void addItemModelToCart({BuildContext context, ItemModel itemModel}) {
  Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  int initialItemCount = 1;
  double width = MediaQuery.of(context).size.width;
  double totalPrice = discountedPrice(
    price: itemModel.price,
    discount: itemModel.discount,
  );
  double price = discountedPrice(
    price: itemModel.price,
    discount: itemModel.discount,
  );
  List<Map> options = [];
  if (itemModel.options.length > 0) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            incrementItem() {
              setState(() {
                initialItemCount = initialItemCount + 1;
                totalPrice = price * initialItemCount;
              });
            }

            decrementItem() {
              if (initialItemCount > 1) {
                setState(() {
                  initialItemCount = initialItemCount - 1;
                  totalPrice = price * initialItemCount;
                });
              } else {
                Navigator.pop(context);
              }
            }

            changeSizeStatus(Map optionSelected) {
              if (options.length > 0) {
                if (mapEquals(optionSelected, options[0])) {
                  setState(() {
                    options = [];
                    price = discountedPrice(
                      price: itemModel.price,
                      discount: itemModel.discount,
                    );
                    totalPrice = price * initialItemCount;
                  });
                } else {
                  setState(() {
                    options = [
                      optionSelected,
                    ];
                    price = discountedPrice(
                          price: itemModel.price,
                          discount: itemModel.discount,
                        ) +
                        options[0]['price'];
                    totalPrice = price * initialItemCount;
                  });
                }
              } else {
                setState(() {
                  options = [
                    optionSelected,
                  ];
                  price = discountedPrice(
                        price: itemModel.price,
                        discount: itemModel.discount,
                      ) +
                      options[0]['price'];
                  totalPrice = price * initialItemCount;
                });
              }
            }

            getSizeListItem(
              Map option,
            ) {
              return Padding(
                padding: EdgeInsets.only(right: fixPadding, left: fixPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            changeSizeStatus(option);
                          },
                          child: Container(
                            width: 26.0,
                            height: 26.0,
                            decoration: BoxDecoration(
                                color: options.length > 0
                                    ? mapEquals(options[0], option)
                                        ? primaryColor
                                        : whiteColor
                                    : whiteColor,
                                borderRadius: BorderRadius.circular(13.0),
                                border: Border.all(
                                    width: 1.0,
                                    color: greyColor.withOpacity(0.7))),
                            child: Icon(Icons.check,
                                color: whiteColor, size: 15.0),
                          ),
                        ),
                        widthSpace,
                        Text(
                          'Tamaño ${option['name']}',
                          style: listItemTitleStyle,
                        ),
                        widthSpace,
                        Text(
                          '(${option['qty']} ${option['qtyUnit']})',
                          style: listItemSubTitleStyle,
                        ),
                      ],
                    ),
                    Text(
                      '\$${option['price']}',
                      style: listItemTitleStyle,
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              children: <Widget>[
                Container(
                  // height: height - 100.0,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    color: whiteColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(fixPadding),
                        alignment: Alignment.center,
                        child: Container(
                          width: 35.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: greyColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fixPadding),
                        child: Text(
                          'Agregar nuevo artículo',
                          style: headingStyle,
                        ),
                      ),
                      Container(
                        width: width,
                        height: 70.0,
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 70.0,
                              width: 70.0,
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    itemModel.thumbnailUrl,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: width - ((fixPadding * 2) + 70.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: fixPadding * 2,
                                        left: fixPadding,
                                        bottom: fixPadding),
                                    child: Text(
                                      itemModel.title,
                                      style: listItemTitleStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: fixPadding,
                                        right: fixPadding,
                                        left: fixPadding),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '\$$price',
                                          style: priceStyle,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: decrementItem,
                                              child: Container(
                                                height: 26.0,
                                                width: 26.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.0),
                                                  color: (initialItemCount == 1)
                                                      ? Colors.grey[300]
                                                      : primaryColor,
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: (initialItemCount == 1)
                                                      ? blackColor
                                                      : whiteColor,
                                                  size: 15.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0, left: 8.0),
                                              child: Text('$initialItemCount'),
                                            ),
                                            InkWell(
                                              onTap: incrementItem,
                                              child: Container(
                                                height: 26.0,
                                                width: 26.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.0),
                                                  color: primaryColor,
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: whiteColor,
                                                  size: 15.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      heightSpace,
                      // Size Start
                      Container(
                        color: scaffoldBgColor,
                        padding: EdgeInsets.all(fixPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Tamaño',
                              style: listItemSubTitleStyle,
                            ),
                            Text(
                              'Precio',
                              style: listItemSubTitleStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: whiteColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Column>.generate(
                              itemModel.options.length, (index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                heightSpace,
                                getSizeListItem(
                                  itemModel.options[index],
                                )
                              ],
                            );
                          }) /*<Widget>[
                            heightSpace,
                            getSizeListItem('S', '500', '0'),
                            heightSpace,
                            getSizeListItem('M', '750', '0.5'),
                            heightSpace,
                            getSizeListItem('L', '1100', '1.2'),
                            heightSpace,
                          ]*/
                          ,
                        ),
                      ),
                      // Size End
                      // Options Start
                      /*Container(
                        width: width,
                        color: scaffoldBgColor,
                        padding: EdgeInsets.all(fixPadding),
                        child: Text(
                          'Options',
                          style: listItemSubTitleStyle,
                        ),
                      ),
                      Container(
                        color: whiteColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            heightSpace,
                            getOptionsListItem('Add Lemon'),
                            heightSpace,
                            getOptionsListItem('Add Ice'),
                            heightSpace,
                          ],
                        ),
                      ),*/
                      // Options End
                      // Add to Cart button row start here
                      Padding(
                        padding: EdgeInsets.all(fixPadding),
                        child: InkWell(
                          onTap: () {
                            if (options.length > 0) {
                              Provider.of<ShoppingCart>(context, listen: false)
                                  .addToCart(
                                itemModelAdd: itemModel,
                                optionsAdd: options,
                                count: initialItemCount,
                              );
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Se ha agregado el artículo al carrito",
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ErrorAlertDialog(
                                      message: 'Escoge un tamaño, por favor.',
                                    );
                                  });
                            }
                            /*Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: ConfirmOrder()));*/
                          },
                          child: Container(
                            width: width - (fixPadding * 2),
                            padding: EdgeInsets.all(fixPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: primaryColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '$initialItemCount ARTÍCULOS',
                                      style: TextStyle(
                                        color: darkPrimaryColor,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 3.0),
                                    Text(
                                      '\$$totalPrice',
                                      style: whiteSubHeadingStyle,
                                    ),
                                  ],
                                ),
                                Text(
                                  'Agregar al carrito',
                                  style: wbuttonWhiteTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Add to Cart button row end here
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  } else {
    Provider.of<ShoppingCart>(context, listen: false).addToCart(
      itemModelAdd: itemModel,
      optionsAdd: [],
      count: 1,
    );
    Fluttertoast.showToast(
      msg: "Se ha agregado el artículo al carrito",
    );
  }
}

void checkItemInCart(
    String productID, BuildContext context, ItemModel itemModel) {
  EcommerceApp.sharedPreferences
      .getStringList(EcommerceApp.userCartList)
      .contains(productID);
  bool isInCart = Provider.of<ShoppingCart>(context, listen: false)
      .isInCart(itemModelCheck: itemModel);
  isInCart
      ? Fluttertoast.showToast(
          msg: "El artículo ya está en el carrito.",
        )
      : addItemToCart(
          productID,
          context,
        );
}

void addItemToCart(String productId, BuildContext context) {
  List tempList =
      EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
}

double discountedPrice({int price, int discount}) {
  if (discount != null || discount != 0) {
    double discountDecimal = discount / 100;
    double discountReal = 1 - discountDecimal;

    double priceDiscounted = price * discountReal;
    return double.parse(
      priceDiscounted.toStringAsFixed(2),
    );
  } else {
    return double.parse(
      price.toStringAsFixed(2),
    );
  }
}

Row modifyQuantity({BuildContext context, ItemModel itemModelModify}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      InkWell(
        onTap: () {
          Provider.of<ShoppingCart>(context, listen: false).decreaseQuant(
            itemModelDecrease: itemModelModify,
          );
        },
        child: Container(
          height: 26.0,
          width: 26.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: (itemModelModify.countAdded == 1)
                ? Colors.grey[300]
                : primaryColor,
          ),
          child: Icon(
            Icons.remove,
            color: (itemModelModify.countAdded == 1) ? blackColor : whiteColor,
            size: 15.0,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: 8.0, left: 8.0),
        child: Text('${itemModelModify.countAdded}'),
      ),
      InkWell(
        onTap: () {
          Provider.of<ShoppingCart>(context, listen: false)
              .increaseQuantity(itemModelQuant: itemModelModify);
        },
        child: Container(
          height: 26.0,
          width: 26.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.0),
            color: primaryColor,
          ),
          child: Icon(
            Icons.add,
            color: whiteColor,
            size: 15.0,
          ),
        ),
      ),
    ],
  );
}
