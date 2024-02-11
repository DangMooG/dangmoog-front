import 'package:dangmoog/models/product_class.dart';

import 'package:dangmoog/screens/mypage/my_post_list.dart';
import 'package:dangmoog/widgets/sorting_toggle.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/services/api.dart';

class LikeMainPage extends StatefulWidget {
  const LikeMainPage({Key? key}) : super(key: key);

  @override
  State<LikeMainPage> createState() => _LikeMainPageState();
}

class _LikeMainPageState extends State<LikeMainPage> {
  late Future<List<ProductModel>> futureProducts;

  final ApiService apiService = ApiService();

  SortingOrder sorting = SortingOrder.descending;
  bool sortByDealStatus = false;
  bool sortByDealStatus2 = false;
  bool sortByDealStatus3 = false;
  // bool like = false;
  int index = 0;

  @override
  void initState() {
    super.initState();
    futureProducts = _loadLikedProducts();
  }

  // 관심목록을 새로고침 액션을 통해 업데이트하기 위한 함수
  void reloadLikedProducts() {
    setState(() {
      futureProducts = _loadLikedProducts();
    });
  }

  // 좋아요한 게시글의 정보들을 리스트 형식으로 반환
  Future<List<ProductModel>> _loadLikedProducts() async {
    Response response = await apiService.getLikePostList();
    if (response.statusCode == 200) {
      // 200 response 형식 {"liked_id": int, "account_id":int, "post_id":int}
      List<dynamic> data = response.data;

      // postId만 추출하여 저장
      List<int> productIds = [];
      for (var item in data) {
        int productId = item['post_id'] as int;
        productIds.add(productId);
      }

      List<ProductModel> productList = [];

      // 각 상품 ID에 대한 정보를 가져와서 productList에 추가
      for (int productId in productIds) {
        Response responseProduct = await apiService.loadProduct(productId);
        Map<String, dynamic> productData =
            responseProduct.data as Map<String, dynamic>;

        // 가져온 데이터를 ProductModel로 변환하여 productList에 추가
        ProductModel product = ProductModel.fromJson(productData);
        productList.add(product);
      }

      return productList;
    } else {
      throw Exception('Failed to load products');
    }
  }

  List<ProductModel> _sortProducts(List<ProductModel> products) {
    List<ProductModel> filteredProducts = List<ProductModel>.from(products);

    // if (like) {
    //   filteredProducts = filteredProducts
    //       .where((product) => product.isFavorited == true)
    //       .toList();
    // }
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
          '관심목록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF302E2E),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
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
                  productList: snapshot.data ?? [],
                  sortingOrder: sorting,
                  onSortingChanged: (newSorting) {
                    setState(() {
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
                return const SizedBox.shrink();
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
              return RefreshIndicator(
                onRefresh: () async {
                  reloadLikedProducts();
                },
                child: Center(
                    child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(child: Text('게시물을 불러오는데 실패했습니다.')),
                  ),
                )),
              );
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  reloadLikedProducts();
                },
                child: Center(
                    child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(child: Text('관심목록이 없습니다.')),
                  ),
                )),
              );
            }

            // 정렬된 데이터를 표시하도록 ProductList 위젯에 sortingOrder를 전달
            return MyProductList(
              productList: _sortProducts(snapshot.data!),
              sortingOrder: sorting,
              reloadProductList: reloadLikedProducts,
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
