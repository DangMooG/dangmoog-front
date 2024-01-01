import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/screens/chat/chat_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dangmoog/utils/convert_money_format.dart';
import 'package:dangmoog/services/api.dart';
import 'package:provider/provider.dart';

import 'edit_post_page.dart';
import 'main_page.dart';

class ProductDetailProvider with ChangeNotifier {
  final ApiService apiService;
  ProductModel? product;
  bool isLoading = true;
  List<String> images = [];

  ProductDetailProvider(this.apiService, int postId) {
    _fetchProductDetail(postId);
  }

  Future<void> _fetchProductDetail(int postId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.loadProduct(postId);
      if (response.statusCode == 200) {
        product = ProductModel.fromJson(response.data);
        await _fetchPhotos(postId);

        await _checkIfFavorited(postId);
      } else {}
    } catch (e) {
      // Handle any exceptions here
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPhotos(int postId) async {
    try {
      final response = await apiService.searchPhoto(postId);
      if (response.statusCode == 200) {
        List<dynamic> photoData = response.data;
        images = photoData.map((item) => item['url'].toString()).toList();
      } else {
        // Handle non-200 responses
      }
    } catch (e) {
      // Handle exceptions
    }
    notifyListeners();
    // No need to call notifyListeners here if you're calling this method
    // from within _fetchProductDetail, which calls notifyListeners in finally.
  }

  List<int> likedProductIds = [];

  Future<void> _checkIfFavorited(int postId) async {
    try {
      final response = await apiService.getLikeList();
      if (response.statusCode == 200) {
        List<dynamic> likedPosts = response.data;
        bool isFavorited = likedPosts.any((item) => item['post_id'] == postId);
        if (product != null) {
          product!.isFavorited = isFavorited;
        }
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  void toggleLike() async {
    if (product == null) return;

    bool isCurrentlyFavorited = product!.isFavorited;
    product!.isFavorited = !isCurrentlyFavorited;
    product!.likeCount += isCurrentlyFavorited ? -1 : 1;
    notifyListeners();

    try {
      Response response = isCurrentlyFavorited
          ? await apiService.decreaseLike(product!.postId)
          : await apiService.increaseLike(product!.postId);

      // Handle response accordingly
      // If there's an error, revert the like state and update UI
      if (response.statusCode != (isCurrentlyFavorited ? 204 : 200)) {
        product!.isFavorited = isCurrentlyFavorited;
        product!.likeCount += isCurrentlyFavorited ? 1 : -1;
        notifyListeners();
      }
      print(response);
    } catch (e) {
      rethrow;
    }
  }
}

class ProductDetailPage extends StatefulWidget {
  final int? postId;

  const ProductDetailPage({
    Key? key,
    this.postId,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Initialize your ProductDetailProvider here
      create: (_) => ProductDetailProvider(ApiService(), widget.postId!),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (provider.product == null) {
            return const Scaffold(
              body: Center(
                child: Text('Product not found!'),
              ),
            );
          }
          return _buildProductDetail(context, provider);
        },
      ),
    );
  }

  Widget _buildProductDetail(
      BuildContext context, ProductDetailProvider provider) {
    final product = provider.product!;
    //TODO: 유저네임 바꾸기
    // bool isUserProduct = product.userName =='flatfish';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF726E6E)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  double dividerThickness = 1;
                  double buttonHeight = 36;
                  return AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            //TODO:  How should I declare postId? I have to send it to the editpostpage.

                            Navigator.pop(context); // Close the dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPostPage(
                                        postId: widget.postId!,
                                        product: product,
                                      )),
                            );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(270, buttonHeight),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.only(
                                top:
                                    8), // Ensures no additional padding is affecting the alignment
                          ),
                          child: const Text(
                            '수정하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFE20529),
                              height: 20 / 14, // line height
                            ),
                          ),
                        ),
                        Divider(thickness: dividerThickness),
                        TextButton(
                          onPressed: () async {
                            int postId = product.postId;
                            try {
                              final response = await ApiService()
                                  .deletePost(postId); // Call the delete API
                              if (response.statusCode == 204) {
                                Navigator.pop(context);
                                // Handle successful deletion here, like showing a confirmation message
                              } else {
                                // Handle the error case
                                print(
                                    'Failed to delete the post: ${response.statusCode}');
                              }
                            } catch (e) {
                              // Handle any exceptions here
                              print(
                                  'An error occurred while deleting the post: $e');
                            }
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(270, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets
                                .zero, // Ensures no additional padding is affecting the alignment
                          ),
                          child: const Text(
                            '삭제하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFE20529),
                            ),
                          ),
                        ),
                        Divider(thickness: dividerThickness),
                        TextButton(
                          onPressed: () {
                            // Close the dialog
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(270, buttonHeight),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.only(
                                bottom:
                                    8), // Ensures no additional padding is affecting the alignment
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Color(0xFFA19E9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                sliderWidget(context),
                sliderIndicator(context),
              ],
            ),
          ),
          productInfo(product),
        ],
      ),
      bottomNavigationBar: _buildChatButton(context, product),
    );
  }

  Widget sliderWidget(BuildContext context) {
    final provider = Provider.of<ProductDetailProvider>(context);
    List<String> displayImages = provider.images.isNotEmpty
        ? provider.images
        : ['assets/images/sample.png'];
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

  Widget sliderIndicator(BuildContext context) {
    final provider = Provider.of<ProductDetailProvider>(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: provider.images.asMap().entries.map((entry) {
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
    String saleMethodText = product.useLocker == 1 ? '사물함거래' : '직접거래';
    Widget imageWidget = product.useLocker == 1
        ? Image.asset(
            'assets/images/uselocker_logo.png', // Replace with your asset image path
            width: 16, // Set your desired width for the image
            height: 16, // Set your desired height for the image
          )
        : const SizedBox(); // Empty box for when there is no image

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            imageWidget,
            const SizedBox(width: 4), // Space between image and text
            Text(
              saleMethodText,
              style: const TextStyle(
                color: Color(0xffE20529),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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

  Widget _buildChatButton(BuildContext context, ProductModel product) {
    return Container(
      height: 85,
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xffBEBCBC),
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
                    onTap: () {
                      // Call the provider's method to toggle the like state
                      Provider.of<ProductDetailProvider>(context, listen: false)
                          .toggleLike();
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
            onPressed: () async {
              // Handle chat logic here

              Response response =
                  await ApiService().getChatRoomId(product.postId);
              if (response.statusCode == 200) {
                String roomId = response.data["room_id"];

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetail(
                      product: product,
                      roomId: roomId,
                    ),
                  ),
                );
              } else {
                // 삭제된 게시글이라든지, 예약중이거나 거래완료된 게시글이라든지
                // 알 수 없는 게시글이라든지
              }
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFE20529)),
              minimumSize: MaterialStateProperty.all<Size>(const Size(269, 46)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
