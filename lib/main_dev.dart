import 'package:e_shop/appConfig.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/main.dart';

void main() async {
  AppConfig devAppConfig = AppConfig(appName: 'CounterApp Dev', flavor: 'dev');
  Widget app = await mainBuild(devAppConfig);
  runApp(app);
}
