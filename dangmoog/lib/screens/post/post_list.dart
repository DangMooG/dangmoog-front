import 'package:dangmoog/screens/addpage/locker_val.dart';
import 'package:dangmoog/utils/time_ago.dart';
import 'package:dangmoog/providers/post_list_scroll_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:dangmoog/screens/addpage/choose_locker_page.dart';
import 'package:dangmoog/screens/post/detail_page.dart';
import 'package:dangmoog/screens/post/house_page.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/models/product_class.dart';

import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/utils/convert_money_format.dart';

import 'locker_timer.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // pagination을 위한 변수
  int checkpoint = 0;

  List<ProductModel> products = [];
  bool isLoadingProductList = false;

  // 이미지 캐싱을 위한 변수
  Map<int, String> imageCache = {};

  List<ProductModel> lockerProducts = [];

  Future<void> _loadLockerProducts() async {
    if (isLoadingProductList) return; // 중복 호출 방지
    if (mounted) {
      setState(() {
        isLoadingProductList = true;
      });
    }

    try {
      Response lockerResponse = await apiService.loadLockerPost();
      if (lockerResponse.statusCode == 200) {
        final List<dynamic> lockerData = lockerResponse.data;
        List<ProductModel> newLockerProducts = lockerData.map((item) {
          return ProductModel.fromJson(item);
        }).toList();
        // print(newLockerProducts[0].createTime);

        if (mounted) {
          setState(() {
            lockerProducts.addAll(newLockerProducts); // Prepend locker products
            isLoadingProductList = false;
          });
        }
      } else {
        // throw Exception('Failed to load locker products');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadProducts() async {
    if (isLoadingProductList) return; // 중복 호출 방지
    if (mounted) {
      setState(() {
        isLoadingProductList = true;
      });
    }

    try {
      Response response =
          await apiService.loadProductListWithPaging(checkpoint);
      if (response.statusCode == 200) {
        final data = response.data;

        final List<dynamic> items = data["items"];

        List<ProductModel> newProducts =
            items.map((item) => ProductModel.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            checkpoint = data["next_checkpoint"];
            products.addAll(newProducts);
            isLoadingProductList = false;
          });
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print(e);
    }
  }

  double _lastMaxScrollExtent = 0; // null로 시작

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            (_lastMaxScrollExtent +
                (_scrollController.position.maxScrollExtent -
                        _lastMaxScrollExtent) *
                    4 /
                    5) &&
        !isLoadingProductList) {
      if (checkpoint != 0) {
        _lastMaxScrollExtent = _scrollController.position.maxScrollExtent;
        _loadProducts();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initializeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostListScrollProvider>(context, listen: false)
          .setScrollController(_scrollController);
    });
  }

  Future<void> _initializeData() async {
    await _loadProducts();
    await _loadLockerProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isIOS ? _buildIOSListView() : _buildDefaultListView(),
      floatingActionButton: addPostButton(context),
    );
  }

  Widget addPostButton(BuildContext context) {
    // Use MediaQuery to get the screen width and calculate the logo size dynamically.
    double screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth *
        0.15; // Adjust the 0.15 value as needed to scale the logo proportionally.

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              surfaceTintColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 20, left: 21, right: 21),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '거래 방식을 \n선택해주세요!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _customButton(
                            context, '직접거래', 'assets/images/direct_icon.png',
                            () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPostPage(
                                  fromChooseLocker: false, lockerId: null),
                            ),
                          );
                        }),
                        const SizedBox(width: 28),
                        _customButton(
                            context, '사물함거래', 'assets/images/move_to_inbox.png',
                            () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChooseLockerPage(),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 228,
                      height: 36,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // close the dialog
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.red[600]!; // Color when pressed
                              }
                              return Colors.transparent; // Regular color
                            },
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF726E6E)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: Color(0xFF726E6E)),
                            ),
                          ),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        child: const Text('취소하기'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: logoSize, // Use the dynamically calculated logo size.
        height: logoSize, // Use the dynamically calculated logo size.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(logoSize /
              2), // Ensure the borderRadius is half the size of the logo for a circular shape.
          color: Colors.transparent,
        ),
        child: Image.asset('assets/images/add_icon.png'),
      ),
    );
  }

  // 직접 거래 or 사물함 거래 선택 버튼
  Widget _customButton(BuildContext context, String label, String imagePath,
      VoidCallback onPressed) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFE20529),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 20, height: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
    if (products.isEmpty && lockerProducts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (mounted) {
            setState(() {
              checkpoint = 0;
            });
          }
          products.clear();
          lockerProducts.clear();
          await _loadProducts();
          await _loadLockerProducts();
        },
        child: Center(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Center(
                child: Text(
              '등록된 게시글이 없습니다.\n가장 먼저 게시글을 올려보세요!',
              textAlign: TextAlign.center,
            )),
          ),
        )),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (mounted) {
          setState(() {
            checkpoint = 0;
          });
        }
        products.clear();
        lockerProducts.clear();
        await _loadProducts();
        await _loadLockerProducts();
      },
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          cacheExtent: 3000,
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          controller: _scrollController,
          itemCount: 1+ lockerProducts.length + products.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              // InkWell widget at the top of the list
              return Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: Container(
                  width: 343,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC5870),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HousePage(),
                          ),
                        );
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '하우스 중고장터!\n지금 바로 구경하러 가볼까요?!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              // Image.asset(
                              //   'assets/images/gist_house.png',
                              //   width: 84,
                              // ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '구경하러 가기',
                                style: TextStyle(
                                  color: Color(0xffFCE6EA),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              ),
                              Icon(
                                size: 16,
                                Icons.arrow_forward, // Use an arrow icon
                                color: Color(0xffFCE6EA),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (index < lockerProducts.length) {
              // Build locker product card
              return ChangeNotifierProvider<ProductModel>.value(
                value: lockerProducts[index - 1],
                child: _lockerProductCard(context, lockerProducts[index - 1]),
              );
            } else if (index < lockerProducts.length + products.length) {
              return ChangeNotifierProvider<ProductModel>.value(
                value: products[index - lockerProducts.length - 1],
                child: _postCard(context),
              );
            } else if (isLoadingProductList) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
          separatorBuilder: (context, i) {
            if (i == 0) {
              return Container(); // Return an empty container to effectively "remove" the divider
            } else {
              return const Divider(
                  height: 1); // Your existing divider for other items
            }
          },
        ),
      ),
    );
  }

  Widget _lockerProductCard(BuildContext context, ProductModel product) {
    return ProductTimer(
      product: product,
      // lockerProducts: lockerProducts,
      buildProductDetails: _buildProductDetails,
      buildProductImage: _buildProductImage,
      onRemove: () => _removeProductFromLockerProducts(product),
    );
  }

  void _removeProductFromLockerProducts(ProductModel product) {
    setState(() {
      lockerProducts.removeWhere((p) => p.postId == product.postId);
    });
  }

  // 게시물 리스트에서 게시물 하나에 대한 위젯
  Widget _postCard(BuildContext context) {
    return Consumer<ProductModel>(
      builder: (context, product, child) {
        double paddingValue = MediaQuery.of(context).size.width * 0.042;

        return InkWell(
          onTap: () {
            var productDetailPage = ProductDetailPage(postId: product.postId);

            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => productDetailPage,
                // PageRouteBuilder(
                // transitionDuration: const Duration(milliseconds: 400),
                // pageBuilder: (context, animation, secondaryAnimation) =>
                //     productDetailPage,
                // transitionsBuilder:
                //     (context, animation, secondaryAnimation, child) {
                //   var previousPageOffsetAnimation =
                //       Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
                //           .chain(CurveTween(curve: Curves.decelerate))
                //           .animate(animation);

                //   return SlideTransition(
                //     position: previousPageOffsetAnimation,
                //     child: child,
                //   );
                // },)
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(paddingValue),
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
  Widget _buildProductImage(BuildContext context, ProductModel product) {
    double size = MediaQuery.of(context).size.width * 0.28;
    double paddingValue = MediaQuery.of(context).size.width * 0.042;

    return Padding(
      padding: EdgeInsets.only(
        right: paddingValue,
      ),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                strokeAlign: BorderSide.strokeAlignInside,
                color: const Color(0xffD3D2D2),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageCache.containsKey(product.representativePhotoId)
                  ? Image.network(
                      imageCache[product.representativePhotoId]!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: const BoxDecoration(
                            color: Color(0xffD9D9D9),
                          ),
                          width: 90,
                          height: 90,
                        );
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          "assets/images/sample.png",
                          width: 90,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : product.representativePhotoId == 0
                      ? Image.asset(
                          "assets/images/sample.png",
                          width: 90,
                          fit: BoxFit.cover,
                        )
                      : FutureBuilder<Response>(
                          future: apiService
                              .loadPhoto(product.representativePhotoId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffF1F1F1),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Image.asset(
                                "assets/images/sample.png",
                                width: 90,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    "assets/images/sample.png",
                                    width: 90,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            } else if (snapshot.data == null) {
                              return Image.asset(
                                'assets/images/sample.png',
                                fit: BoxFit.cover,
                              );
                            } else if (snapshot.hasData) {
                              Map<String, dynamic> data = snapshot.data!.data;
                              String imageUrl = data["url"];
                              imageCache[product.representativePhotoId] =
                                  imageUrl;
                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Image.asset(
                                    'assets/images/sample.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/images/sample.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            } else {
                              return Image.asset(
                                "assets/images/sample.png",
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
            ),
          ),
          if (product.useLocker != 0)
            Positioned(
              top: 4, // Adjust these values as needed for your logo's position
              left: 4,
              child: Image.asset(
                'assets/images/uselocker_logo.png', // Replace with your logo asset path
                width: size * 0.25, // Adjust the size as needed
              ),
            ),
        ],
      ),
    );
  }

  // 게시물 상세 내역
  Widget _buildProductDetails(BuildContext context, ProductModel product) {
    double height = MediaQuery.of(context).size.width * 0.28;
    return Expanded(
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductTexts(product),
            if (product.useLocker != 1) _buildProductLikeChatCount(product),
          ],
        ),
      ),
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

  // 게시글 제목, 카테고리, 시간, 가격 표시
  Widget _buildProductTexts(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 1,
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
            "${categeryItems[product.categoryId]} | ${timeAgo(product.createTime)}",
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
            _buildDealStatus(product.status),
            product.price != 0
                ? Text(
                    convertMoneyFormat(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF302E2E),
                    ),
                  )
                : const Text(
                    '나눔 🐿️',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF302E2E),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  // 게시글 거래 상태 표기
  Widget _buildDealStatus(int dealStatus) {
    return dealStatus != 0
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
              color: dealStatus == 1
                  ? const Color(0xffEC5870)
                  : const Color(0xff726E6E),
            ),
            child: Text(
              dealStatus == 1 ? '예약중' : '거래완료',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                backgroundColor: dealStatus == 1
                    ? const Color(0xffEC5870)
                    : const Color(0xff726E6E),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
