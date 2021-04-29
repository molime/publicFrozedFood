import 'dart:async';

import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class PushNotificationsProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _messagesStreamController = StreamController<Map>.broadcast();

  Stream<Map> get messagesStream => _messagesStreamController.stream;

  static Future<dynamic> onBackgroundMessage(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  initNotifications() async {
    await _firebaseMessaging.requestNotificationPermissions();
    final token = await _firebaseMessaging.getToken();

    print('====FCM Token====');
    print(token);

    _firebaseMessaging.configure(
      onMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print('====onMessage====');
    print('message $message');

    final Map argumento = message['data'] ?? {};
    _messagesStreamController.sink.add(argumento);
    Fluttertoast.showToast(msg: argumento['message']);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print('====onLaunch====');
    print('message $message');

    final Map argumento = message['data'] ?? {};
    _messagesStreamController.sink.add(argumento);
    if (argumento['order'] != null) {
      Order order = Order.fromMap(map: argumento['order']);
      navigatorKey.currentState
          .pushReplacementNamed(OrderDetails.id, arguments: {
        'orderId': order.uid,
        'order': order,
      });
    }
  }

  Future<dynamic> onResume(Map<String, dynamic> message) async {
    print('====onResume====');
    print('message $message');

    final Map argumento = message['data'] ?? {};
    _messagesStreamController.sink.add(argumento);
    if (argumento['order'] != null) {
      Order order = Order.fromMap(map: argumento['order']);
      navigatorKey.currentState
          .pushReplacementNamed(OrderDetails.id, arguments: {
        'orderId': order.uid,
        'order': order,
      });
    }
  }

  dispose() {
    _messagesStreamController?.close();
  }
}
