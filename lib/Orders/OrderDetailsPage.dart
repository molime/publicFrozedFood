import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/Models/creditCard.dart';
import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Orders/myOrders.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/orderCard.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatelessWidget {
  final String orderId;
  final Order order;

  OrderDetails({
    Key key,
    this.orderId,
    this.order,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                StatusBanner(
                  status: order.isSuccess,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.all(
                    4.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      order.dailyProducts.length > 0 &&
                              order.dailyProducts != null
                          ? "Total de la orden: \$ ${order.dailyTotalAmount}"
                          : "Total de la orden: \$ ${order.normalTotalAmount}",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    4.0,
                  ),
                  child: statusOrder(
                    sent: order.sent,
                    delivered: order.delivered,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    4.0,
                  ),
                  child: Text(
                    "Ordenado el: ${DateFormat("dd/MM/yyy").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(order.orderTime),
                      ),
                    )}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    4.0,
                  ),
                  child: Text(
                    "Fecha de entrega: ${DateFormat("dd/MM/yyy").format(
                      order.deliveryDate,
                    )}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Divider(
                  height: 2.0,
                ),
                PaymentDetailsCard(
                  creditCardId: order.paymentMethod,
                ),
                Divider(
                  height: 2.0,
                ),
                if (order.products.length > 0) ...[
                  OrderCard(
                    order: order,
                    isInDetailsPage: true,
                  ),
                ],
                if (order.dailyProducts.length > 0) ...[
                  OrderDailyCard(
                    order: order,
                    isInDetailsPage: true,
                  ),
                ],
                Divider(
                  height: 2.0,
                ),
                ShippingDetails(
                  model: order.addressDetails,
                  orderModel: order,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Text statusOrder({bool sent, bool delivered}) {
  if (!sent) {
    return Text('Estatus de la órden: Por enviar');
  } else if (sent && !delivered) {
    return Text("Estatus de la órden: En camino");
  } else {
    return Text("Estatus de la órden: Entregada");
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;

  StatusBanner({
    Key key,
    this.status,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Exitosa" : msg = "Fracasada";
    return Container(
      decoration: new BoxDecoration(
        color: Colors.lightGreenAccent,
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Route route = MaterialPageRoute(
                builder: (context) => MyOrders(),
              );
              Navigator.pushReplacement(
                context,
                route,
              );
            },
            child: Container(
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            "Orden " + msg,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentDetailsCard extends StatefulWidget {
  final String creditCardId;

  PaymentDetailsCard({
    this.creditCardId,
  });

  @override
  _PaymentDetailsCardState createState() => _PaymentDetailsCardState();
}

class _PaymentDetailsCardState extends State<PaymentDetailsCard> {
  bool showSpinner = false;
  CreditCard creditCard;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCard();
  }

  Future<void> getCard() async {
    setState(() {
      showSpinner = true;
    });
    creditCard =
        await Provider.of<CreditCardData>(context, listen: false).getCreditCard(
      cardId: widget.creditCardId,
    );
    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !showSpinner
        ? creditCard != null
            ? Container(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightGreen,
                        child: Icon(
                          Icons.credit_card,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        "${creditCard.expMonth}/${creditCard.expYear}, ${creditCard.last4}",
                      ),
                      subtitle: Text(
                        creditCard.brand.toUpperCase(),
                      ),
                      trailing: Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.lightGreen,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        label: Text(
                          "Pagado",
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.lightGreen,
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "Hubo un error consiguiendo la información de la tarjeta",
                  ),
                  subtitle: Text(
                    "Lo sentimos",
                  ),
                ),
              )
        : circularProgress();
  }
}

class ShippingDetails extends StatelessWidget {
  final AddressModel model;
  final Order orderModel;
  ShippingDetails({
    Key key,
    this.model,
    this.orderModel,
  }) : super(
          key: key,
        );
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Text(
            "Dirección de entrega",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 90.0,
            vertical: 5.0,
          ),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(
                children: [
                  KeyText(
                    msg: "Dirección calle",
                  ),
                  Text(
                    model.thoroughfare + ' ' + model.subThroughFare,
                  ),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Ciudad",
                  ),
                  Text(
                    model.locality,
                  ),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Colonia",
                  ),
                  Text(
                    model.subLocality,
                  ),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "País",
                  ),
                  Text(
                    model.countryName,
                  ),
                ],
              ),
              TableRow(
                children: [
                  KeyText(
                    msg: "Código Postal",
                  ),
                  Text(
                    model.postalCode,
                  ),
                ],
              ),
              if (model.reference != null && model.reference != "") ...[
                TableRow(
                  children: [
                    KeyText(
                      msg: "Referencia",
                    ),
                    Text(
                      model.reference,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        /*!orderModel.delivered || orderModel.delivered == null
            ? Padding(
                padding: EdgeInsets.all(
                  10.0,
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      confirmedUserOrderReceived(
                        context,
                        orderModel.uid,
                      );
                    },
                    child: Container(
                      decoration: new BoxDecoration(
                        color: Colors.lightGreenAccent,
                      ),
                      width: MediaQuery.of(context).size.width - 40.0,
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Confirmar de entregado",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),*/
      ],
    );
  }

  Future<void> confirmedUserOrderReceived(
    BuildContext context,
    String orderId,
  ) async {
    await EcommerceApp.firestore
        .collection(
          EcommerceApp.collectionUser,
        )
        .doc(
          EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
        )
        .collection(
          EcommerceApp.collectionOrders,
        )
        .doc(
          orderId,
        )
        .update(
      {
        "delivered": true,
      },
    );
    await EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .doc(orderId)
        .update(
      {
        "delivered": true,
      },
    );

    Route route = MaterialPageRoute(
      builder: (context) => StoreHome(),
    );
    Navigator.pushReplacement(
      context,
      route,
    );

    Fluttertoast.showToast(
      msg: "La orden ha sido confirmada de recibida.",
    );
  }
}
