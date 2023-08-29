import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import 'package:dangmoog/screens/post/detail_page.dart';
import 'package:dangmoog/screens/addpage/add_page.dart';

import 'package:dangmoog/models/product_list_model.dart';

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
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Visibility(
              visible: _isPressed,
              child: SizedBox(
                width:
                    56, // Set the size to match the FloatingActionButton's size
                height: 56,
                child: Image.asset(
                  'assets/images/add_shadow.png',
                  fit: BoxFit
                      .cover, // This ensures the image fills the entire container
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
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
                          // This ensures the previous page (list page) also moves, revealing itself when swiping the detail page.
                          var previousPageOffsetAnimation = Tween(
                                  begin: const Offset(0, 1),
                                  end: const Offset(0, 0))
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
          ),
        ],
      ),
    );
  }

  Widget _buildIOSListView() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: _buildListView(),
    );
  }

  Widget _buildDefaultListView() {
    return _buildListView();
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: widget.productList.length,
      itemBuilder: (context, index) {
        Widget productCard = ChangeNotifierProvider<ProductListModel>.value(
          value: widget.productList[index],
          child: _buildProductCard(context),
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

  Widget _buildProductCard(BuildContext context) {
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
    double width =
        MediaQuery.of(context).size.width * 0.32; // 32% of screen width
    double paddingValue =
        MediaQuery.of(context).size.width * 0.042; // 4.2% of screen width

    return Padding(
      padding: EdgeInsets.only(
        right: paddingValue,
      ),
      child: SizedBox(
        width: width,
        height: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              15), // You can adjust this value for desired rounding
          child: Image.asset(product.image, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildProductDetails(ProductListModel product) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProductTexts(product),
              IconButton(
                icon: Icon(
                  product.isFavorited ? Icons.favorite : Icons.favorite_border,
                ),
                color: Colors.red,
                onPressed: () {
                  // product.isFavorited = !product.isFavorited;
                },
              ),
            ],
          ),
          Text(
            '${product.price}원',
            style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF552619)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTexts(ProductListModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title,
            style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF552619))),
        _buildCategoryAndTime(product),
      ],
    );
  }

  Widget _buildCategoryAndTime(ProductListModel product) {
    return Row(
      children: [
        Text(
          "${product.category} ",
          style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w200,
              fontSize: 13,
              color: Color(0xFFA07272)),
        ),
        Text(
          "| ${timeAgo(product.uploadTime)}",
          style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w200,
              fontSize: 13,
              color: Color(0xFFA07272)),
        ),
      ],
    );
  }

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
}
