import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/product_detail_provider.dart';
import 'package:dangmoog/providers/user_provider.dart';
import 'package:dangmoog/screens/chat/chat_detail/chat_detail_page.dart';

import 'package:dangmoog/screens/report/post_report.dart';
import 'package:dangmoog/screens/main_page.dart';
import 'package:dangmoog/widgets/bottom_popup.dart';
import 'package:dangmoog/widgets/fadein_router.dart';
import 'package:dangmoog/widgets/fullscreen_image_viewer.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dangmoog/utils/convert_money_format.dart';
import 'package:dangmoog/services/api.dart';
import 'package:provider/provider.dart';

import '../report/user_report.dart';
import 'edit_post_page.dart';

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
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailProvider(ApiService(), widget.postId!),
      child: Consumer<ProductDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.keyboard_backspace,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (provider.product == null) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
              ),
              body: const Center(
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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userNickname = userProvider.nickname;
    bool isUserProduct = product.userName == userNickname;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF726E6E)),
            onPressed: !isUserProduct
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        double dividerThickness = 1;
                        double buttonHeight = 36;
                        return AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPostPage(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size(270, buttonHeight),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                                    final response =
                                        await ApiService().deletePost(postId);
                                    if (response.statusCode == 204) {
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainPage()),
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      print(
                                          'Failed to delete the post: ${response.statusCode}');
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    showPopup(
                                        context, "채팅내역이 존재하는 게시글은 삭제할 수 없습니다.");
                                  }
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(270, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
      body: SingleChildScrollView(
        child: Column(
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
            productInfo(product, provider, isUserProduct),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildChatButton(context, product, provider.chatAvailable),
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
            _current = index;
          });
        },
      ),
      items: displayImages.map((imagePath) {
        return Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(fadeInRouting(
                  FullScreenImageViewer(
                    imageUrls: displayImages,
                    initialPage: _current,
                  ),
                ));
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: (imagePath.startsWith('http') ||
                        imagePath.startsWith('https'))
                    ? Image.network(
                        imagePath,
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
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
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

  Widget productInfo(
    ProductModel product,
    ProductDetailProvider provider,
    bool isUserProduct,
  ) {
    return Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: _buildProductInformation(product),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildProductLikeChatCount(product),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildProductStatusImage(product),
                    ),
                  ],
                ),
              ),
              // Other widgets can be added here as needed
            ],
          ),
          _buildProductDescription(product),
          if (!isUserProduct) _buildReportButton(product),
        ],
      ),
    );
  }

  Widget _buildProductStatusImage(ProductModel product) {
    int saleStatus = product.status;
    bool forFree = product.price == 0;

    // Define the desired height and width
    double imageHeight = 100.0; // Example height
    double imageWidth = 100.0; // Example width

    String imagePath;
    if (saleStatus == 0 && !forFree) {
      imagePath = 'assets/images/saleStatus_logos/selling_logo.png';
    } else if (saleStatus == 0 && forFree) {
      imagePath = 'assets/images/saleStatus_logos/forfree_selling_logo.png';
    } else if (saleStatus == 1 && !forFree) {
      imagePath = 'assets/images/saleStatus_logos/reserved_logo.png';
    } else if (saleStatus == 1 && forFree) {
      imagePath = 'assets/images/saleStatus_logos/forfree_reserved_logo.png';
    } else if (saleStatus == 2 && !forFree) {
      imagePath = 'assets/images/saleStatus_logos/soldout_logo.png';
    } else {
      imagePath = 'assets/images/saleStatus_logos/forfree_soldout_logo.png';
    }

    // Return the image wrapped in a SizedBox
    return SizedBox(
      height: imageHeight,
      width: imageWidth,
      child: Image.asset(imagePath),
    );
  }

  Widget _buildProductInformation(ProductModel product) {
    String saleMethodText =
        (product.useLocker == 1 || product.useLocker == 2) ? '사물함거래' : '직접거래';
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
        '${categeryItems[product.categoryId]} | ${timeAgo(product.createTime)}',
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
              convertMoneyFormat(product.price),
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
      margin: const EdgeInsets.only(top: 16),
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
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 사용자 신고하기 option
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                UserReportPage(product: product),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(270, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.only(
                            top:
                                8), // Ensures no additional padding is affecting the alignment
                      ),
                      child: const Text(
                        '사용자 신고하기',
                        // style: TextStyle(color: Color(0xFFE20529)),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFE20529),
                        ),
                      ),
                    ),
                    const Divider(),
                    // 게시글 신고하기 option
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PostReportPage(product: product),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(270, 36),
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Ensures no additional padding is affecting the alignment
                      ),
                      child: const Text(
                        '게시글 신고하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFE20529),
                        ),
                      ),
                    ),
                    const Divider(),
                    // 취소 option
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(270, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.only(
                            bottom:
                                8), // Ensures no additional padding is affecting the alignment
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Color(0xFFA19E9E)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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

  Widget _buildChatButton(
      BuildContext context, ProductModel product, bool chatAvailable) {
    return Container(
      height: 90,
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
                InkWell(
                  onTap: () {
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
            // 1. 내 게시글이 아니거나
            // 2. 거래상태가 거래중인 경우에만 채팅 가능
            onPressed: chatAvailable
                ? () async {
                    try {
                      String? roomId;

                      // 만약 이미 사용자가 구매자로서 채팅을 보낸 적이 있는 게시글이면
                      // // 해당 게시글에 대한 채탕방 roomId를 찾아서 ChatProvider에 저장
                      // 그렇지 않다면, null값이 저장됨
                      ChatListProvider chatListProvider =
                          Provider.of<ChatListProvider>(context, listen: false);
                      if (chatListProvider.buyChatList.any((chatListCell) =>
                          chatListCell.postId == product.postId)) {
                        // chat list page의 정보 update
                        int index = chatListProvider.buyChatList.indexWhere(
                            (chatListCell) =>
                                chatListCell.postId == product.postId);
                        roomId = chatListProvider.buyChatList[index].roomId;
                      }

                      if (!mounted) return;
                      Provider.of<ChatProvider>(context, listen: false)
                          .getInChatRoom(
                              true, product.postId, product.userName);

                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ChatDetail(
                            roomId: roomId,
                          ),
                        ),
                      );
                    } catch (e) {
                      // 채팅이 불가능함을 사용자에게 알리기
                      print(e);
                    }
                  }
                : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(chatAvailable
                  ? const Color(0xFFE20529)
                  : const Color(0xffBEBCBC)),
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
