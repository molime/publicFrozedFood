import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/constants.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class DailyMenus extends StatefulWidget {
  @override
  _DailyMenusState createState() => _DailyMenusState();
}

class _DailyMenusState extends State<DailyMenus> {
  DateTime dateNow;

  Future<void> getDateTime() async {
    //DateTime now = await TrueTime.now();
    DateTime dateTime = await NTP.now();
    print({
      'dateTime from NTP': dateTime,
    });
    /*DateTime dateTimeNow = DateTime.now();
    final int offset = await NTP.getNtpOffset(
      localTime: dateTimeNow,
    );*/
    setState(() {
      dateNow = dateTime;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getDateTime();
    getDateTime();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        if (dateNow == null) ...[
          circularProgress(),
        ],
        if (dateNow != null) ...[
          if (minutes(dateTime: dateNow) <= 810) ...[
            StreamBuilder<QuerySnapshot>(
              stream: EcommerceApp.firestore
                  .collection("dailyMenus")
                  .where(
                    "dayAvailable",
                    isEqualTo: DateTime(
                      dateNow.year,
                      dateNow.month,
                      dateNow.day,
                    ),
                  )
                  .snapshots(),
              builder: (BuildContext context, dataSnapshot) {
                print({
                  'dailyData': dataSnapshot,
                });
                if (!dataSnapshot.hasData) {
                  return Center(
                    child: circularProgress(),
                  );
                } else if (dataSnapshot.data.docs.length == 0) {
                  return noDailyMenus(
                    msg:
                        "Las opciones del día no están disponibles, intente nuevamente más tarde",
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: dataSnapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      ItemModel model = ItemModel.fromJson(
                        dataSnapshot.data.docs[index].data(),
                        dataSnapshot.data.docs[index].id,
                      );
                      return sourceDailyInfo(
                        model: model,
                        context: context,
                      );
                    },
                  );
                }
              },
            ),
          ],
          if (minutes(dateTime: dateNow) > 810) ...[
            noDailyMenus(
              msg:
                  "Sólo aceptamos pedidos de las opciones del día hasta la 1:30 pm",
            ),
          ],
        ],
      ],
    );
  }

  int minutes({DateTime dateTime}) {
    int minutes = (dateTime.hour * 60) + dateTime.minute;
    return minutes;
  }

  Card noDailyMenus({
    @required String msg,
  }) {
    return Card(
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
              msg,
            ),
            Text(
              "Lo sentimos",
            ),
          ],
        ),
      ),
    );
  }
}

Widget sourceDailyInfo({
  ItemModel model,
  BuildContext context,
  Color background,
  removeCartFunction,
}) {
  return InkWell(
    onTap: () {},
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
                    height: 15.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.disponibilidad > 0 &&
                                    model.disponibilidad != null
                                ? "Disponible: ${model.disponibilidad}"
                                : "Agotado",
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
                            .isInDaily(itemModelCheck: model)
                        ? IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              print({
                                'dailyOption': model.toJson(),
                              });
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
    ),
  );
}

void addItemModelDailyToCart({BuildContext context, ItemModel itemModel}) {
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
  List<Map> sopasList = [];
  List<Map> entremesesList = [];
  List<Map> postresList = [];
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

          changeSopa(Map sopaSelected) {
            if (sopasList.length > 0) {
              if (mapEquals(sopaSelected, sopasList[0])) {
                setState(() {
                  sopasList = [];
                });
              } else {
                setState(() {
                  sopasList = [
                    sopaSelected,
                  ];
                });
              }
            } else {
              setState(() {
                sopasList = [
                  sopaSelected,
                ];
              });
            }
          }

          changeEntremes(Map entremesSelected) {
            if (entremesesList.length > 0) {
              if (mapEquals(entremesSelected, entremesesList[0])) {
                setState(() {
                  entremesesList = [];
                });
              } else {
                setState(() {
                  entremesesList = [
                    entremesSelected,
                  ];
                });
              }
            } else {
              setState(() {
                entremesesList = [
                  entremesSelected,
                ];
              });
            }
          }

          changePostre(Map postreSelected) {
            if (postresList.length > 0) {
              if (mapEquals(postreSelected, postresList[0])) {
                setState(() {
                  postresList = [];
                });
              } else {
                setState(() {
                  postresList = [
                    postreSelected,
                  ];
                });
              }
            } else {
              setState(() {
                postresList = [
                  postreSelected,
                ];
              });
            }
          }

          changeSizeStatus(Map optionSelected) {
            if (options.length > 0) {
              if (options.contains(optionSelected)) {
                List<Map> mapList = [];
                for (Map mapCheck in options) {
                  if (!mapEquals(mapCheck, optionSelected)) {
                    mapList.add(mapCheck);
                  }
                }
                double newPrice = discountedPrice(
                  price: itemModel.price,
                  discount: itemModel.discount,
                );
                if (mapList.length > 0) {
                  for (Map mapPriceAdd in mapList) {
                    newPrice += mapPriceAdd['price'];
                  }
                }
                setState(() {
                  options = mapList;
                  price = newPrice;
                  totalPrice = price * initialItemCount;
                });
              } else {
                List<Map> mapList = options;
                mapList.add(optionSelected);
                double newPrice = discountedPrice(
                  price: itemModel.price,
                  discount: itemModel.discount,
                );
                for (Map mapPriceAdd in mapList) {
                  newPrice += mapPriceAdd['price'];
                }
                setState(() {
                  options = mapList;
                  price = newPrice;
                  totalPrice = price * initialItemCount;
                });
              }
            } else {
              List<Map> mapList = [optionSelected];
              double newPrice = discountedPrice(
                price: itemModel.price,
                discount: itemModel.discount,
              );
              for (Map mapPriceAdd in mapList) {
                newPrice += mapPriceAdd['price'];
              }
              setState(() {
                options = mapList;
                price = newPrice;
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
                                ? options.contains(option)
                                    ? primaryColor
                                    : whiteColor
                                : whiteColor,
                            borderRadius: BorderRadius.circular(
                              13.0,
                            ),
                            border: Border.all(
                              width: 1.0,
                              color: greyColor.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: whiteColor,
                            size: 15.0,
                          ),
                        ),
                      ),
                      widthSpace,
                      Text(
                        '${option['name']}',
                        style: listItemTitleStyle,
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

          getOptionsListItem(
              {Map option, Function selectOption, List<Map> optionCompare}) {
            return Padding(
              padding: EdgeInsets.only(right: fixPadding, left: fixPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: selectOption,
                        child: Container(
                          width: 26.0,
                          height: 26.0,
                          decoration: BoxDecoration(
                            color: optionCompare.length > 0
                                ? mapEquals(option, optionCompare[0])
                                    ? primaryColor
                                    : whiteColor
                                : whiteColor,
                            borderRadius: BorderRadius.circular(
                              13.0,
                            ),
                            border: Border.all(
                              width: 1.0,
                              color: greyColor.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            color: whiteColor,
                            size: 15.0,
                          ),
                        ),
                      ),
                      widthSpace,
                      Text(
                        '${option['name']}',
                        style: listItemTitleStyle,
                      ),
                    ],
                  ),
                  /*Text(
                    '\$${option['price']}',
                    style: listItemTitleStyle,
                  ),*/
                ],
              ),
            );
          }

          return Wrap(
            children: <Widget>[
              Container(
                // height: height - 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                            child: Icon(
                              Icons.food_bank_outlined,
                              size: 70.0,
                            ),
                            /*decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              image: DecorationImage(
                                image: NetworkImage(
                                  itemModel.thumbnailUrl,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),*/
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
                                                    BorderRadius.circular(13.0),
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
                                                    BorderRadius.circular(13.0),
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
                    itemModel.optionsDaily.length > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: scaffoldBgColor,
                                padding: EdgeInsets.all(fixPadding),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Opción',
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
                                    itemModel.optionsDaily.length,
                                    (index) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          heightSpace,
                                          getSizeListItem(
                                            itemModel.optionsDaily[index],
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),

                    // Size End
                    // Options Start
                    Container(
                      width: width,
                      color: scaffoldBgColor,
                      padding: EdgeInsets.all(fixPadding),
                      child: Text(
                        'Sopa',
                        style: listItemSubTitleStyle,
                      ),
                    ),
                    Container(
                      color: whiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          itemModel.sopas.length,
                          (index) {
                            return getOptionsListItem(
                              option: itemModel.sopas[index],
                              selectOption: () {
                                changeSopa(
                                  itemModel.sopas[index],
                                );
                              },
                              optionCompare: sopasList,
                            );
                          },
                        ),
                      ),
                    ),
                    // Options End
                    Container(
                      width: width,
                      color: scaffoldBgColor,
                      padding: EdgeInsets.all(fixPadding),
                      child: Text(
                        'Entremés',
                        style: listItemSubTitleStyle,
                      ),
                    ),
                    Container(
                      color: whiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          itemModel.entremeses.length,
                          (index) {
                            return getOptionsListItem(
                              option: itemModel.entremeses[index],
                              selectOption: () {
                                changeEntremes(
                                  itemModel.entremeses[index],
                                );
                              },
                              optionCompare: entremesesList,
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: width,
                      color: scaffoldBgColor,
                      padding: EdgeInsets.all(fixPadding),
                      child: Text(
                        'Postre',
                        style: listItemSubTitleStyle,
                      ),
                    ),
                    Container(
                      color: whiteColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          itemModel.postres.length,
                          (index) {
                            return getOptionsListItem(
                              option: itemModel.postres[index],
                              selectOption: () {
                                changePostre(
                                  itemModel.postres[index],
                                );
                              },
                              optionCompare: postresList,
                            );
                          },
                        ),
                      ),
                    ),
                    // Add to Cart button row start here
                    Padding(
                      padding: EdgeInsets.all(fixPadding),
                      child: InkWell(
                        onTap: () {
                          if (sopasList.length > 0 &&
                              entremesesList.length > 0 &&
                              postresList.length > 0) {
                            Provider.of<ShoppingCart>(context, listen: false)
                                .addToDaily(
                              optionsDailyAdd: options,
                              sopasAdd: sopasList,
                              entremesesAdd: entremesesList,
                              postresAdd: postresList,
                              itemModelAdd: itemModel,
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
                                    message:
                                        'Por favor escoge una sopa, entremés y postre',
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
}

Row modifyQuantityDaily({BuildContext context, ItemModel itemModelModify}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      InkWell(
        onTap: () {
          Provider.of<ShoppingCart>(context, listen: false).decreaseDailyQuant(
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
              .increaseDailyQuantity(itemModel: itemModelModify);
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
