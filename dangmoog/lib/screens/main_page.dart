// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/models/user_class.dart';


class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Product> products = [
    // Here you can add your list of products. I'll add a few examples.
    Product(
      id: '1',
      title: 'Product 1',
      description: 'This is product 1',
      price: 29.99,
      imageUrl:
          'assets/flickr_wild_000017.jpg',
    ),
    Product(
      id: '2',
      title: 'Product 2',
      description: 'This is product 2',
      price: 39.99,
      imageUrl:
          'assets/flickr_wild_000017.jpg',
    ),
    // Add more products here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DangMooG'),
      ),
      body: ProductList(products: products),
    );
  }
}


