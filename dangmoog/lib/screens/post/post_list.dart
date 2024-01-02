import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:dangmoog/screens/addpage/choose_locker_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:dangmoog/screens/post/detail_page.dart';

import 'package:dangmoog/models/product_class.dart';

import 'package:dangmoog/utils/convert_money_format.dart';

import 'package:dangmoog/services/api.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Future<List<ProductModel>> futureProducts;
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // 이미지 캐싱을 위한 변수
  Map<int, String> imageCache = {};

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  // 현재 사용된 곳 없음
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      // You're at the top of the scrollable, trigger the refresh logic
      setState(() {
        futureProducts = fetchProducts();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> fetchProducts() async {
    Response response = await apiService.loadList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isIOS ? _buildIOSListView() : _buildDefaultListView(),
      floatingActionButton: addPostButton(context),
    );
  }

  // 게시물 추가하기 버튼
  Widget addPostButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '거래 방식을 \n선택해주세요!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _customButton(
                            context, '직접거래', 'assets/images/direct_icon.png',
                            () {
                          Navigator.of(context).pop(); // close the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddPostPage(title: '직접거래 등록'),
                            ),
                          );
                        }),
                        _customButton(context, '사물함 거래',
                            'assets/images/move_to_inbox.png', () {
                          Navigator.of(context).pop(); // close the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChooseLockerPage(),
                            ),
                          );

                          // For now, it just closes the dialog, but you can add navigation or other logic here
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // close the dialog
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.red[600]!; // Color when pressed
                              }
                              return Colors.transparent; // Regular color
                            },
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF726E6E)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: Color(0xFF726E6E)),
                            ),
                          ),
                        ),
                        child: const Text('취소하기'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.transparent,
        ),
        child: Image.asset('assets/images/add_icon.png'),
      ),
    );
  }

  // 직접 거래 or 사물함 거래 선택 버튼
  Widget _customButton(BuildContext context, String label, String imagePath,
      VoidCallback onPressed) {
    return SizedBox(
      width: 100, // same width and height
      height: 100, // same width and height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFE20529), // text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // center the children vertically
          children: [
            Image.asset(imagePath,
                width: 24,
                height:
                    24), // replace 'path_to_your_image.png' with your image's path
            const SizedBox(
                height: 5), // adjust the space between the image and text
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSListView() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: _postListView(),
    );
  }

  Widget _buildDefaultListView() {
    return _postListView();
  }

  // 게시물 리스트 위젯
  Widget _postListView() {
    return FutureBuilder<List<ProductModel>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While data is still loading:
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If we run into an error:
          return Center(
              child: Text('Failed to load products: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Data is loaded but empty:
          return const Center(child: Text('No products available.'));
        }

        // Data is loaded and available:
        List<ProductModel> products = snapshot.data!;
        // Reverse the order of products so the latest one appears at the top.
        products = products.reversed.toList();
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              futureProducts = fetchProducts();
            });
            await futureProducts;
          },
          child: ListView.separated(
            controller: _scrollController,
            itemCount: products.length,
            itemBuilder: (context, index) {
              Widget productCard = ChangeNotifierProvider<ProductModel>.value(
                value: products[index],
                child: _postCard(context),
              );
              return productCard;
            },
            separatorBuilder: (context, i) {
              return const Divider(
                height: 1,
              );
            },
          ),
        );
      },
    );
  }

  // 게시물 리스트에서 게시물 하나에 대한 위젯
  Widget _postCard(BuildContext context) {
    return Consumer<ProductModel>(
      builder: (context, product, child) {
        double paddingValue = MediaQuery.of(context).size.width * 0.042;
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProductDetailPage(
                  postId: product.postId,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var previousPageOffsetAnimation =
                      Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
                          .chain(CurveTween(curve: Curves.decelerate))
                          .animate(animation);

                  return SlideTransition(
                    position: previousPageOffsetAnimation,
                    child: ProductDetailPage(
                      postId: product.postId,
                    ),
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(
              paddingValue,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImage(context, product),
                _buildProductDetails(context, product),
              ],
            ),
          ),
        );
      },
    );
  }

  // 게시물 내역 이미지
  Widget _buildProductImage(BuildContext context, ProductModel product) {
    double size = MediaQuery.of(context).size.width * 0.28;
    double paddingValue = MediaQuery.of(context).size.width * 0.042;

    return Padding(
      padding: EdgeInsets.only(
        right: paddingValue,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignInside,
            color: const Color(0xffF1F1F1),
            width: 0.5,
          ),
        ),
        child: imageCache.containsKey(product.representativePhotoId)
            ? Image.network(
                imageCache[product.representativePhotoId]!,
                fit: BoxFit.cover,
              )
            : product.representativePhotoId == 0
                ? Image.asset(
                    "assets/images/sample.png",
                    width: 90,
                    fit: BoxFit.cover,
                  )
                : FutureBuilder<Response>(
                    future: apiService.loadPhoto(product.representativePhotoId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Image.asset(
                          "assets/images/sample.png",
                          width: 90,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              "assets/images/sample.png",
                              width: 90,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      } else if (snapshot.data == null) {
                        return Image.asset(
                          '/assets/images/sample.png',
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.hasData) {
                        Map<String, dynamic> data = snapshot.data!.data;
                        String imageUrl = data["url"];
                        imageCache[product.representativePhotoId] = imageUrl;
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Image.asset(
                          "assets/images/sample.png",
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
      ),
    );
  }

  
  Widget _buildProductDetails(BuildContext context, ProductModel product) {
    double height = MediaQuery.of(context).size.width * 0.28;
    return Expanded(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductTexts(product),
            // LikeChatCount(product: product)
          ],
        ),
      ),
    );
  }

  // 게시글 제목, 카테고리, 시간, 가격 표시
  Widget _buildProductTexts(ProductModel product) {
    String timeAgo(DateTime date) {
      Duration diff = DateTime.now().difference(date);

      int years = (diff.inDays / 365).floor();
      int months = (diff.inDays / 30).floor();
      int weeks = (diff.inDays / 7).floor();

      if (years > 0) {
        return '$years년 전';
      } else if (months > 0) {
        return '$months개월 전';
      } else if (weeks > 0) {
        return '$weeks주일 전';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}일 전';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}시간 전';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}분 전';
      } else {
        return '방금 전';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF302E2E),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "${categeryItems[product.categoryId - 1]} | ${timeAgo(product.createTime)}",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: Color(0xFFA19E9E),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDealStatus(product.status),
            product.price != 0
                ? Text(
                    convertoneyFormat(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF302E2E),
                    ),
                  )
                : const Text(
                    '나눔 🐿️',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF302E2E),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  // 게시글 거래 상태 표기
  Widget _buildDealStatus(int dealStatus) {
    return dealStatus != 0
        ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2.5,
            ),
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(3),
              ),
              color: dealStatus == 1
                  ? const Color(0xffEC5870)
                  : const Color(0xff726E6E),
            ),
            child: Text(
              dealStatus == 1 ? '예약중' : '판매완료',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                backgroundColor: dealStatus == 1
                    ? const Color(0xffEC5870)
                    : const Color(0xff726E6E),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
