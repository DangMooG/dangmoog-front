import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/providers/user_provider.dart';
import 'package:dangmoog/screens/mypage/my_post_list.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/widgets/sorting_toggle.dart';
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
  late Future<List<ProductModel>> futureProducts;
  List<ProductModel>? products;
  SortingOrder sorting = SortingOrder.descending; // 정렬 순서 기본값
  bool sortByDealStatus = false;
  bool sortByDealStatus2 = false;
  bool sortByDealStatus3 = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadPurchaseProducts();
  }

  Future<List<ProductModel>> _loadPurchaseProducts() async {
    final response = await ApiService().loadPurchase();

    if (response.statusCode == 200) {
      List<dynamic> data = response.data["result"] as List;

      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  List<ProductModel> _sortProducts(List<ProductModel> products) {
    List<ProductModel> filteredProducts = products;
    if (sortByDealStatus) {
      filteredProducts =
          filteredProducts.where((product) => product.status == 2).toList();
    }
    if (sortByDealStatus2) {
      filteredProducts =
          filteredProducts.where((product) => product.status == 0).toList();
    }
    if (sortByDealStatus3) {
      filteredProducts =
          filteredProducts.where((product) => product.status == 1).toList();
    }

    // 필터링된 데이터를 정렬 순서에 따라 정렬한 후 반환
    if (sorting == SortingOrder.ascending) {
      return filteredProducts
        ..sort((a, b) => a.createTime.compareTo(b.createTime));
    } else {
      return filteredProducts
        ..sort((a, b) => b.createTime.compareTo(a.createTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '구매목록',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF302E2E)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          FutureBuilder<List<ProductModel>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('게시물을 불러오는데 실패했습니다.'),
                  );
                }

                return ProductListSorting(
                  productList: snapshot.data ?? [], // 받은 데이터를 전달
                  sortingOrder: sorting,
                  onSortingChanged: (newSorting) {
                    setState(() {
                      // ProductListSorting에서 전달된 sorting 값을 업데이트
                      sorting = newSorting;
                    });
                  },
                  onSorting1Changed:
                      (newsortState1, newsortState2, newsortState3) {
                    setState(() {
                      sortByDealStatus = newsortState1;
                      sortByDealStatus2 = newsortState2;
                      sortByDealStatus3 = newsortState3;
                    });
                  },
                );
              } else {
                return const Center(child: SizedBox.shrink());
              }
            },
          ),
        ],
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
      body: FutureBuilder<List<ProductModel>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              // 구매 목록이 없는 경우 메시지를 표시
              return const Center(
                child: Text('구매목록이 없습니다.'),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('게시물을 불러오는데 실패했습니다.'),
              );
            }

            // 정렬된 데이터를 표시하도록 ProductList 위젯에 sortingOrder를 전달
            return MyProductList(
              productList: _sortProducts(snapshot.data!),
              sortingOrder: sorting,
              reloadProductList: () {},
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class CustomTextButtonWithBorder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const CustomTextButtonWithBorder({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // 원하는 색상 설정
            width: 0.5, // 라인 두께 설정
          ),
        ),
      ),
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(
            Size(375, height), // 크기를 원하는대로 설정
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE20529),
          ),
        ),
      ),
    );
  }
}
