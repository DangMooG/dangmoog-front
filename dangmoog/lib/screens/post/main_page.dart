// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_class.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Product> products = [
    // Here you can add your list of products. I'll add a few examples.
    Product(
      id: '1',
      title: '한국토종여우',
      category: '동물',
      uploadTime: DateTime(2),
      comments: '와 존나 힘들다',
      description: 'This is product 1',
      price: 29.99,
      imageUrl: 'assets/images/flickr_wild_000017.jpg',
      saleMethod: '위탁판매',
      user: '김동우',
    ),
    Product(
      id: '2',
      title: '하우스지박령',
      category: '괴물',
      uploadTime: DateTime(20),
      comments: '와 존나 힘들다',
      description: 'This is product 2',
      price: 39.99,
      imageUrl: 'assets/images/sample.png',
      saleMethod: '위탁판매',
      user: '김철희',
    ),
    Product(
      id: '2',
      title: 'Product 2',
      category: '여우',
      uploadTime: DateTime(20),
      comments: '와 존나 힘들다',
      description: 'This is product 2',
      price: 39.99,
      imageUrl: 'assets/images/flickr_wild_000017.jpg',
      saleMethod: '위탁판매',
      user: '배정윤',
    ),
    Product(
      id: '2',
      title: 'Product 2',
      category: '여우',
      uploadTime: DateTime(20),
      comments: '와 존나 힘들다',
      description: 'This is product 2',
      price: 39.99,
      imageUrl: 'assets/images/flickr_wild_000017.jpg',
      saleMethod: '위탁판매',
      user: '지유나',
    ),
    // Add more products here
  ];

  @override
  Widget build(BuildContext context) {
    return ProductList(products: products);
  }
}
