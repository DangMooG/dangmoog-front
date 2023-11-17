// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_class.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProductList(),
    );
  }
}
