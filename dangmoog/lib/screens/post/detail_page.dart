import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dangmoog/constants/navbar_icon.dart';


class ImageSlider extends StatefulWidget {
  final List<String> images;

  ImageSlider({required this.images});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.45,
            viewportFraction: 1.0, // Full width item
            autoPlay: false,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.images.map((imagePath) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.map((url) {
              int index = widget.images.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? const Color(0xFFCCBEBA)
                      : const Color(0xFFFFFFFF),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

Widget _buildProductImage(BuildContext context, Product product) {
  return ImageSlider(images: product.images);
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Product>.value(
      value: product,
      child: Consumer<Product>(
        builder: (context, product, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent, // Transparent AppBar
              elevation: 0, // No shadow
              iconTheme: const IconThemeData(color: Colors.white), // Icon color
            ),
            extendBodyBehindAppBar: true,
            // Text color
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImage(context, product),
                _buildTopInfoRow(context, product),
                _buildProductInformation(product),

              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildChatButton(),
            ),

          );
        },
      ),
    );
  }



  Widget _buildProductInformation(Product product){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:<Widget>[
          _buildProductTitle(product),
          _buildProductPrice(product),
          _buildSellerName(product),
          _buildProductDetails(product),
          _buildProductDescription(product),
        ]
      ),
    );
  }

  Widget _buildTopInfoRow(BuildContext context, Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
              product.isFavorited ? Icons.favorite : Icons.favorite_border),
          color: Colors.red,
          onPressed: () {
            product.isFavorited = !product.isFavorited;
            product.notifyListeners();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            '${timeAgo(product.uploadTime)} | ${product.viewCount} 명 읽음 | 좋아요 ${product.likes} 개',
          ),
        ),
      ],
    );
  }

  Widget _buildProductTitle(Product product) {
    return Text(
      product.title,
      style: const TextStyle(
          fontSize: 18,
          color: Color(0xff552619),
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProductPrice(Product product) {
    return Text(
      '${product.price.toStringAsFixed(2)}원',
      style: const TextStyle(
        fontSize: 18,
        color: Color(0xff552619),
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSellerName(Product product) {
    return Text(
      product.user,
      style: const TextStyle(
          fontSize: 13,
          color: Color(0xffa07272),
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w300),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        '${product.category} | ${product.saleMethod} | ${timeAgo(product.uploadTime)}',
        style: const TextStyle(
            fontSize: 12,
            color: Color(0xffa07272),
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget _buildProductDescription(Product product) {
    return Text(
      product.description,
      style: const TextStyle(
          fontSize: 18,
          color: Color(0xff421E14),
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w200),
    );
  }

  Widget _buildChatButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // handle chat logic
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          minimumSize:
              MaterialStateProperty.all<Size>(const Size(double.infinity, 50)),
        ),
        child: const Text('바로 채팅하기'),
      ),
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


