import 'package:e_shop/appConfig.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/main.dart';

void main() async {
  AppConfig devAppConfig =
      AppConfig(appName: 'CounterApp Prod', flavor: 'prod');
  Widget app = await mainBuild(devAppConfig);
  runApp(app);
}
