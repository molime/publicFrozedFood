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
      "dailyTotalAmount.type": doc.data()['dailyTotalAmount'].runtimeType,
    });
    Order order = Order(
      uid: doc.id != null ? doc.id : null,
      addressID:
          doc.data()['addressID'] != null ? doc.data()['addressID'] : null,
      deliveryDate: doc.data()['deliveryDate'] != null
          ? doc.data()['deliveryDate'].toDate()
          : null,
      isSuccess:
          doc.data()['isSuccess'] != null ? doc.data()['isSuccess'] : false,
      delivered:
          doc.data()['delivered'] != null ? doc.data()['delivered'] : false,
      sent: doc.data()['sent'] != null ? doc.data()['sent'] : false,
      orderBy: doc.data()['orderBy'] != null ? doc.data()['orderBy'] : null,
      totalAmount: doc.data()['totalAmount'] != null
          ? double.parse(doc.data()['totalAmount'].toString())
          : null,
      orderTime:
          doc.data()['orderTime'] != null ? doc.data()['orderTime'] : null,
      paymentDetails: doc.data()['paymentDetails'] != null
          ? doc.data()['paymentDetails']
          : null,
      paymentMethod: doc.data()['paymentMethod'] != null
          ? doc.data()['paymentMethod']
          : null,
      paymentIntent: doc.data()['paymentIntent'] != null
          ? doc.data()['paymentIntent']
          : null,
      addressDetails: doc.data()['addressDetails'] != null
          ? AddressModel.fromJson(
              doc.data()['addressDetails'],
              uidReceived: doc.data()['addressDetails']['uid'],
            )
          : null,
      productIDs: [],
      products: [],
      clientOrderUid: doc.data()['clientOrderUid'] != null
          ? doc.data()['clientOrderUid']
          : null,
      dailyProductIds: [],
      dailyProducts: [],
      dailyOrderUid: doc.data()['dailyOrderUid'] != null
          ? doc.data()['dailyOrderUid']
          : null,
      dailyTotalAmount: doc.data()['dailyTotalAmount'] != null
          ? double.parse(doc.data()['dailyTotalAmount'].toString())
          : null,
      normalTotalAmount: doc.data()['normalTotalAmount'] != null
          ? double.parse(doc.data()['normalTotalAmount'].toString())
          : null,
    );

    if (doc.data()['productIDs'] != null) {
      for (String prodUid in doc.data()['productIDs']) {
        order.productIDs.add(prodUid);
      }
    }

    if (doc.data()['dailyProductIds'] != null) {
      for (String prodUid in doc.data()['dailyProductIds']) {
        order.dailyProductIds.add(prodUid);
      }
    }

    if (doc.data()['products'] != null) {
      for (Map product in doc.data()['products']) {
        ItemModel itemModelAdd = ItemModel.fromJson(
          product,
          product['uid'],
        );
        order.products.add(itemModelAdd);
      }
    }

    if (doc.data()['dailyProducts'] != null) {
      for (Map product in doc.data()['dailyProducts']) {
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
