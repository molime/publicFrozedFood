import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/stripe.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/creditCard.dart';
import 'package:e_shop/Orders/addCard.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Config/constants.dart';
import 'package:ntp/ntp.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final double totalAmount;

  PaymentPage({
    Key key,
    this.totalAmount,
    this.addressId,
  }) : super(
          key: key,
        );

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  DateTime _dateTimeSelected;
  bool showSpinner = false;

  Future<void> startCreditCards() async {
    await Provider.of<CreditCardData>(context, listen: false).initCreditCards();
  }

  int minutesPlaceOrder({DateTime dateTime}) {
    int minutes = (dateTime.hour * 60) + dateTime.minute;
    return minutes;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    startCreditCards();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: MyAppBar(
          leadingWidget: IconButton(
            icon: Icon(
              Icons.chevron_left,
            ),
            onPressed: () {
              Route route = MaterialPageRoute(
                builder: (context) => AddressScreen(),
              );
              Navigator.pushReplacement(
                context,
                route,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (Provider.of<ShoppingCart>(context, listen: false)
                    .itemsCart
                    .length >
                0) {
              if (Provider.of<CreditCardData>(context, listen: false)
                          .creditCardSelected ==
                      null ||
                  _dateTimeSelected == null) {
                showDialog(
                  context: context,
                  builder: (c) {
                    return ErrorAlertDialog(
                      message:
                          "Por favor selecciona una tarjeta y fecha de entrega.",
                    );
                  },
                );
              } else {
                if (Provider.of<ShoppingCart>(context, listen: false)
                        .getTotalAmount() <
                    10) {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(
                        message: "El monto mínimo por orden es de \$10.00 MXN.",
                      );
                    },
                  );
                } else {
                  setState(() {
                    showSpinner = true;
                  });
                  DateTime timeSend = await NTP.now();
                  if (Provider.of<ShoppingCart>(context, listen: false)
                          .dailyItems
                          .length >
                      0) {
                    if (minutesPlaceOrder(dateTime: timeSend) > 810) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Sólo aceptamos pedidos de los productos del día hasta la 1:30 pm, lo sentimos.",
                          );
                        },
                      );
                      return;
                    }
                    if (!Provider.of<ShoppingCart>(context, listen: false)
                        .allDailyItemsBelongToday(
                      today: timeSend,
                    )) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Tienes un producto que es de otro día, por lo que no podemos procesar tu pedido. Lo sentimos.",
                          );
                        },
                      );
                      return;
                    }
                    if (!await Provider.of<ShoppingCart>(context, listen: false)
                        .dailyStillAvailable(
                      dateTime: timeSend,
                    )) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Ya se agotó uno o más de los productos del día que quieres comprar, lo sentimos",
                          );
                        },
                      );
                      return;
                    }
                  }
                  bool resultPay = await addOrderDetails(
                    timeOrdered: timeSend,
                  );
                  setState(() {
                    showSpinner = false;
                  });
                  if (resultPay) {
                    Route route = MaterialPageRoute(
                      builder: (context) => StoreHome(),
                    );
                    Navigator.pushReplacement(
                      context,
                      route,
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            "Hubo un error procesando la orden. Por favor vuelva a intentarlo");
                  }
                }
              }
            } else {
              if (Provider.of<CreditCardData>(context, listen: false)
                      .creditCardSelected ==
                  null) {
                showDialog(
                  context: context,
                  builder: (c) {
                    return ErrorAlertDialog(
                      message:
                          "Por favor selecciona una tarjeta y fecha de entrega.",
                    );
                  },
                );
              } else {
                if (Provider.of<ShoppingCart>(context, listen: false)
                        .getTotalAmount() <
                    10) {
                  showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(
                        message: "El monto mínimo por orden es de \$10.00 MXN.",
                      );
                    },
                  );
                } else {
                  setState(() {
                    showSpinner = true;
                  });
                  DateTime dateSend = await NTP.now();
                  if (Provider.of<ShoppingCart>(context, listen: false)
                          .dailyItems
                          .length >
                      0) {
                    if (minutesPlaceOrder(dateTime: dateSend) > 810) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Sólo aceptamos pedidos de los productos del día hasta la 1:30 pm, lo sentimos.",
                          );
                        },
                      );
                      return;
                    }
                    if (!Provider.of<ShoppingCart>(context, listen: false)
                        .allDailyItemsBelongToday(
                      today: dateSend,
                    )) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Tienes un producto que es de otro día, por lo que no podemos procesar tu pedido. Lo sentimos.",
                          );
                        },
                      );
                      return;
                    }
                    if (!await Provider.of<ShoppingCart>(context, listen: false)
                        .dailyStillAvailable(
                      dateTime: dateSend,
                    )) {
                      setState(() {
                        showSpinner = false;
                      });
                      showDialog(
                        context: context,
                        builder: (c) {
                          return ErrorAlertDialog(
                            message:
                                "Ya se agotó uno o más de los productos del día que quieres comprar, lo sentimos",
                          );
                        },
                      );
                      return;
                    }
                  }
                  bool resultPay = await addOrderDetails(
                    timeOrdered: dateSend,
                  );
                  setState(() {
                    showSpinner = false;
                  });
                  if (resultPay) {
                    Route route = MaterialPageRoute(
                      builder: (context) => StoreHome(),
                    );
                    Navigator.pushReplacement(
                      context,
                      route,
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            "Hubo un error procesando la orden. Por favor vuelva a intentarlo");
                  }
                }
              }
            }
          },
          label: Text(
            "Pagar y crear orden",
          ),
          backgroundColor: Colors.pink,
          icon: Icon(
            Icons.food_bank_outlined,
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(
                    8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Seleccionar tarjeta",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        alignment: Alignment.topCenter,
                        icon: Icon(
                          Icons.add,
                          size: 24.0,
                        ),
                        onPressed: () {
                          Route route = MaterialPageRoute(
                            builder: (context) => AddCard(
                              fromCardPage: true,
                            ),
                          );
                          Navigator.pushReplacement(context, route);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Provider.of<CreditCardData>(context).showLoadingCards()
                  ? circularProgress()
                  : paymentMethod(
                      creditCardList: Provider.of<CreditCardData>(context)
                          .creditCards
                          .toList(),
                    ),
              if (Provider.of<ShoppingCart>(context).itemsCart.toList().length >
                  0) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(
                      8.0,
                    ),
                    child: Text(
                      "Seleccionar fecha de entrega para tus productos del menú",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                _dateTimeSelected != null
                    ? Text(
                        DateFormat('dd/MM/yyyy').format(
                          _dateTimeSelected,
                        ),
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      )
                    : Container(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink,
                    onPrimary: Colors.white,
                  ),
                  /*ButtonStyle(
                  foregroundColor: Colors.pink,
                ),*/
                  onPressed: () async {
                    DateTime nowDate = await NTP.now();
                    DateTime initialDate;
                    if (nowDate.hour >= 16) {
                      if (nowDate.hour == 16 && nowDate.minute == 0) {
                        initialDate = nowDate.add(
                          Duration(
                            days: 1,
                          ),
                        );
                      } else {
                        initialDate = nowDate.add(
                          Duration(
                            days: 2,
                          ),
                        );
                      }
                    } else {
                      initialDate = nowDate.add(
                        Duration(days: 1),
                      );
                    }
                    DateTime dateTimePicked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: initialDate,
                      lastDate: nowDate.add(
                        Duration(
                          days: 7,
                        ),
                      ),
                    );
                    setState(() {
                      _dateTimeSelected = dateTimePicked;
                    });
                  },
                  //color: Colors.pink,
                  child: Text(
                    'Seleccionar fecha',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> addOrderDetails({@required DateTime timeOrdered}) async {
    Map mapPayment = await processPayment(
      customerId:
          EcommerceApp.sharedPreferences.getString(EcommerceApp.userStripeId),
      amount:
          Provider.of<ShoppingCart>(context, listen: false).getTotalAmount(),
      paymentMethod: Provider.of<CreditCardData>(context, listen: false)
          .creditCardSelected
          .id,
      email: EcommerceApp.sharedPreferences.getString(
        EcommerceApp.userEmail,
      ),
    );
    if (mapPayment == null) {
      print("mapPayment == null");
      showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message:
                "Hubo un error procesando el pago. Por favor vuelva a intentarlo",
          );
        },
      );
      return false;
    } else {
      print("MapPayment != null");
      /*DocumentReference clientOrder = await writeOrderDetails({
        EcommerceApp.addressID: Provider.of<ShoppingCart>(
          context,
          listen: false,
        ).selectedAddress.uid,
        "addressDetails": Provider.of<ShoppingCart>(
          context,
          listen: false,
        ).selectedAddress.toJson(),
        EcommerceApp.totalAmount: Provider.of<ShoppingCart>(
          context,
          listen: false,
        ).getTotalAmount(),
        "orderBy": EcommerceApp.sharedPreferences.getString(
          EcommerceApp.userUID,
        ),
        EcommerceApp.productID: Provider.of<ShoppingCart>(
          context,
          listen: false,
        ).getProductUids(),
        "dailyProductIds":
            Provider.of<ShoppingCart>(context, listen: false).getDailyUids(),
        EcommerceApp.paymentDetails: "Card payment",
        EcommerceApp.orderTime: timeOrdered.millisecondsSinceEpoch.toString()
        */ /*await NTP.now().millisecondsSinceEpoch.toString()*/ /*,
        EcommerceApp.isSuccess: true,
        "products":
            Provider.of<ShoppingCart>(context, listen: false).itemsCartToJson(),
        "dailyProducts": Provider.of<ShoppingCart>(context, listen: false)
            .itemsDailyToJson(),
        "paymentIntent": mapPayment["id"],
        "paymentMethod": Provider.of<CreditCardData>(context, listen: false)
            .creditCardSelected
            .id,
        "deliveryDate": _dateTimeSelected,
        "delivered": false,
        "sent": false,
      });*/

      DocumentReference dailyOrder;
      DocumentReference normalOrder;

      if (Provider.of<ShoppingCart>(context, listen: false).dailyItems.length >
              0 &&
          Provider.of<ShoppingCart>(context, listen: false).itemsCart.length >
              0) {
        print("both dailyOrder and normalOrder");
        dailyOrder = await writeOrderDetailsForAdmin({
          EcommerceApp.addressID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.uid,
          "addressDetails": Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.toJson(),
          EcommerceApp.totalAmount: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getTotalAmount(),
          "dailyTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getDailyTotalAmount(),
          "normalTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getItemsTotalAmount(),
          "orderBy": EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
          "dailyProductIds":
              Provider.of<ShoppingCart>(context, listen: false).getDailyUids(),
          EcommerceApp.paymentDetails: "Card payment",
          EcommerceApp.orderTime: timeOrdered.millisecondsSinceEpoch.toString(),
          /*DateTime.now().millisecondsSinceEpoch.toString(),*/
          EcommerceApp.isSuccess: true,
          "dailyProducts": Provider.of<ShoppingCart>(context, listen: false)
              .itemsDailyToJson(),
          "paymentIntent": mapPayment["id"],
          "paymentMethod": Provider.of<CreditCardData>(context, listen: false)
              .creditCardSelected
              .id,
          "deliveryDate": timeOrdered,
          "delivered": false,
          "sent": false,
          //"clientOrderUid": clientOrder.id,
        });

        normalOrder = await writeOrderDetailsForAdmin({
          EcommerceApp.addressID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.uid,
          "addressDetails": Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.toJson(),
          EcommerceApp.totalAmount: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getTotalAmount(),
          "dailyTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getDailyTotalAmount(),
          "normalTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getItemsTotalAmount(),
          "orderBy": EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
          EcommerceApp.productID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getProductUids(),
          EcommerceApp.paymentDetails: "Card payment",
          EcommerceApp.orderTime: timeOrdered.millisecondsSinceEpoch.toString(),
          /*DateTime.now().millisecondsSinceEpoch.toString(),*/
          EcommerceApp.isSuccess: true,
          "products": Provider.of<ShoppingCart>(context, listen: false)
              .itemsCartToJson(),
          "paymentIntent": mapPayment["id"],
          "paymentMethod": Provider.of<CreditCardData>(context, listen: false)
              .creditCardSelected
              .id,
          "deliveryDate": _dateTimeSelected,
          "delivered": false,
          "sent": false,
          "dailyOrderUid": dailyOrder.id,
          //"clientOrderUid": clientOrder.id,
        });
      } else if (Provider.of<ShoppingCart>(context, listen: false)
                  .itemsCart
                  .length >
              0 &&
          Provider.of<ShoppingCart>(context, listen: false).dailyItems.length ==
              0) {
        print("only normalOrder");
        normalOrder = await writeOrderDetailsForAdmin({
          EcommerceApp.addressID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.uid,
          "addressDetails": Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.toJson(),
          EcommerceApp.totalAmount: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getTotalAmount(),
          "dailyTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getDailyTotalAmount(),
          "normalTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getItemsTotalAmount(),
          "orderBy": EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
          EcommerceApp.productID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getProductUids(),
          EcommerceApp.paymentDetails: "Card payment",
          EcommerceApp.orderTime: timeOrdered.millisecondsSinceEpoch.toString(),
          /*DateTime.now().millisecondsSinceEpoch.toString(),*/
          EcommerceApp.isSuccess: true,
          "products": Provider.of<ShoppingCart>(context, listen: false)
              .itemsCartToJson(),
          "paymentIntent": mapPayment["id"],
          "paymentMethod": Provider.of<CreditCardData>(context, listen: false)
              .creditCardSelected
              .id,
          "deliveryDate": _dateTimeSelected,
          "delivered": false,
          "sent": false,
          //"clientOrderUid": clientOrder.id,
        });
      } else if (Provider.of<ShoppingCart>(context, listen: false)
                  .itemsCart
                  .length ==
              0 &&
          Provider.of<ShoppingCart>(context, listen: false).dailyItems.length >
              0) {
        print("only dailyOrder");
        dailyOrder = await writeOrderDetailsForAdmin({
          EcommerceApp.addressID: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.uid,
          "addressDetails": Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).selectedAddress.toJson(),
          EcommerceApp.totalAmount: Provider.of<ShoppingCart>(
            context,
            listen: false,
          ).getTotalAmount(),
          "dailyTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getDailyTotalAmount(),
          "normalTotalAmount": Provider.of<ShoppingCart>(context, listen: false)
              .getItemsTotalAmount(),
          "orderBy": EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
          "dailyProductIds":
              Provider.of<ShoppingCart>(context, listen: false).getDailyUids(),
          EcommerceApp.paymentDetails: "Card payment",
          EcommerceApp.orderTime: timeOrdered.millisecondsSinceEpoch.toString(),
          /*DateTime.now().millisecondsSinceEpoch.toString(),*/
          EcommerceApp.isSuccess: true,
          "dailyProducts": Provider.of<ShoppingCart>(context, listen: false)
              .itemsDailyToJson(),
          "paymentIntent": mapPayment["id"],
          "paymentMethod": Provider.of<CreditCardData>(context, listen: false)
              .creditCardSelected
              .id,
          "deliveryDate": timeOrdered,
          "delivered": false,
          "sent": false,
          //"clientOrderUid": clientOrder.id,
        });
      } else {
        print("refund to create");
        Map mapRefund = await createRefund(
          paymentIntentId: mapPayment["id"],
        );
        if (mapRefund != null) {
          print("refund successful no daily nor normal");
          showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(
                message:
                    "Hubo un error creando la orden y ya te reembolsamos tu dinero. Una disculpa por el inconveniente.",
              );
            },
          );
          return false;
        } else {
          print("refund unsuccessful no daily nor normal");
          showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(
                message:
                    "Hubo un error creando la orden. Por favor ponte en contanto con restaurantestictac@gmail.com para que te reembolsemos tu dinero. Una disculpa por el inconveniente.",
              );
            },
          );
          return false;
        }
      }

      if (isOrderCreationSuccess(
        dailyOrder: dailyOrder,
        normalOrder: normalOrder,
        dailyLength:
            Provider.of<ShoppingCart>(context, listen: false).dailyItems.length,
        normalLength:
            Provider.of<ShoppingCart>(context, listen: false).itemsCart.length,
      )) {
        print("order creation successful");
        await Provider.of<ShoppingCart>(context, listen: false)
            .updateDisponibilidades();
        Provider.of<ShoppingCart>(context, listen: false)
            .deleteSelectedAddress();
        Provider.of<ShoppingCart>(context, listen: false).emptyCart();
        Provider.of<ShoppingCart>(context, listen: false).emptyDaily();
        Provider.of<CreditCardData>(context, listen: false)
            .deleteSelectedCard();
        Fluttertoast.showToast(
          msg: "Tu orden ha sido creada con éxito.",
        );
        return true;
      } else {
        print("order creation unsuccessful");
        Map mapRefund = await createRefund(
          paymentIntentId: mapPayment["id"],
        );
        if (mapRefund != null) {
          print("refund normal successful");
          showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(
                message:
                    "Hubo un error creando la orden y ya te reembolsamos tu dinero. Una disculpa por el inconveniente.",
              );
            },
          );
          return false;
        } else {
          print("refund normal unsuccessful");
          showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(
                message:
                    "Hubo un error creando la orden. Por favor ponte en contanto con restaurantestictac@gmail.com para que te reembolsemos tu dinero. Una disculpa por el inconveniente.",
              );
            },
          );
          return false;
        }
      }
    }
  }

  Future<DocumentReference> writeOrderDetails(Map<String, dynamic> data) async {
    return await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .doc(
          EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
        )
        .collection(EcommerceApp.collectionOrders)
        .add(data);
  }

  Future<DocumentReference> writeOrderDetailsForAdmin(
      Map<String, dynamic> data) async {
    return await EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .add(data);
  }

  Container paymentMethod({List<CreditCard> creditCardList}) {
    double width = MediaQuery.of(context).size.width;
    return creditCardList != null && creditCardList.length > 0
        ? Container(
            width: width,
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: creditCardList.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: Provider.of<CreditCardData>(context)
                          .isSelectedCard(creditCard: creditCardList[index])
                      ? () {
                          Provider.of<CreditCardData>(context, listen: false)
                              .deleteSelectedCard();
                        }
                      : () {
                          Provider.of<CreditCardData>(context, listen: false)
                              .setSelectedCard(
                                  creditCard: creditCardList[index]);
                        },
                  child: Padding(
                    padding: EdgeInsets.all(fixPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 1.0,
                          color: Provider.of<CreditCardData>(context)
                                  .isSelectedCard(
                                      creditCard: creditCardList[index])
                              ? primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 100.0,
                            padding: EdgeInsets.only(
                              top: fixPadding,
                              bottom: fixPadding,
                              left: fixPadding,
                              right: Provider.of<CreditCardData>(context)
                                      .isSelectedCard(
                                          creditCard: creditCardList[index])
                                  ? fixPadding * 4
                                  : fixPadding,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 15.0,
                                  child: creditCardList[index].brand ==
                                              "visa" ||
                                          creditCardList[index].brand ==
                                              "mastercard"
                                      ? Image.asset(
                                          creditCardList[index].brand == "visa"
                                              ? 'images/visa.png'
                                              : 'images/master_card.png',
                                          fit: BoxFit.fitHeight)
                                      : Icon(
                                          Icons.credit_card,
                                          size: 15.0,
                                        ),
                                ),
                                widthSpace,
                                Text(
                                  '**** **** **** ${creditCardList[index].last4}',
                                  style: headingStyle,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: Provider.of<CreditCardData>(context)
                                    .isSelectedCard(
                                        creditCard: creditCardList[index])
                                ? Container(
                                    height: 30.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(30.0),
                                      ),
                                      color: primaryColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.check,
                                        color: whiteColor, size: 15.0),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : noCreditCardCard();
  }

  noCreditCardCard() {
    return Container(
      child: Card(
        color: Colors.pink.withOpacity(
          0.5,
        ),
        child: Container(
          height: 100.0,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.white,
              ),
              Text(
                "No tienes tarjetas guardadas.",
              ),
              Text(
                "Por favor agrega una tarjeta, para poder continuar y crear la orden.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool isOrderCreationSuccess({
  DocumentReference dailyOrder,
  DocumentReference normalOrder,
  int dailyLength,
  int normalLength,
}) {
  print({
    "dailyLength": dailyLength,
    "normalLength": normalLength,
    "daily != null": dailyOrder != null,
    "normal != null": normalOrder != null,
  });
  if (dailyLength > 0 && normalLength > 0) {
    return dailyOrder != null && normalOrder != null;
  } else if (dailyLength > 0 && normalLength == 0) {
    return dailyOrder != null && normalOrder == null;
  } else if (dailyLength == 0 && normalLength > 0) {
    return dailyOrder == null && normalOrder != null;
  } else {
    return false;
  }
}
