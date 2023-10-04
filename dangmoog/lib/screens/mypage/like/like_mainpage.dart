import 'package:dangmoog/screens/mypage/like/like_postlist.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_list_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

enum SortingOrder { ascending, descending }

class LikeMainPage extends StatefulWidget {
  const LikeMainPage({Key? key}) : super(key: key);

  @override
  State<LikeMainPage> createState() => _LikeMainPageState();
}

class _LikeMainPageState extends State<LikeMainPage> {
  late Future<List<ProductListModel>> futureProducts;
  SortingOrder sorting = SortingOrder.descending; // 정렬 순서 기본값
  bool sortByDealStatus = false;
  bool sortByDealStatus2 = false;
  bool sortByDealStatus3 = false;
  @override
  void initState() {
    super.initState();
    futureProducts = _loadProductsFromAsset();
  }

  Future<List<ProductListModel>> _loadProductsFromAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/mylike_products.json');
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
      sorting = SortingOrder.descending;
    });
  }

  List<ProductListModel> _sortProducts(List<ProductListModel> products) {
    List<ProductListModel> filteredProducts = products;
    if (sortByDealStatus) {
      filteredProducts =
          filteredProducts.where((product) => product.dealStatus == 2).toList();
    }
    if (sortByDealStatus2) {
      filteredProducts =
          filteredProducts.where((product) => product.dealStatus == 0).toList();
    }
    if (sortByDealStatus3) {
      filteredProducts =
          filteredProducts.where((product) => product.dealStatus == 1).toList();
    }

    // 필터링된 데이터를 정렬 순서에 따라 정렬한 후 반환
    if (sorting == SortingOrder.ascending) {
      return filteredProducts
        ..sort((a, b) => a.uploadTime.compareTo(b.uploadTime));
    } else {
      return filteredProducts
        ..sort((a, b) => b.uploadTime.compareTo(a.uploadTime));
    }
  }

  //거래완료
  void _toggleSortByDealStatus() {
    setState(() {
      sortByDealStatus = true;
      sortByDealStatus2 = false;
      sortByDealStatus3 = false;
    });
  }

  //거래중
  void _toggleSortByDealStatus2() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = true;
      sortByDealStatus3 = false;
    });
  }

  //예약중
  void _toggleSortByDealStatus3() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = false;
      sortByDealStatus3 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '관심목록',
        ),
        actions: [
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE20529)),
                borderRadius: BorderRadius.circular(6)),
            child: TextButton.icon(
              onPressed: () {
                _accountPopup(context);
              },
              label: Text(
                '최신순',
                style: TextStyle(color: Color(0xFFE20529)),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Color(0xFFE20529),
                size: 16,
              ),
            ),
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

            // 정렬된 데이터를 표시하도록 ProductList 위젯에 sortingOrder를 전달
            return ProductList(
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

  Future<void> _accountPopup(BuildContext context) async {
    final double popupWidth = 270;
    final double popupHeight = 186;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          content: Container(
            width: popupWidth, // 팝업의 가로 크기 설정
            height: popupHeight, // 팝업의 세로 크기 설정
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    // 버튼이 클릭되었을 때 실행될 코드
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(popupWidth, 36),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ), // 패딩 조정
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
                  width: popupWidth, // 선의 길이
                  height: 0.5, // 선의 두께
                  color: Colors.grey, // 선의 색상 (회색)
                ),
                // 나머지 버튼들 추가
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _accountPopup(BuildContext context) async {
  final double popupWidth = 270;
  final double popupHeight = 186;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        content: Container(
          width: popupWidth, // 팝업의 가로 크기 설정
          height: popupHeight, // 팝업의 세로 크기 설정
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  // "전체보기" 버튼이 클릭되었을 때 실행될 코드
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(popupWidth, 36),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ), // 패딩 조정
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
                width: popupWidth, // 선의 길이
                height: 0.5, // 선의 두께
                color: Colors.grey, // 선의 색상 (회색)
              ),
              TextButton(
                onPressed: () {
                  // "거래중" 버튼이 클릭되었을 때 실행될 코드
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(popupWidth, 36),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ), // 패딩 조정
                ),
                child: const Text(
                  '거래중',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE20529),
                  ),
                ),
              ),
              Container(
                width: popupWidth, // 선의 길이
                height: 0.5, // 선의 두께
                color: Colors.grey, // 선의 색상 (회색)
              ),
              TextButton(
                onPressed: () {
                  // "예약중" 버튼이 클릭되었을 때 실행될 코드
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(popupWidth, 36),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ), // 패딩 조정
                ),
                child: const Text(
                  '예약중',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE20529),
                  ),
                ),
              ),
              Container(
                width: popupWidth, // 선의 길이
                height: 0.5, // 선의 두께
                color: Colors.grey, // 선의 색상 (회색)
              ),
              TextButton(
                onPressed: () {
                  // "거래완료" 버튼이 클릭되었을 때 실행될 코드
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(popupWidth, 36),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ), // 패딩 조정
                ),
                child: const Text(
                  '거래완료',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE20529),
                  ),
                ),
              ),
              Container(
                width: popupWidth, // 선의 길이
                height: 0.5, // 선의 두께
                color: Colors.grey, // 선의 색상 (회색)
              ),
              TextButton(
                onPressed: () {
                  // "취소" 버튼이 클릭되었을 때 실행될 코드
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(popupWidth, 36),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ), // 패딩 조정
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA19E9E),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
