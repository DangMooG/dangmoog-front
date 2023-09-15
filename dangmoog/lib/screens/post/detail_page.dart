import 'package:dangmoog/screens/post/like_chat_count.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dangmoog/utils/convert_money_format.dart';

Future<ProductModel> _loadProductFromAsset() async {
  final String jsonString =
      await rootBundle.loadString('assets/product_detail.json');
  final dynamic productDetailData = json.decode(jsonString);

  return ProductModel(
    postId: productDetailData['postId'],
    title: productDetailData['title'],
    description: productDetailData['description'],
    price: productDetailData['price'],
    images: productDetailData['images'],
    category: productDetailData['category'],
    uploadTime: DateTime.parse(productDetailData['uploadTime']),
    saleMethod: productDetailData['saleMethod'],
    userName: productDetailData['userName'],
    dealStatus: productDetailData['dealStatus'],
    viewCount: productDetailData['viewCount'],
    chatCount: productDetailData['chatCount'],
    likeCount: productDetailData['likeCount'],
    isFavorited: productDetailData['isFavorited'],
  );
}

class ProductDetailPage extends StatefulWidget {
  final int postId;

  const ProductDetailPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  late Future<ProductModel> futureProductDetail;

  @override
  void initState() {
    super.initState();
    futureProductDetail = _loadProductFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel>(
      future: futureProductDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products!'));
          }
          return _buildProductDetail(snapshot.data!);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildProductDetail(ProductModel product) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                sliderWidget(product),
                sliderIndicator(product),
              ],
            ),
          ),
          productInfo(product),
        ],
      ),
      bottomNavigationBar: _buildChatButton(product),
    );

    // return ChangeNotifierProvider<ProductModel>.value(
    //   value: widget.product,
    //   child: Consumer<ProductModel>(
    //     builder: (context, product, child) {
    //       return Scaffold(
    //         appBar: AppBar(
    //           backgroundColor: Colors.transparent,
    //           elevation: 0,
    //           iconTheme: const IconThemeData(color: Colors.white),
    //         ),
    //         extendBodyBehindAppBar: true,
    //         body: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             SizedBox(
    //               child: Stack(
    //                 children: [
    //                   sliderWidget(),
    //                   Positioned(
    //                     bottom: 0,
    //                     left: 0,
    //                     right: 0,
    //                     child: sliderIndicator(),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             _buildProductLikeChatCount(context, product),
    //             _buildProductInformation(product),
    //           ],
    //         ),
    //         bottomNavigationBar: Padding(
    //           padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
    //           child: _buildChatButton(product),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Widget sliderWidget(ProductModel product) {
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.45,
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
      items: product.images.map((imagePath) {
        return Builder(
          builder: (context) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
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

  Widget sliderIndicator(ProductModel product) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: product.images.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 9.0,
              height: 9.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffCCBEBA),
                  width: 0.5,
                ),
                color: _current == entry.key
                    ? const Color(0xFFCCBEBA)
                    : const Color(0xFFFFFFFF),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget productInfo(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInformation(product),
              // _buildProductLikeChatCount(product),
              LikeChatCount(product: product)
            ],
          ),
          _buildProductDescription(product),
          _buildReportButton(product),
        ],
      ),
    );
  }

  Widget _buildProductInformation(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 거래 방식 표기
        Text(
          product.saleMethod,
          style: const TextStyle(
            color: Color(0xffE20529),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        _buildProductTitle(product),
        _buildSellerName(product),
        _buildProductDetails(product),
        _buildProductPrice(product),
      ],
    );
  }

  // 좋아요, 채팅 개수 표기
  Widget _buildProductLikeChatCount(ProductModel product) {
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

  // 게시글 제목 표기
  Widget _buildProductTitle(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Text(
        product.title,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xff302E2E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 판매자 닉네임 표기
  Widget _buildSellerName(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            product.userName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff726E6E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            '님',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff726E6E),
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }

  // 카테고리, 올린 날짜
  Widget _buildProductDetails(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Text(
        '${product.category} | ${timeAgo(product.uploadTime)}',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xffA19E9E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // 판매 물품 가격 표기
  Widget _buildProductPrice(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: product.price != 0
          ? Text(
              convertoneyFormat(product.price),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF302E2E),
              ),
            )
          : const Text('나눔 🐿️'),
    );
  }

  // 게시글 본문 내용
  Widget _buildProductDescription(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(
        top: 28,
      ),
      child: Text(
        product.description,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xff302E2E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildReportButton(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
      ),
      child: InkWell(
        onTap: () {},
        child: const Text(
          '신고하기',
          style: TextStyle(
            color: Color(0xff726E6E),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xff726E6E),
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(ProductModel product) {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(
              0xffBEBCBC,
            ),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  child: GestureDetector(
                    // borderRadius: BorderRadius.circular(20), // 물린 효과의 모서리를 둥글게
                    // radius: 60.0,
                    onTap: () {
                      product.isFavorited = !product.isFavorited;
                      product.notifyListeners();
                    },
                    child: Icon(
                      product.isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xffE20529),
                      size: 30,
                    ),
                  ),
                ),
                Text(
                  "${product.likeCount}",
                  style: const TextStyle(
                    color: Color(0xffE20529),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // handle chat logic
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFFE20529)),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size(269, 46)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)))),
            child: const Text(
              '채팅하기',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ],
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
