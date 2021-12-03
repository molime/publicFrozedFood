import 'package:e_shop/Models/address.dart';
import 'package:e_shop/Models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String uid;
  final String addressID;
  final AddressModel addressDetails;
  final DateTime deliveryDate;
  final bool isSuccess;
  final bool delivered;
  final bool sent;
  final String orderBy;
  final String orderTime;
  final String paymentDetails;
  final String paymentIntent;
  final String paymentMethod;
  final List<String> productIDs;
  final List<ItemModel> products;
  final List<ItemModel> dailyProducts;
  final double totalAmount;
  final String clientOrderUid;
  final double dailyTotalAmount;
  final double normalTotalAmount;
  final List<String> dailyProductIds;
  final String dailyOrderUid;

  Order({
    this.uid,
    this.addressID,
    this.addressDetails,
    this.totalAmount,
    this.orderBy,
    this.deliveryDate,
    this.isSuccess,
    this.delivered,
    this.sent,
    this.orderTime,
    this.paymentDetails,
    this.paymentIntent,
    this.paymentMethod,
    this.productIDs,
    this.products,
    this.dailyProducts,
    this.clientOrderUid,
    this.dailyOrderUid,
    this.dailyProductIds,
    this.dailyTotalAmount,
    this.normalTotalAmount,
  });

  factory Order.fromDocument({
    DocumentSnapshot doc,
  }) {
    print({
      "dailyTotalAmount.type":
          (doc.data() as Map)['dailyTotalAmount'].runtimeType,
    });
    Order order = Order(
      uid: doc.id != null ? doc.id : null,
      addressID: (doc.data() as Map)['addressID'] != null
          ? (doc.data() as Map)['addressID']
          : null,
      deliveryDate: (doc.data() as Map)['deliveryDate'] != null
          ? (doc.data() as Map)['deliveryDate'].toDate()
          : null,
      isSuccess: (doc.data() as Map)['isSuccess'] != null
          ? (doc.data() as Map)['isSuccess']
          : false,
      delivered: (doc.data() as Map)['delivered'] != null
          ? (doc.data() as Map)['delivered']
          : false,
      sent: (doc.data() as Map)['sent'] != null
          ? (doc.data() as Map)['sent']
          : false,
      orderBy: (doc.data() as Map)['orderBy'] != null
          ? (doc.data() as Map)['orderBy']
          : null,
      totalAmount: (doc.data() as Map)['totalAmount'] != null
          ? double.parse((doc.data() as Map)['totalAmount'].toString())
          : null,
      orderTime: (doc.data() as Map)['orderTime'] != null
          ? (doc.data() as Map)['orderTime']
          : null,
      paymentDetails: (doc.data() as Map)['paymentDetails'] != null
          ? (doc.data() as Map)['paymentDetails']
          : null,
      paymentMethod: (doc.data() as Map)['paymentMethod'] != null
          ? (doc.data() as Map)['paymentMethod']
          : null,
      paymentIntent: (doc.data() as Map)['paymentIntent'] != null
          ? (doc.data() as Map)['paymentIntent']
          : null,
      addressDetails: (doc.data() as Map)['addressDetails'] != null
          ? AddressModel.fromJson(
              (doc.data() as Map)['addressDetails'],
              uidReceived: (doc.data() as Map)['addressDetails']['uid'],
            )
          : null,
      productIDs: [],
      products: [],
      clientOrderUid: (doc.data() as Map)['clientOrderUid'] != null
          ? (doc.data() as Map)['clientOrderUid']
          : null,
      dailyProductIds: [],
      dailyProducts: [],
      dailyOrderUid: (doc.data() as Map)['dailyOrderUid'] != null
          ? (doc.data() as Map)['dailyOrderUid']
          : null,
      dailyTotalAmount: (doc.data() as Map)['dailyTotalAmount'] != null
          ? double.parse((doc.data() as Map)['dailyTotalAmount'].toString())
          : null,
      normalTotalAmount: (doc.data() as Map)['normalTotalAmount'] != null
          ? double.parse((doc.data() as Map)['normalTotalAmount'].toString())
          : null,
    );

    if ((doc.data() as Map)['productIDs'] != null) {
      for (String prodUid in (doc.data() as Map)['productIDs']) {
        order.productIDs.add(prodUid);
      }
    }

    if ((doc.data() as Map)['dailyProductIds'] != null) {
      for (String prodUid in (doc.data() as Map)['dailyProductIds']) {
        order.dailyProductIds.add(prodUid);
      }
    }

    if ((doc.data() as Map)['products'] != null) {
      for (Map product in (doc.data() as Map)['products']) {
        ItemModel itemModelAdd = ItemModel.fromJson(
          product,
          product['uid'],
        );
        order.products.add(itemModelAdd);
      }
    }

    if ((doc.data() as Map)['dailyProducts'] != null) {
      for (Map product in (doc.data() as Map)['dailyProducts']) {
        ItemModel itemModelAdd = ItemModel.fromJson(
          product,
          product['uid'],
        );
        order.dailyProducts.add(itemModelAdd);
      }
    }

    return order;
  }

  factory Order.fromMap({Map map}) {
    print({
      "dailyTotalAmount.type": map['dailyTotalAmount'].runtimeType,
    });
    Order order = Order(
      uid: map['id'] != null ? map['id'] : null,
      addressID: map['addressID'] != null ? map['addressID'] : null,
      deliveryDate:
          map['deliveryDate'] != null ? map['deliveryDate'].toDate() : null,
      isSuccess: map['isSuccess'] != null ? map['isSuccess'] : false,
      delivered: map['delivered'] != null ? map['delivered'] : false,
      sent: map['sent'] != null ? map['sent'] : false,
      orderBy: map['orderBy'] != null ? map['orderBy'] : null,
      totalAmount: map['totalAmount'] != null
          ? double.parse(map['totalAmount'].toString())
          : null,
      orderTime: map['orderTime'] != null ? map['orderTime'] : null,
      paymentDetails:
          map['paymentDetails'] != null ? map['paymentDetails'] : null,
      paymentMethod: map['paymentMethod'] != null ? map['paymentMethod'] : null,
      paymentIntent: map['paymentIntent'] != null ? map['paymentIntent'] : null,
      addressDetails: map['addressDetails'] != null
          ? AddressModel.fromJson(
              map['addressDetails'],
              uidReceived: map['addressDetails']['uid'],
            )
          : null,
      productIDs: [],
      products: [],
      clientOrderUid:
          map['clientOrderUid'] != null ? map['clientOrderUid'] : null,
      dailyProductIds: [],
      dailyProducts: [],
      dailyOrderUid: map['dailyOrderUid'] != null ? map['dailyOrderUid'] : null,
      dailyTotalAmount: map['dailyTotalAmount'] != null
          ? double.parse(map['dailyTotalAmount'].toString())
          : null,
      normalTotalAmount: map['normalTotalAmount'] != null
          ? double.parse(map['normalTotalAmount'].toString())
          : null,
    );

    if (map['productIDs'] != null) {
      for (String prodUid in map['productIDs']) {
        order.productIDs.add(prodUid);
      }
    }

    if (map['dailyProductIds'] != null) {
      for (String prodUid in map['dailyProductIds']) {
        order.dailyProductIds.add(prodUid);
      }
    }

    if (map['products'] != null) {
      for (Map product in map['products']) {
        ItemModel itemModelAdd = ItemModel.fromJson(
          product,
          product['uid'],
        );
        order.products.add(itemModelAdd);
      }
    }

    if (map['dailyProducts'] != null) {
      for (Map product in map['dailyProducts']) {
        ItemModel itemModelAdd = ItemModel.fromJson(
          product,
          product['uid'],
        );
        order.dailyProducts.add(itemModelAdd);
      }
    }

    return order;
  }

  int orderNumProducts() {
    int countProducts = 0;

    for (ItemModel itemModel in this.products) {
      countProducts += itemModel.countAdded;
    }

    for (ItemModel itemModel in this.dailyProducts) {
      countProducts += itemModel.countAdded;
    }

    return countProducts;
  }
}
