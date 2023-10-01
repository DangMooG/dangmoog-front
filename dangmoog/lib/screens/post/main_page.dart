// /screens/main_page.dart
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/models/product_class.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<ProductModel>> _loadProductsFromAsset() async {

  final String jsonString = await rootBundle.loadString('assets/products.json');
  final List<dynamic> jsonResponse = json.decode(jsonString);

  return jsonResponse
      .map((productData) => ProductModel(
            postId: productData['postId'],
            title: productData['title'],
            category: productData['category'],
            description: productData['description'],
            uploadTime: DateTime.parse(productData['uploadTime']),
            price: productData['price'],
            images: List<String>.from(productData['images']),
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
  late Future<List<ProductModel>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print(snapshot.error);
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
