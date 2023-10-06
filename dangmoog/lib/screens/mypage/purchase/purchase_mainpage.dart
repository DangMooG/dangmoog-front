import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/mypage/purchase/purchase_postlist.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<ProductModel>> _loadProductsFromAsset() async {
  final String jsonString =
      await rootBundle.loadString('assets/mypurchase_products.json');
  final List<dynamic> jsonResponse = json.decode(jsonString);

  return jsonResponse
      .map((productData) => ProductModel(
            postId: productData['postId'],
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            images: List<String>.from(productData['images']),
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

class PurchaseMainPage extends StatefulWidget {
  const PurchaseMainPage({Key? key}) : super(key: key);

  @override
  State<PurchaseMainPage> createState() => _PurchaseMainPageState();
}

class _PurchaseMainPageState extends State<PurchaseMainPage> {
  late Future<List<ProductModel>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '구매내역',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF302E2E)),
        ),
        actions: const [],
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('게시물을 불러오는데 실패했습니다.'),
              );
            }

            // 정렬된 데이터를 표시하도록 ProductList 위젯에 sortingOrder를 전달
            return ProductList(productList: snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
