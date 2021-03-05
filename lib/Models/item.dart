import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';

class ItemModel {
  String title;
  String shortInfo;
  Timestamp publishedDate;
  String thumbnailUrl;
  String longDescription;
  String status;
  int price;
  int discount;
  String centro;
  List<String> categories;
  List<String> searchTerms;
  List<Map> options;
  List<Map> sopas;
  List<Map> entremeses;
  List<Map> postres;
  List<Map> optionsDaily;
  int disponibilidad;
  DateTime dayAvailable;
  bool isDaily;
  String uid;
  int countAdded;

  ItemModel({
    this.title,
    this.shortInfo,
    this.publishedDate,
    this.thumbnailUrl,
    this.longDescription,
    this.status,
    this.discount,
    this.centro,
    this.categories,
    this.options,
    this.uid,
    this.price,
    this.countAdded,
    this.searchTerms,
    this.disponibilidad,
    this.isDaily,
    this.postres,
    this.entremeses,
    this.sopas,
    this.optionsDaily,
    this.dayAvailable,
  });

  ItemModel.fromJson(Map<String, dynamic> json, String id) {
    List<String> catsList = [];
    List<Map> optionsAdd = [];
    List<String> termsAdd = [];
    List<Map> sopasAdd = [];
    List<Map> entremesesAdd = [];
    List<Map> postresAdd = [];
    List<Map> optionsDailyAdd = [];

    for (String cat in json['categories']) {
      catsList.add(cat);
    }

    for (String term in json['searchTerms']) {
      termsAdd.add(term);
    }

    if (json['options'] != null) {
      for (dynamic docOption in json['options']) {
        Map mapOption = {
          'name': docOption['name'],
          'price': docOption['price'],
          'qty': docOption['qty'],
          'qtyUnit': docOption['qtyUnit'],
          'optionNumber': docOption['optionNumber'],
        };
        optionsAdd.add(mapOption);
      }
    }

    if (json['optionsDaily'] != null) {
      for (dynamic docOption in json['optionsDaily']) {
        Map mapOption = {
          'optionNumber': docOption['optionNumber'],
          'name': docOption['name'],
          'price': docOption['price'],
        };
        optionsDailyAdd.add(mapOption);
      }
    }

    if (json['sopas'] != null) {
      for (dynamic docOption in json['sopas']) {
        Map mapOption = {
          'optionNumber': docOption['optionNumber'],
          'name': docOption['name'],
        };
        sopasAdd.add(mapOption);
      }
    }

    if (json['entremeses'] != null) {
      for (dynamic docOption in json['entremeses']) {
        Map mapOption = {
          'optionNumber': docOption['optionNumber'],
          'name': docOption['name'],
        };
        entremesesAdd.add(mapOption);
      }
    }

    if (json['postres'] != null) {
      for (dynamic docOption in json['postres']) {
        Map mapOption = {
          'optionNumber': docOption['optionNumber'],
          'name': docOption['name'],
        };
        postresAdd.add(mapOption);
      }
    }

    title = json['title'];
    shortInfo = json['shortInfo'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    price = json['price'];
    discount = json['discount'];
    centro = json['centro'];
    categories = catsList;
    options = optionsAdd;
    uid = id;
    countAdded = json['countAdded'] == null || json['countAdded'] == 0
        ? 0
        : json['countAdded'];
    searchTerms = termsAdd;
    disponibilidad =
        json['disponibilidad'] != null ? json['disponibilidad'] : null;
    isDaily = json['isDaily'] != null ? json['isDaily'] : false;
    postres = postresAdd;
    entremeses = entremesesAdd;
    sopas = sopasAdd;
    optionsDaily = optionsDailyAdd;
    dayAvailable =
        json['dayAvailable'] != null ? json['dayAvailable'].toDate() : null;
  }

  factory ItemModel.fromItem({
    ItemModel itemModelReplicate,
    List<Map> optionsAdd,
    int count,
    List<Map> optionsDailyAdd,
    List<Map> sopasAdd,
    List<Map> entremesAdd,
    List<Map> postreAdd,
  }) {
    return ItemModel(
      title: itemModelReplicate.title,
      shortInfo: itemModelReplicate.shortInfo,
      publishedDate: itemModelReplicate.publishedDate,
      thumbnailUrl: itemModelReplicate.thumbnailUrl,
      longDescription: itemModelReplicate.longDescription,
      status: itemModelReplicate.status,
      price: itemModelReplicate.price,
      discount: itemModelReplicate.discount,
      centro: itemModelReplicate.centro,
      categories: itemModelReplicate.categories,
      options: optionsAdd,
      uid: itemModelReplicate.uid,
      countAdded: count,
      searchTerms: itemModelReplicate.searchTerms,
      disponibilidad: itemModelReplicate.disponibilidad,
      isDaily: itemModelReplicate.isDaily,
      sopas: sopasAdd,
      entremeses: entremesAdd,
      postres: postreAdd,
      optionsDaily: optionsDailyAdd,
      dayAvailable: itemModelReplicate.dayAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['shortInfo'] = this.shortInfo;
    data['price'] = this.price;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['longDescription'] = this.longDescription;
    data['status'] = this.status;
    data['discount'] = this.discount;
    data['centro'] = this.centro;
    data['categories'] = this.categories;
    data['options'] = this.options;
    data['uid'] = this.uid;
    data['countAdded'] = this.countAdded;
    data['searchTerms'] = this.searchTerms;
    data['disponibilidad'] = this.disponibilidad;
    data['isDaily'] = this.isDaily;
    data['sopas'] = this.sopas;
    data['entremeses'] = this.entremeses;
    data['postres'] = this.postres;
    data['optionsDaily'] = this.optionsDaily;
    data['dayAvailable'] = this.dayAvailable;
    return data;
  }

  void setCount({int count}) {
    this.countAdded = count;
  }

  void addToCount({int count}) {
    this.countAdded += count;
  }

  void addCount() {
    this.countAdded++;
  }

  void decreaseCount() {
    this.countAdded--;
  }

  double getItemTotal() {
    double totalAmount = 0.0;
    double realPrice = discountedPrice(
      price: this.price,
      discount: this.discount,
    );
    for (Map option in this.options) {
      realPrice += option["price"];
    }
    double totalPrice = realPrice * this.countAdded;
    totalAmount += totalPrice;
    return totalAmount;
  }

  double getItemDailyTotal() {
    double totalAmount = 0.0;
    double realPrice = discountedPrice(
      price: this.price,
      discount: this.discount,
    );
    for (Map option in this.optionsDaily) {
      realPrice += option["price"];
    }
    double totalPrice = realPrice * this.countAdded;
    totalAmount += totalPrice;
    return totalAmount;
  }

  bool isSameDate({DateTime dateTime}) {
    if (dayAvailable == null) {
      return false;
    } else {
      return dateTime.year == dayAvailable.year &&
          dateTime.month == dayAvailable.month &&
          dateTime.day == dayAvailable.day;
    }
  }

//dateAvailable
  Future<void> updateDisponibilidad() async {
    print("updating one disponibilidad");
    DocumentSnapshot doc =
        await EcommerceApp.firestore.collection("dailyMenus").doc(uid).get();
    if (doc != null) {
      if (doc.data()["disponibilidad"] != null) {
        await EcommerceApp.firestore.collection("dailyMenus").doc(uid).update({
          "disponibilidad": doc.data()["disponibilidad"] - countAdded,
        });
        disponibilidad = doc.data()["disponibilidad"] - countAdded;
      }
    }
  }
}

class PublishedDate {
  String date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
