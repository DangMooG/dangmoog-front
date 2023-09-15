import 'package:flutter/material.dart';

import 'package:dangmoog/themes/main_theme.dart';

import 'package:dangmoog/screens/auth/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dotorit',
      debugShowCheckedModeBanner: false,
      theme: mainThemeData(),
      home: const SplashScreen(),
    );
  }
}
