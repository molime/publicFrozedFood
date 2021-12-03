import 'dart:async';
import 'dart:io';

import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Models/order.dart';
import 'package:e_shop/Orders/OrderDetailsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//TODO: configure ios notifications

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class PushNotificationsProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messagesStreamController = StreamController<Map>.broadcast();

  Stream<Map> get messagesStream => _messagesStreamController.stream;

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> onBackgroundMessage(Map<String, dynamic> message) async {
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
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();

    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.notificationsToken, token);

    print('====FCM Token====');
    print(token);
    FirebaseMessaging.onMessage.listen((event) async {
      await onMessage(event.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      await onLaunch(event.data);
    });

    FirebaseMessaging.onBackgroundMessage((message) async {
      await Firebase.initializeApp();
    });

    RemoteMessage initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      await onResume(initialMessage.data);
    }
    /* _firebaseMessaging.configure(
      onMessage: onMessage,
      onBackgroundMessage:
          Platform.isIOS ? null : PushNotificationsProvider.onBackgroundMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );*/
  }

  Future<dynamic> onMessage(Map<String, dynamic> message) async {
    print('====onMessage====');
    print('message $message');

    Map argumento = {};
    if (Platform.isAndroid) {
      argumento = message['data'] ?? {};
    } else {
      argumento = message ?? {};
    }
    _messagesStreamController.sink.add(argumento);
    Fluttertoast.showToast(msg: argumento['message']);
  }

  Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print('====onLaunch====');
    print('message $message');

    Map argumento = {};
    if (Platform.isAndroid) {
      argumento = message['data'] ?? {};
    } else {
      argumento = message ?? {};
    }
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

    Map argumento = {};
    if (Platform.isAndroid) {
      argumento = message['data'] ?? {};
    } else {
      argumento = message ?? {};
    }
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
