import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSummary extends StatefulWidget {
  final Order order;

  OrderSummary({
    Key key,
    this.order,
  }) : super(
          key: key,
        );

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Route route = MaterialPageRoute(
          builder: (context) => OrderDetails(
            orderId: widget.order.uid,
            order: widget.order,
          ),
        );
        Navigator.pushReplacement(
          context,
          route,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        elevation: 20.0,
        child: Container(
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
              Image.asset(
                'images/welcome.png',
                width: 140.0,
                height: 140.0,
              ),
              /*CachedNetworkImage(
                imageUrl: widget.order.,
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
                              "Fecha entrega: ${DateFormat("dd/MM/yyyy").format(
                                widget.order.deliveryDate,
                              )}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          /*SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            child: statusOrderSummary(
                              sent: widget.order.sent,
                              delivered: widget.order.delivered,
                            ),
                          ),*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: statusOrderSummary(
                              sent: widget.order.sent,
                              delivered: widget.order.delivered,
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
                              "Ordenado el: ${DateFormat("dd/MM/yyyy").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(
                                    widget.order.orderTime,
                                  ),
                                ),
                              )}",
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
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Número de artículos: ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${widget.order.orderNumProducts()}",
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
                                    widget.order.dailyProducts.length > 0 &&
                                            widget.order.dailyProducts != null
                                        ? "${widget.order.dailyTotalAmount}"
                                        : "${widget.order.normalTotalAmount}",
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
                    /*Flexible(
                      child: Container(),
                    ),
                    Divider(
                      height: 5.0,
                      color: Colors.pink,
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text statusOrderSummary({bool sent, bool delivered}) {
    if (!sent) {
      return Text(
        'Estatus de la órden: Por enviar',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      );
    } else if (sent && !delivered) {
      return Text(
        "Estatus de la órden: En camino",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      );
    } else {
      return Text(
        "Estatus de la órden: Entregada",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      );
    }
  }
}
