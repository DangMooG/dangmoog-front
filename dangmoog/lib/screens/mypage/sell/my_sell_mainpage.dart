import 'package:flutter/material.dart';
import 'package:dangmoog/screens/mypage/sell/my_sell_postlist.dart';
import 'package:dangmoog/models/product_list_model.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

enum SortingOrder { ascending, descending }

class MySellMainPage extends StatefulWidget {
  const MySellMainPage({Key? key}) : super(key: key);

  @override
  State<MySellMainPage> createState() => _MySellMainPageState();
}

class _MySellMainPageState extends State<MySellMainPage> {
  late Future<List<ProductListModel>> futureProducts;
  SortingOrder sortingOrder = SortingOrder.descending; // 정렬 순서 기본값
  bool sortByDealStatus = false;
  bool sortByDealStatus2 = false;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  Future<List<ProductListModel>> _loadProductsFromAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/mysell_products.json');
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

  void _toggleSortingOrder() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = false;
      sortingOrder = SortingOrder.descending;
    });
  }

  List<ProductListModel> _sortProducts(List<ProductListModel> products) {
    List<ProductListModel> filteredProducts = products;
    if (sortByDealStatus) {
      filteredProducts =
          filteredProducts.where((product) => product.dealStatus == 2).toList();
    }
    if (sortByDealStatus2) {
      filteredProducts = filteredProducts
          .where(
              (product) => product.dealStatus == 0 || product.dealStatus == 1)
          .toList();
    }

    // 필터링된 데이터를 정렬 순서에 따라 정렬한 후 반환
    if (sortingOrder == SortingOrder.ascending) {
      return filteredProducts
        ..sort((a, b) => a.uploadTime.compareTo(b.uploadTime));
    } else {
      return filteredProducts
        ..sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
    }
  }

  void _toggleSortByDealStatus() {
    setState(() {
      sortByDealStatus = true;
      sortByDealStatus2 = false;
    });
  }

  void _toggleSortByDealStatus2() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('판매내역'),
        actions: [
          TextButton(
            onPressed: () {
              _accountPopup(screenSize, context);
            },
            child: Text('최신순'),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductListModel>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('게시물을 불러오는데 실패했습니다.'),
              );
            }

            return ProductList(
              productList: _sortProducts(snapshot.data!),
              sortingOrder: sortingOrder,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _accountPopup(Size screenSize, BuildContext context) async {
    final double popupWidth = MediaQuery.of(context).size.width;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          actions: [
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    _toggleSortingOrder();
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(popupWidth, 36),
                    ),
                  ),
                  child: const Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFE20529),
                    ),
                  ),
                ),
                Container(
                  width: screenSize.width, // 선의 길이
                  height: 0.5, // 선의 두께
                  color: Colors.grey, // 선의 색상 (회색)
                ),
                TextButton(
                  onPressed: () {
                    _toggleSortByDealStatus2();
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(popupWidth, 36),
                    ),
                  ),
                  child: const Text(
                    '거래완료 제외',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFE20529),
                    ),
                  ),
                ),
                Container(
                  width: screenSize.width, // 선의 길이
                  height: 0.5, // 선의 두께
                  color: Colors.grey, // 선의 색상 (회색)
                ),
                TextButton(
                  onPressed: () {
                    _toggleSortByDealStatus();
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(popupWidth, 36),
                    ),
                  ),
                  child: const Text(
                    '거래완료만',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFE20529),
                    ),
                  ),
                ),
                Container(
                  width: screenSize.width, // 선의 길이
                  height: 0.5, // 선의 두께
                  color: Colors.grey, // 선의 색상 (회색)
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(popupWidth, 36),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFE20529),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
