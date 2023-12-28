import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/mypage/my_post_list.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PurchaseMainPage extends StatefulWidget {
  const PurchaseMainPage({Key? key}) : super(key: key);

  @override
  State<PurchaseMainPage> createState() => _PurchaseMainPageState();
}

class _PurchaseMainPageState extends State<PurchaseMainPage> {
  final ApiService apiService = ApiService();
  List<ProductModel>? products;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchaseProducts(context);
  }

  Future<void> _loadPurchaseProducts(BuildContext context) async {
    try {
      String userNickname =
          Provider.of<UserProvider>(context, listen: false).nickname;

      final filters = {"username": userNickname};
      final response = await apiService.searchPosts(filters);
      if (response.statusCode == 200) {
        if (response.data is List) {
          List<dynamic> data = response.data as List;
          setState(() {
            products = data.map((item) => ProductModel.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Data format from server is unexpected.');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        print(errorMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return const Center(
        child: Text('게시물을 불러오는데 실패했습니다.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '구매내역',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF302E2E)),
        ),
      ),
      body: MyProductList(productList: products!, sortingOrder: null),
    );
  }
}
