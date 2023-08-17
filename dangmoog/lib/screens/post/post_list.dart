
import 'package:flutter/material.dart';
import '../../../models/product_class.dart';

//import '../../widgets/post/detail_page.dart';
import 'detail_page.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/screens/addpage/add_page.dart';
import 'dart:io';


class ProductList extends StatefulWidget {
  final List<Product> products;
  const ProductList({Key? key, required this.products}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
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
                  width: 56, // Set the size to match the FloatingActionButton's size
                  height: 56,
                  child: Image.asset(
                    'assets/images/add_shadow.png',
                    fit: BoxFit.cover, // This ensures the image fills the entire container
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
                  Navigator.push(context,
                  PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, animation, secondaryAnimation) => UploadProductPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {

                        // This ensures the previous page (list page) also moves, revealing itself when swiping the detail page.
                        var previousPageOffsetAnimation = Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation);

                        return SlideTransition(
                          position: previousPageOffsetAnimation,
                          child: UploadProductPage(),
                        );
                      }
                  ));

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
        )

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
      itemCount: widget.products.length,
      itemBuilder: (context, i) {
        Widget productCard = ChangeNotifierProvider<Product>.value(
          value: widget.products[i],
          child: _buildProductCard(context),
        );
        // Apply extra padding to the first item only
        if (i == 0) {
          productCard = Padding(
            padding: const EdgeInsets.only(top: 8.0), // Set your desired padding
            child: productCard,
          );
        }
        else if (i == widget.products.length-1) {
          productCard = Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Set your desired padding
            child: productCard,
          );
        }
        return productCard;
      },
      separatorBuilder: (context, i) {
        return const Divider();
      },
    );
  }



  Widget _buildProductCard(BuildContext context) {
    return Consumer<Product>(
      builder: (context, product, child) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(product: product,),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    // This ensures the previous page (list page) also moves, revealing itself when swiping the detail page.
                    var previousPageOffsetAnimation = Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation);

                    return SlideTransition(
                      position: previousPageOffsetAnimation,
                      child: ProductDetailPage(product: product,),
                    );
                  }

              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildProductImage(context, product),
              _buildProductDetails(product),
            ],
          ),
        );
      },
    );
  }


  Widget _buildProductImage(BuildContext context, Product product) {
    double width = MediaQuery.of(context).size.width * 0.32; // 32% of screen width
    double paddingValue = MediaQuery.of(context).size.width * 0.042; // 4.2% of screen width

    return Padding(
      padding: EdgeInsets.only(right: paddingValue/2, bottom: paddingValue/2, left: paddingValue, top: paddingValue/2),
      child: SizedBox(
        width: width,
        height: width, // height will also be 32% of the screen width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15), // You can adjust this value for desired rounding
          child: Image.asset(product.images[0], fit: BoxFit.cover),
        ),
      ),
    );
  }



  Widget _buildProductDetails(Product product) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                    product.isFavorited = !product.isFavorited;
                  },
                ),
              ],
            ),
            Text('${product.price}원',
              style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF552619)
              ),
            ),
            // _buildComments(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTexts(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title,
            style: const TextStyle(fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF552619))),
        _buildCategoryAndTime(product),
      ],
    );
  }

  Widget _buildCategoryAndTime(Product product) {
    return Row(
      children: [
        Text("${product.category} ",
              style: const TextStyle(fontFamily: 'Pretendard',
                                     fontWeight: FontWeight.w200,
                                     fontSize: 13,
                                     color: Color(0xFFA07272)),),
        Text("| ${timeAgo(product.uploadTime)}",
                style: const TextStyle(fontFamily: 'Pretendard',
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
