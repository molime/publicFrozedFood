import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Data/shopping_cart.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/address.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/wideButton.dart';
import 'package:e_shop/Counters/changeAddresss.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'addAddress.dart';

class AddressScreen extends StatefulWidget {
  final double totalAmount;

  AddressScreen({
    Key key,
    this.totalAmount,
  }) : super(
          key: key,
        );
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  AddressScreen address;
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
                builder: (context) => CartPage(),
              );
              Navigator.pushReplacement(context, route);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Route route = MaterialPageRoute(
              builder: (context) => AddAddress(
                isFromAddresses: true,
              ),
            );
            Navigator.pushReplacement(context, route);
          },
          label: Text(
            "Agregar nueva dirección",
          ),
          backgroundColor: Colors.pink,
          icon: Icon(
            Icons.add_location,
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: Provider.of<ShoppingCart>(context).addressSpinner,
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
                  child: Text(
                    "Seleccionar dirección",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Consumer<AddressChanger>(
                builder: (context, address, c) {
                  return Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: EcommerceApp.firestore
                          .collection(
                            EcommerceApp.collectionUser,
                          )
                          .doc(
                            EcommerceApp.sharedPreferences.getString(
                              EcommerceApp.userUID,
                            ),
                          )
                          .collection(
                            EcommerceApp.subCollectionAddress,
                          )
                          .snapshots(),
                      builder: (context, snapshot) {
                        return !snapshot.hasData
                            ? Center(
                                child: circularProgress(),
                              )
                            : snapshot.data.docs.length == 0
                                ? noAddressCard()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      print({
                                        'address': AddressModel.fromJson(
                                          snapshot.data.docs[index].data(),
                                          uidReceived:
                                              snapshot.data.docs[index].id,
                                        ),
                                      });
                                      print({
                                        'addressId':
                                            snapshot.data.docs[index].id,
                                      });
                                      return AddressCard(
                                        currentIndex: address.count,
                                        value: index,
                                        addressId: snapshot.data.docs[index].id,
                                        totalAmount: widget.totalAmount,
                                        model: AddressModel.fromJson(
                                          snapshot.data.docs[index].data(),
                                          uidReceived:
                                              snapshot.data.docs[index].id,
                                        ),
                                      );
                                    },
                                  );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
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
              Icons.add_location,
              color: Colors.white,
            ),
            Text(
              "No tienes direcciones guardadas.",
            ),
            Text(
              "Por favor agrega una dirección, para que podamos realizarte entregas.",
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final String addressId;
  final double totalAmount;
  final int currentIndex;
  final int value;

  AddressCard({
    Key key,
    this.value,
    this.totalAmount,
    this.model,
    this.addressId,
    this.currentIndex,
  }) : super(
          key: key,
        );
  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        print({
          'addressCard': widget.model.toJson(),
        });
        Provider.of<AddressChanger>(context, listen: false).displayResult(
          widget.value,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        elevation: 20.0,
        /*color: Colors.pinkAccent.withOpacity(
          0.4,
        ),*/
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  value: widget.value,
                  groupValue: widget.currentIndex,
                  activeColor: Colors.pink,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false)
                        .displayResult(
                      val,
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        10.0,
                      ),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Dirección calle",
                              ),
                              widget.model.subThroughFare != null
                                  ? Text(
                                      widget.model.thoroughfare +
                                          ' ' +
                                          widget.model.subThroughFare,
                                    )
                                  : Text(
                                      widget.model.thoroughfare,
                                    ),
                            ],
                          ),
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Ciudad",
                              ),
                              Text(
                                widget.model.locality,
                              ),
                            ],
                          ),
                          if (widget.model.subLocality != null) ...[
                            TableRow(
                              children: [
                                KeyText(
                                  msg: "Colonia",
                                ),
                                Text(
                                  widget.model.subLocality,
                                ),
                              ],
                            )
                          ],
                          TableRow(
                            children: [
                              KeyText(
                                msg: "País",
                              ),
                              Text(
                                widget.model.countryName,
                              ),
                            ],
                          ),
                          if (widget.model.postalCode != null) ...[
                            TableRow(
                              children: [
                                KeyText(
                                  msg: "Código Postal",
                                ),
                                Text(
                                  widget.model.postalCode,
                                ),
                              ],
                            ),
                          ],
                          if (widget.model.reference != null &&
                              widget.model.reference != "") ...[
                            TableRow(
                              children: [
                                KeyText(
                                  msg: "Referencia",
                                ),
                                Text(
                                  widget.model.reference,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
                ? WideButton(
                    message: "Proceder",
                    onPressed: () async {
                      if (widget.model.countryCode != null &&
                          widget.model.locality != null &&
                          widget.model.postalCode != null) {
                        Provider.of<ShoppingCart>(context, listen: false)
                            .setSpinner(
                          true,
                        );
                        QuerySnapshot query = await EcommerceApp.firestore
                            .collection("zipCodes")
                            .where(
                              'countryCode',
                              isEqualTo: widget.model.countryCode,
                            )
                            .where(
                              'locality',
                              isEqualTo: widget.model.locality,
                            )
                            .where(
                              'postalCode',
                              isEqualTo: widget.model.postalCode,
                            )
                            .get();
                        Provider.of<ShoppingCart>(context, listen: false)
                            .setSpinner(
                          false,
                        );
                        if (query != null && query.docs.length > 0) {
                          Provider.of<ShoppingCart>(context, listen: false)
                              .setSelectedAddress(
                            selectedAddress: widget.model,
                          );
                          Route route = MaterialPageRoute(
                            builder: (context) => PaymentPage(
                              addressId: widget.addressId,
                              totalAmount: widget.totalAmount,
                            ),
                          );
                          Navigator.push(context, route);
                        } else {
                          showDialog(
                            context: context,
                            builder: (c) {
                              return ErrorAlertDialog(
                                message:
                                    "No tenemos servicio en tu zona, lo sentimos.",
                              );
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (c) {
                            return ErrorAlertDialog(
                              message:
                                  "Tu dirección está incompleta, no te podemos dar servicio. Lo sentimos.",
                            );
                          },
                        );
                      }
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;

  KeyText({
    Key key,
    this.msg,
  }) : super(
          key: key,
        );
  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
