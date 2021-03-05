import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/Config/config.dart';
import 'package:flutter/services.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/orderCard.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
            ),
            onPressed: () {
              Route route = MaterialPageRoute(
                builder: (context) => StoreHome(),
              );
              Navigator.pushReplacement(
                context,
                route,
              );
            },
          ),
          flexibleSpace: Container(
            decoration: new BoxDecoration(
              color: Colors.lightGreenAccent,
            ),
          ),
          centerTitle: true,
          title: Text(
            "Mis órdenes",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          /*actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],*/
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: EcommerceApp.firestore
              /*.collection(
                EcommerceApp.collectionUser,
              )
              .doc(
                EcommerceApp.sharedPreferences.getString(
                  EcommerceApp.userUID,
                ),
              )*/
              .collection(
                EcommerceApp.collectionOrders,
              )
              .where(
                "orderBy",
                isEqualTo: EcommerceApp.sharedPreferences.getString(
                  EcommerceApp.userUID,
                ),
              )
              .snapshots(),
          builder: (c, snapshot) {
            return snapshot.hasData
                ? snapshot.data.docs.length > 0
                    ? ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return OrderSummary(
                            order: Order.fromDocument(
                              doc: snapshot.data.docs[index],
                            ),
                          );
                          /*return OrderCard(
                            order: Order.fromDocument(
                              doc: snapshot.data.docs[index],
                            ),
                          );*/
                        },
                      )
                    : CustomScrollView(
                        slivers: [
                          beginOrdering(),
                        ],
                      )
                : Center(
                    child: circularProgress(),
                  );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter beginOrdering() {
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
                "No tienes órdenes",
              ),
              Text(
                "Haz tu primer pedido",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
