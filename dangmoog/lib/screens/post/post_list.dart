import 'package:dangmoog/screens/addpage/locker_val.dart';
import 'package:dangmoog/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:dangmoog/screens/addpage/choose_locker_page.dart';
import 'package:dangmoog/screens/post/detail_page.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/models/product_class.dart';

import 'package:dangmoog/constants/category_list.dart';
import 'package:dangmoog/utils/convert_money_format.dart';

import 'package:dangmoog/providers/provider.dart';

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

        if (mounted) {
          setState(() {
            lockerProducts.addAll(newLockerProducts); // Prepend locker products
            isLoadingProductList = false;
          });
        }
      } else {
        throw Exception('Failed to load locker products');
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
      if (checkpoint != -1) {
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

  // 게시물 추가하기 버튼
  Widget addPostButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '거래 방식을 \n선택해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _customButton(
                            context, '직접거래', 'assets/images/direct_icon.png',
                            () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddPostPage(title: '직접거래 등록'),
                            ),
                          );
                        }),
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
                      width: 300,
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
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
      width: 100,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFFE20529),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
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
          cacheExtent: 1000,
          controller: _scrollController,
          itemCount: lockerProducts.length + products.length,
          itemBuilder: (context, index) {
            if (index < lockerProducts.length) {
              // Build locker product card
              return ChangeNotifierProvider<ProductModel>.value(
                value: lockerProducts[index],
                child: _lockerProductCard(context, lockerProducts[index]),
              );
            }
            int regularIndex = index - lockerProducts.length;
            if (regularIndex < products.length) {
              return ChangeNotifierProvider<ProductModel>.value(
                value: products[regularIndex],
                child: _postCard(context),
              );
            } else if (isLoadingProductList) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container();
            }
          },
          separatorBuilder: (context, i) {
            return const Divider(
              height: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _lockerProductCard(BuildContext context, ProductModel product) {
    double paddingValue = MediaQuery.of(context).size.width * 0.042;

    return InkWell(
      onTap: () {
        // Logic when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LockerValPage(product),
          ),
        );
        // Navigator.push(
        //   context,
        //   PageRouteBuilder(
        //     transitionDuration: const Duration(milliseconds: 400),
        //     pageBuilder: (context, animation, secondaryAnimation) =>
        //         ProductDetailPage(
        //           postId: product.postId,
        //         ),
        //     transitionsBuilder:
        //         (context, animation, secondaryAnimation, child) {
        //       var previousPageOffsetAnimation =
        //       Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
        //           .chain(CurveTween(curve: Curves.decelerate))
        //           .animate(animation);
        //
        //       return SlideTransition(
        //         position: previousPageOffsetAnimation,
        //         child: ProductDetailPage(
        //           postId: product.postId,
        //         ),
        //       );
        //     },
        //   ),
        // );
      },
      child: Padding(
        padding: EdgeInsets.all(paddingValue),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE20529), // Color for validation border
                  width: 3.0, // Thickness of the validation border
                ),
                borderRadius: BorderRadius.circular(8), // Border radius
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFFCE6EA),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '앗! 아직 인증하지 않은 게시물이 있어요.\n인증을 진행하고 게시물을 업로드하시겠어요?',
                                style: TextStyle(
                                  color: Color(0xFF302E2E),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () {
                                // Navigate to LockerValPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LockerValPage(product),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFFE20529),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      6), // Border radius of the button
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 4.0),
                                    child: Text('인증하기'),
                                  ),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.5, // Reduced opacity as per the original code
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildProductImage(context, product),
                          _buildProductDetails(context, product),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: paddingValue,
              right: paddingValue,
              child: ProductTimer(createTime: product.createTime),
            ),
          ],
        ),
      ),
    );
  }

  // 게시물 리스트에서 게시물 하나에 대한 위젯
  Widget _postCard(BuildContext context) {
    return Consumer<ProductModel>(
      builder: (context, product, child) {
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignInside,
            color: const Color(0xffF1F1F1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageCache.containsKey(product.representativePhotoId)
              ? Image.network(
                  imageCache[product.representativePhotoId]!,
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
              : product.representativePhotoId == 0
                  ? Image.asset(
                      "assets/images/sample.png",
                      width: 90,
                      fit: BoxFit.cover,
                    )
                  : FutureBuilder<Response>(
                      future:
                          apiService.loadPhoto(product.representativePhotoId),
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
                            '/assets/images/sample.png',
                            fit: BoxFit.cover,
                          );
                        } else if (snapshot.hasData) {
                          Map<String, dynamic> data = snapshot.data!.data;
                          String imageUrl = data["url"];
                          imageCache[product.representativePhotoId] = imageUrl;
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              print("이미지 오류");
                              return Image.asset(
                                '/assets/images/sample.png',
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
            // LikeChatCount(product: product)
          ],
        ),
      ),
    );
  }

  // 게시글 제목, 카테고리, 시간, 가격 표시
  Widget _buildProductTexts(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 2,
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
            "${categeryItems[product.categoryId - 1]} | ${timeAgo(product.createTime)}",
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
                    convertoneyFormat(product.price),
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
              dealStatus == 1 ? '예약중' : '판매완료',
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
