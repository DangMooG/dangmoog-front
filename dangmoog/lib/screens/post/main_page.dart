// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_list_model.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<ProductListModel>> _loadProductsFromAsset() async {
  final String jsonString = await rootBundle.loadString('assets/products.json');
  final List<dynamic> jsonResponse = json.decode(jsonString);

  return jsonResponse
      .map((productData) => ProductListModel(
            postId: productData['postId'],
            title: productData['title'],
            price: productData['price'],
            image: productData['image'],
            category: productData['category'],
            uploadTime: DateTime.parse(productData['uploadTime']),
            saleMethod: productData['saleMethod'],
            userName: productData['userName'],
            dealStatus: productData['dealStatus'],
            viewCount: productData['viewCount'],
            chatCount: productData['chatCount'],
            likeCount: productData['likeCount'],
            isFavorited: productData['isFavorited'],
          ))
      .toList();
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<ProductListModel>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductListModel>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('게시물을 불러오는데 실패했습니다.'),
            );
          }

          return ProductList(productList: snapshot.data!);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
