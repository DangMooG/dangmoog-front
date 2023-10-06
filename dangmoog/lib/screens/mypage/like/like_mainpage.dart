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
  bool like = false;
  int index = 0;
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
      like = true;
      sortByDealStatus = false;
      sortByDealStatus2 = false;
      sortByDealStatus3 = false;
    });
  }

  List<ProductListModel> _sortProducts(List<ProductListModel> products) {
    List<ProductListModel> filteredProducts =
        List<ProductListModel>.from(products);

    if (like) {
      filteredProducts = filteredProducts
          .where((product) => product.isFavorited == true)
          .toList();
    }
    if (sortByDealStatus) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.isFavorited == true && product.dealStatus == 2)
          .toList();
    }
    if (sortByDealStatus2) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.isFavorited == true && product.dealStatus == 0)
          .toList();
    }
    if (sortByDealStatus3) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.isFavorited == true && product.dealStatus == 1)
          .toList();
    }

    return filteredProducts = filteredProducts
        .where((product) => product.isFavorited == true)
        .toList();
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
    final List<String> ButtonList = ['전체', '거래중', '예약중', '거래완료'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '관심목록',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF302E2E)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(5),
                minimumSize: const Size(40, 24),
                side: const BorderSide(
                  color: Color(0xFFE20529), // 원하는 border 색상 설정
                  width: 1.0, // border의 두께 설정
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0), // 버튼의 모서리를 둥글게 설정
                ),
              ),
              child: Row(
                children: [
                  Text(
                    ButtonList[index],
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFE20529)),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Color(0xFFE20529),
                    size: 16,
                  ),
                ],
              ),
              onPressed: () {
                _accountPopup(context, index);
              },
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

  Future<void> _accountPopup(BuildContext context, int currentindex) async {
    Size screenSize = MediaQuery.of(context).size;
    int newindex = currentindex;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          content: SizedBox(
            width: 270,
            height: screenSize.height * 0.22,
            child: Column(
              children: [
                CustomTextButtonWithBorder(
                  text: '전체보기',
                  onPressed: () {
                    _toggleSortingOrder();
                    Navigator.of(context).pop();
                    newindex = 0;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '거래중',
                  onPressed: () {
                    _toggleSortByDealStatus2();
                    Navigator.of(context).pop();
                    newindex = 1;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '예약중',
                  onPressed: () {
                    _toggleSortByDealStatus3();
                    Navigator.of(context).pop();
                    newindex = 2;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '거래완료',
                  onPressed: () {
                    _toggleSortByDealStatus();
                    Navigator.of(context).pop();
                    newindex = 3;
                  },
                  height: screenSize.height * 0.044,
                ),
                Container(
                  height: screenSize.height * 0.044,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(375, 36), // 크기를 원하는대로 설정
                      ),
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
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() {
      index = newindex; // 인덱스 업데이트를 상태 변경과 함께 수행
    });
  }
}

class CustomTextButtonWithBorder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const CustomTextButtonWithBorder({
    required this.text,
    required this.onPressed,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE20529),
          ),
        ),
      ),
    );
  }
}
