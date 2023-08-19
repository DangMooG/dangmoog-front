// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_class.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Product>> _loadProductsFromAsset() async {
  final String jsonString = await rootBundle.loadString('assets/products.json');
  final List<dynamic> jsonResponse = json.decode(jsonString);

  return jsonResponse.map((productData) => Product(
    id: productData['id'],
    title: productData['title'],
    description: productData['description'],
    price: productData['price'].toDouble(),
    images: List<String>.from(productData['images']),
    category: productData['category'],
    uploadTime: DateTime.parse(productData['uploadTime']),
    saleMethod: productData['saleMethod'],
    user: productData['user'],
  )).toList();
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading products!'));
          }

          return ProductList(products: snapshot.data!);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

