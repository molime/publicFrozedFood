import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Store/storehome.dart';

int counter = 0;

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isInDetailsPage;

  OrderCard({
    Key key,
    this.order,
    this.isInDetailsPage = false,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: !isInDetailsPage
          ? () {
              Route route;
              if (counter == 0) {
                counter++;
                route = MaterialPageRoute(
                  builder: (context) => OrderDetails(
                    orderId: order.uid,
                    order: order,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  route,
                );
              }
            }
          : () {},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        elevation: 20.0,
        child: Container(
          /*decoration: new BoxDecoration(
            color: Colors.grey.withOpacity(
              0.2,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
          ),*/
          padding: EdgeInsets.all(
            8.0,
          ),
          margin: EdgeInsets.all(
            10.0,
          ),
          height: order.products.length * 190.0,
          child: ListView.builder(
            itemCount: order.products.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index != order.products.length - 1) {
                return Column(
                  children: [
                    sourceOrderInfo(
                      order.products[index],
                      context,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                );
              } else {
                return sourceOrderInfo(
                  order.products[index],
                  context,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget sourceOrderInfo(ItemModel model, BuildContext context,
    {Color background}) {
  width = MediaQuery.of(context).size.width;

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.all(
        Radius.circular(
          20,
        ),
      ),
    ),
    //color: Colors.grey[100],
    height: 170,
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
                              "Cantidad: ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${model.countAdded}",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey,
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
                              "${model.getItemTotal()}",
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
          ),
        ),
      ],
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

class OrderDailyCard extends StatelessWidget {
  final Order order;
  final bool isInDetailsPage;

  OrderDailyCard({
    Key key,
    this.order,
    this.isInDetailsPage,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      elevation: 20.0,
      child: Container(
        padding: EdgeInsets.all(
          8.0,
        ),
        margin: EdgeInsets.all(
          10.0,
        ),
        height: order.dailyProducts.length * 250.0,
        child: ListView.builder(
          itemCount: order.dailyProducts.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index != order.dailyProducts.length - 1) {
              return Column(
                children: [
                  sourceOrderDailyInfo(
                    order.dailyProducts[index],
                    context,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              );
            } else {
              return sourceOrderDailyInfo(
                order.dailyProducts[index],
                context,
              );
            }
          },
        ),
      ),
    );
  }
}

Widget sourceOrderDailyInfo(ItemModel model, BuildContext context,
    {Color background}) {
  width = MediaQuery.of(context).size.width;

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
                                "${model.getItemDailyTotal()}",
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
            ),
          ),
        ],
      ),
    ),
  );
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
