import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:dangmoog/screens/post/detail_page.dart';
import 'package:dangmoog/screens/addpage/add_page.dart';

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
      floatingActionButton: GestureDetector(
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
                      const UploadProductPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var previousPageOffsetAnimation = Tween(
                            begin: const Offset(0, 1), end: const Offset(0, 0))
                        .chain(CurveTween(curve: Curves.decelerate))
                        .animate(animation);

                    return SlideTransition(
                      position: previousPageOffsetAnimation,
                      child: const UploadProductPage(),
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
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

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
                _buildProductDetails(product),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(BuildContext context, ProductListModel product) {
    double size =
        MediaQuery.of(context).size.width * 0.32; // 32% of screen width
    double paddingValue =
        MediaQuery.of(context).size.width * 0.042; // 4.2% of screen width

    return Padding(
      padding: EdgeInsets.only(
        right: paddingValue,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            product.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(ProductListModel product) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTexts(product),
          // like button
          IconButton(
            icon: Icon(
              product.isFavorited ? Icons.favorite : Icons.favorite_border,
            ),
            color: Colors.red,
            onPressed: () {
              product.isFavorited = !product.isFavorited;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductTexts(ProductListModel product) {
    String timeAgo(DateTime date) {
      Duration diff = DateTime.now().difference(date);
      if (diff.inDays > 0) {
        return '${diff.inDays} 일 전';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} 시간 전';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} 분 전';
      } else {
        return '방금 전';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Color(0xFF552619),
          ),
        ),
        Text(
          "${product.category} | ${timeAgo(product.uploadTime)}",
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w200,
            fontSize: 13,
            color: Color(0xFFA07272),
          ),
        ),
        Text(
          convertoneyFormat(product.price),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF552619),
          ),
        ),
      ],
    );
  }
}
