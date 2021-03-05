import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map> createPaymentMethod({
  @required String customer,
  @required String number,
  @required int expMonth,
  @required int expYear,
  @required String cvc,
}) async {
  String chargeUrl =
      'https://us-central1-restaurantes-223b1.cloudfunctions.net/stripeCreatePaymentMethod';

  var body = json.encode({
    'customer': customer,
    'number': number,
    'expMonth': expMonth,
    'expYear': expYear,
    'cvc': cvc,
  });
  http.Response response;

  try {
    response = await http.post(
      chargeUrl,
      body: body,
      headers: {
        "content-type": 'text/plain',
      },
    );
  } catch (err) {
    print(err.toString());
    return null;
  }

  dynamic responseBody = json.decode(response.body);

  if (response.statusCode == 200) {
    DocumentReference documentReference = await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .doc(
          EcommerceApp.sharedPreferences.getString(
            EcommerceApp.userUID,
          ),
        )
        .collection(EcommerceApp.subCollectionPaymentMethods)
        .add({
      "id": responseBody["id"],
    });

    if (documentReference != null) {
      return responseBody;
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<List<dynamic>> getCustomerCards() async {
  String chargeUrl =
      "https://us-central1-restaurantes-223b1.cloudfunctions.net/getCustomerCards";

  var body = json.encode({
    'customerId':
        EcommerceApp.sharedPreferences.getString(EcommerceApp.userStripeId),
  });
  http.Response response;

  try {
    response = await http.post(
      chargeUrl,
      body: body,
      headers: {
        "content-type": 'text/plain',
      },
    );
  } catch (err) {
    print(err.toString());
    return null;
  }

  dynamic responseBody = json.decode(response.body);

  if (response.statusCode == 200) {
    return responseBody["data"];
  } else {
    return null;
  }
}

Future<Map> processPayment({
  double amount,
  String customerId,
  String paymentMethod,
  String email,
}) async {
  String chargeUrl =
      "https://us-central1-restaurantes-223b1.cloudfunctions.net/createPaymentIntent";

  var body = json.encode({
    'customerId': customerId,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'email': email,
  });
  http.Response response;

  try {
    response = await http.post(
      chargeUrl,
      body: body,
      headers: {
        "content-type": 'text/plain',
      },
    );
  } catch (err) {
    print(err.toString());
    return null;
  }

  dynamic responseBody = json.decode(response.body);

  if (response.statusCode == 200) {
    return responseBody;
  } else {
    return null;
  }
}

Future<Map> createRefund({String paymentIntentId}) async {
  String chargeUrl =
      "https://us-central1-restaurantes-223b1.cloudfunctions.net/stripeRefundCreate";

  var body = json.encode({
    'paymentIntentId': paymentIntentId,
  });
  http.Response response;

  try {
    response = await http.post(
      chargeUrl,
      body: body,
      headers: {
        "content-type": 'text/plain',
      },
    );
  } catch (err) {
    print(err.toString());
    return null;
  }

  dynamic responseBody = json.decode(response.body);

  if (response.statusCode == 200) {
    return responseBody;
  } else {
    return null;
  }
}

Future<Map> getOneCard({String cardId}) async {
  String chargeUrl =
      "https://us-central1-restaurantes-223b1.cloudfunctions.net/getCustomerSingleCard";

  var body = json.encode({
    'paymentMethod': cardId,
  });
  http.Response response;

  try {
    response = await http.post(
      chargeUrl,
      body: body,
      headers: {
        "content-type": 'text/plain',
      },
    );
  } catch (err) {
    print(err.toString());
    return null;
  }

  dynamic responseBody = json.decode(response.body);

  if (response.statusCode == 200) {
    return responseBody;
  } else {
    return null;
  }
}
