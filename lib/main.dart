import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foka_hub_build/screens/home_screen.dart';
import 'package:foka_hub_build/screens/ths_monitor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final String clientId = Random().nextInt(100000000).toString();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        THSMonitor.id: (context) => const THSMonitor(),
      },
    );
  }
}
