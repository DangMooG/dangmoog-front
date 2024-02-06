import 'package:dangmoog/constants/category_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:dangmoog/screens/post/detail_page.dart';

import 'package:dangmoog/models/product_class.dart';

import 'package:dangmoog/utils/convert_money_format.dart';

import 'package:dangmoog/services/api.dart';

enum SortingOrder { ascending, descending }

class MyProductList extends StatefulWidget {
  final List<ProductModel> productList;
  final VoidCallback reloadProductList;

  const MyProductList({
    Key? key,
    required this.productList,
    required SortingOrder? sortingOrder,
    required this.reloadProductList,
  }) : super(key: key);
  @override
  State<MyProductList> createState() => _MyProductListState();
}

class _MyProductListState extends State<MyProductList> {
  late Future<List<ProductModel>> futureProducts;
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // 이미지 캐싱을 위한 변수
  Map<int, String> imageCache = {};

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isIOS ? _buildIOSListView() : _buildDefaultListView(),
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
    return RefreshIndicator(
        onRefresh: () async {
          widget.reloadProductList();
          // setState(() {
          //   //   futureProducts = widget.productList as Future<List<ProductModel>>;
          //   futureProducts = Future.value(widget.productList);
          // });
          // await futureProducts;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.productList.length,
          itemBuilder: (context, index) {
            Widget productCard = ChangeNotifierProvider<ProductModel>.value(
              value: widget.productList[index],
              child: _postCard(context),
            );
            return productCard;
          },
          separatorBuilder: (context, i) {
            return const Divider(
              height: 1,
            );
          },
        ));
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageCache.containsKey(product.representativePhotoId)
              ? Image.network(
                  imageCache[product.representativePhotoId]!,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      "assets/images/sample.png",
                      width: 90,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : product.representativePhotoId == 0
                  ? Image.asset(
                      "assets/images/sample.png",
                      width: 90,
                      fit: BoxFit.cover,
                    )
                  : FutureBuilder<Response>(
                      future:
                          apiService.loadPhoto(product.representativePhotoId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Image.asset(
                            "assets/images/sample.png",
                            width: 90,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                "assets/images/sample.png",
                                width: 90,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        } else if (snapshot.data == null) {
                          return Image.asset(
                            'assets/images/sample.png',
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
            "${categeryItems[product.categoryId]} | ${timeAgo(product.createTime)}",
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
                    convertMoneyFormat(product.price),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
