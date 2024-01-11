import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/mypage/my_post_list.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

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

  Future<List<ProductModel>> _loadPurchaseProducts(BuildContext context) async {
    String userNickname =
        Provider.of<UserProvider>(context, listen: false).nickname;

    final filters = {'username': userNickname};
    Response response = await apiService.loadPurchase(filters);
    if (response.statusCode == 200) {
      if (response.data is Map<String, dynamic>) {
        Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('result') &&
            responseData['result'] is List<dynamic>) {
          List<dynamic> data = responseData['result'];

          List<int> productIds = [];

          for (var item in data) {
            if (item is int) {
              productIds.add(item);
            } else {
              throw Exception('Data format from server is unexpected.');
            }
          }
          print(productIds);

          List<ProductModel> productList = [];

          for (int productId in productIds) {
            Response responseProduct = await apiService.loadProduct(productId);
            Map<String, dynamic> productData =
                responseProduct.data as Map<String, dynamic>;

            ProductModel product = ProductModel.fromJson(productData);
            productList.add(product);
          }

          setState(() {
            isLoading = false;
            products = productList;
          });

          return productList;
        } else {
          throw Exception('Data format from server is unexpected.');
        }
      } else {
        throw Exception('Data format from server is unexpected.');
      }
    } else {
      throw Exception('Failed to load products');
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(
            color: Color(0xFFBEBCBC),
            height: 1,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
        ),
      ),
      body: products != null && products!.isNotEmpty
          ? MyProductList(productList: products!, sortingOrder: null)
          : const Center(
              child: Text('구매한 게시물이 없어요.'),
            ),
    );
  }
}
