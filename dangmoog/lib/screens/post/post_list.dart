import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:dangmoog/screens/post/detail_page.dart';

import 'package:dangmoog/models/product_list_model.dart';

import 'package:dangmoog/utils/convert_money_format.dart';

class ProductList extends StatefulWidget {
  final List<ProductListModel> productList;

  const ProductList({Key? key, required this.productList}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isIOS ? _buildIOSListView() : _buildDefaultListView(),
      floatingActionButton: addPostButton(context),
    );
  }

  // 게시물 추가하기 버튼
  GestureDetector addPostButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _isPressed = false;
        });
        Navigator.push(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AddPostPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var previousPageOffsetAnimation =
                      Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                          .chain(CurveTween(curve: Curves.decelerate))
                          .animate(animation);

                  return SlideTransition(
                    position: previousPageOffsetAnimation,
                    // child: const UploadProductPage(),
                    child: const AddPostPage(),
                  );
                }));
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        width: 56, // FloatingActionButton's default size
        height: 56, // FloatingActionButton's default size
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.transparent,
        ),
        child: Image.asset('assets/images/add_icon.png'),
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
    return ListView.separated(
      itemCount: widget.productList.length,
      itemBuilder: (context, index) {
        Widget productCard = ChangeNotifierProvider<ProductListModel>.value(
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
    );
  }

  // 게시물 리스트에서 게시물 하나에 대한 위젯
  Widget _postCard(BuildContext context) {
    return Consumer<ProductListModel>(
      builder: (context, product, child) {
        // 4.2% of screen width
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
                  // const begin = Offset(1.0, 0.0);
                  // const end = Offset.zero;
                  // const curve = Curves.easeInOut;

                  // var tween = Tween(begin: begin, end: end)
                  //     .chain(CurveTween(curve: curve));
                  // var offsetAnimation = animation.drive(tween);

                  // This ensures the previous page (list page) also moves, revealing itself when swiping the detail page.
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
  Widget _buildProductImage(BuildContext context, ProductListModel product) {
    double size =
        MediaQuery.of(context).size.width * 0.32; // 32% of screen width
    double paddingValue =
        MediaQuery.of(context).size.width * 0.042; // 4.2% of screen width

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
          child: Image.asset(
            product.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, ProductListModel product) {
    double height = MediaQuery.of(context).size.width * 0.32;
    return Expanded(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductTexts(product),
            _buildProductLikeChatCount(product),
          ],
        ),
      ),
    );
  }

  // 게시글 제목, 카테고리, 시간, 가격 표시
  Widget _buildProductTexts(ProductListModel product) {
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
            "${product.category} | ${timeAgo(product.uploadTime)}",
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
            _buildDealStatus(product.dealStatus),
            product.price != 0
                ? Text(
                    convertoneyFormat(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF302E2E),
                    ),
                  )
                : const Text('나눔 🐿️'),
          ],
        ),
      ],
    );
  }

  Widget _buildDealStatus(int status) {
    return status != 0
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
              color: status == 1
                  ? const Color(0xffEC5870)
                  : const Color(0xff726E6E),
            ),
            child: Text(
              status == 1 ? '예약중' : '판매완료',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  // 좋아요, 채팅 개수 표시
  Row _buildProductLikeChatCount(ProductListModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              color: Color(0xffA19E9E),
              size: 15,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              product.likeCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Color(0xffA19E9E),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.forum_outlined,
              color: Color(0xffA19E9E),
              size: 15,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              product.chatCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Color(0xffA19E9E),
              ),
            ),
          ],
        )
      ],
    );
  }
}
