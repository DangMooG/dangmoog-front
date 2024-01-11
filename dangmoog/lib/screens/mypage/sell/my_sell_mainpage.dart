import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/mypage/my_post_list.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/widgets/sorting_toggle.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

//enum SortingOrder { ascending, descending }

class MySellMainPage extends StatefulWidget {
  const MySellMainPage({Key? key}) : super(key: key);

  @override
  State<MySellMainPage> createState() => _MySellMainPageState();
}

class _MySellMainPageState extends State<MySellMainPage> {
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
    futureProducts = _loadMySellProduct(context);
  }

  Future<List<ProductModel>> _loadMySellProduct(BuildContext context) async {
    String userNickname =
        Provider.of<UserProvider>(context, listen: false).nickname;

    final filters = {'username': userNickname};
    final response = await apiService.searchPosts(filters);
    if (response.statusCode == 200) {
      if (response.data is List) {
        List<dynamic> data = response.data as List;
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Data format from server is unexpected.');
      }
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
          '판매내역',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF302E2E)),
        ),
        actions: [
          FutureBuilder<List<ProductModel>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
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
            if (snapshot.hasError) {
              return const Center(
                child: Text('게시물을 불러오는데 실패했습니다.'),
              );
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              // 판매 목록이 없는 경우 메시지를 표시
              return const Center(
                child: Text('판매목록이 없습니다.'),
              );
            }

            // 정렬된 데이터를 표시하도록 ProductList 위젯에 sortingOrder를 전달
            return MyProductList(
              productList: _sortProducts(snapshot.data!),
              sortingOrder: sorting,
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
