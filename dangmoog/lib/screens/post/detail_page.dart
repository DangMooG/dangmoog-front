import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/screens/post/like_chat_count.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:dangmoog/utils/convert_money_format.dart';
import 'package:dangmoog/services/api.dart';

class ProductDetailPage extends StatefulWidget {
  final int? postId;

  const ProductDetailPage({
    Key? key,
    this.postId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  ApiService apiService = ApiService();
  List<String> images = [];
  late Future<ProductModel?> futureProductDetail;

  Future<ProductModel> fetchProductDetail(int postId) async {
    Response response =
        await apiService.loadProduct(postId); // Adjust the URL accordingly

    if (response.statusCode == 200) {
      return ProductModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProductDetail = fetchProductDetail(widget.postId!);

    apiService.searchPhoto(widget.postId!).then((response) {
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        images = data.map((item) => item['url'] as String).toList();
        print(images);
        setState(() {});
      } else {
        // Handle the error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: futureProductDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(child: Text('Error loading products!'));
          }
          if (snapshot.data == null) {
            return const Center(child: Text('Product not found!'));
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
  }

  Widget sliderWidget(ProductModel product) {
    List<String> displayImages =
        images.isNotEmpty ? images : ['assets/images/sample.png'];
    return CarouselSlider(
      carouselController: _controller,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.45,
        viewportFraction: 1.0,
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
      items: displayImages.map((imagePath) {
        return Builder(
          builder: (context) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: (imagePath.startsWith('http') ||
                      imagePath.startsWith('https'))
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.fill,
                    )
                  : Image.asset(
                      imagePath,
                      fit: BoxFit.fill,
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
        children: images.asMap().entries.map((entry) {
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
              _buildProductLikeChatCount(product),
              // LikeChatCount(product: product, apiService: apiService,)
            ],
          ),
          _buildProductDescription(product),
          _buildReportButton(product),
        ],
      ),
    );
  }

  Widget _buildProductInformation(ProductModel product) {
    String saleMethodText;

    if (product.useLocker == 0) {
      saleMethodText = '직접거래';
    } else {
      saleMethodText = '사물함거래';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          saleMethodText,
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
            const Text(
              // apiService.chatCount(product.postId).toString(),
              "0",
              style: TextStyle(
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
        '${categeryItems[product.categoryId - 1]} | ${timeAgo(product.createTime)}',
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
                  child: InkWell(
                    onTap: () async {
                      // product.isUpdatingLike = true;  // Indicate that we're starting the update process

                      product.isFavorited = !product
                          .isFavorited; // Optimistically toggle the favorite state
                      product.likeCount +=
                          product.isFavorited ? 1 : -1; // Adjust the like count
                      product.notifyListeners(); // Notify the UI of changes

                      final response = product.isFavorited
                          ? await apiService.increaseLike(product.postId)
                          : await apiService.decreaseLike(product.postId);

                      // Check for status code 200 for increase and 204 for decrease
                      if ((product.isFavorited && response.statusCode != 200) ||
                          (!product.isFavorited &&
                              response.statusCode != 204)) {
                        setState(() {
                          product.isFavorited = !product
                              .isFavorited; // Revert the favorite state if the request failed
                          product.likeCount += product.isFavorited
                              ? 1
                              : -1; // Revert the like count
                        });
                      } else {
                        setState(() {
                          futureProductDetail =
                              fetchProductDetail(widget.postId!);
                        });
                      }

                      // product.isUpdatingLike = false;  // Reset the updating flag
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
