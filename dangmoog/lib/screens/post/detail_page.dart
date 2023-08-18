import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';



class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  int _current = 0; // Remove the final keyword
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Product>.value(
      value: widget.product,
      child: Consumer<Product>(
        builder: (context, product, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            extendBodyBehindAppBar: true,
            body:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              <Widget>[
                SizedBox(
                  child: Stack(
                    children: [
                      sliderWidget(),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: sliderIndicator(),
                      ),
                    ],
                  ),
                ),
                _buildTopInfoRow(context, product),
                _buildProductInformation(product),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: _buildChatButton(product),
            ),
          );
        },
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
        height: MediaQuery
            .of(context)
            .size
            .height * 0.45,
        viewportFraction: 1.0,

        // Full width item
        autoPlay: false,
        enlargeCenterPage: false,
        enableInfiniteScroll: false,
        initialPage: 0,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index; // Update _current to the new page index
          });
        },
      ),
      items: widget.product.images.map((imagePath) {
        return Builder(
          builder: (context) {
            return SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage(imagePath),
              ),
            );
          },
        );
      }).toList(),
    );
  }


  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.product.images
            .asMap()
            .entries
            .map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == entry.key
                    ? Color(0xFFCCBEBA)
                    : Color(0xFFFFFFFF),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildProductInformation(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 8.0),
          child: Text(
            '${timeAgo(product.uploadTime)} | ${product
                .viewCount} 명 읽음 | 좋아요 ${product.likes} 개',
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '${product.price.toStringAsFixed(2)}원',
        style: const TextStyle(
            fontSize: 18,
            color: Color(0xff552619),
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold),
      ),
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
        '${product.category} | ${product.saleMethod} | ${timeAgo(
            product.uploadTime)}',
        style: const TextStyle(
            fontSize: 12,
            color: Color(0xffa07272),
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget _buildProductDescription(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        product.description,
        style: const TextStyle(
            fontSize: 18,
            color: Color(0xff421E14),
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w200),
      ),
    );
  }

  Widget _buildChatButton(Product product) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              product.isFavorited ? Icons.favorite : Icons.favorite_border,
            ),
            color: Colors.red,
            onPressed: () {
              product.isFavorited = !product.isFavorited;
              product.notifyListeners();
            },
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // handle chat logic
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFFC30020)),
                minimumSize:
                MaterialStateProperty.all<Size>(
                    const Size(double.infinity, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0)
                    )
                )
            ),
            child: const Text(
              '바로 채팅하기', style: TextStyle(color: Color(0xFFFFFFFF)),),
          ),
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
