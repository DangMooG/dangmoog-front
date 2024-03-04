import 'package:dangmoog/providers/post_list_scroll_provider.dart';
import 'package:dangmoog/utils/time_ago.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:dangmoog/screens/post/detail_page.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/constants/category_house.dart';
import 'package:dangmoog/utils/convert_money_format.dart';

class HousePage extends StatefulWidget {
  const HousePage({Key? key}) : super(key: key);

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // pagination을 위한 변수
  int checkpoint = 0;

  List<ProductModel> houseProducts = [];
  bool isLoadingProductList = false;
  String? selectedCategory = houseItems[0];

  // 이미지 캐싱을 위한 변수
  Map<int, String> imageCache = {};

  Future<void> _loadHouseProducts({String? categoryName}) async {
    if (isLoadingProductList) return; // 중복 호출 방지
    if (mounted) {
      setState(() {
        isLoadingProductList = true;
      });
    }

    try {
      Response response;
      if (categoryName == null) {
        // Load without category filter
        response = await apiService.loadHouseProductListWithPaging(checkpoint);
      } else {
        // Convert category name to index assuming `houseItems` contains all categories including 'All' at index 0
        int categoryIndex = houseItems.indexOf(categoryName);
        // Ensure categoryIndex is valid and not pointing to 'All'
        if (categoryIndex > 0) {
          response = await apiService.loadHouseProductListWithCategoryPaging(
              checkpoint, categoryIndex);
        } else {
          // Fallback to loading without category filter
          response =
              await apiService.loadHouseProductListWithPaging(checkpoint);
        }
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data["items"];
        List<ProductModel> newProducts =
            items.map((item) => ProductModel.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            checkpoint = data["next_checkpoint"];
            houseProducts.addAll(newProducts);
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
        // Assuming `-1` indicates no more products to load.
        _lastMaxScrollExtent = _scrollController.position.maxScrollExtent;
        _loadHouseProducts(categoryName: selectedCategory);
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
    await _loadHouseProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String categoryName) {
    // Determine if the category is being deselected
    final isDeselecting = selectedCategory == categoryName;

    setState(() {
      // Toggle category selection
      selectedCategory = isDeselecting ? houseItems[0] : categoryName;
      checkpoint = 0; // Reset pagination checkpoint
      _lastMaxScrollExtent = 0;
      houseProducts.clear(); // Clear existing products to load new set
    });

    // Load products based on the updated selection
    _loadHouseProducts(categoryName: selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            size: 24,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "하우스 중고장터",
          style: TextStyle(
            color: Color(0xff302E2E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50, // Adjust based on your design
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: houseItems.length,
                itemBuilder: (context, index) {
                  var category = houseItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 4.0),
                    child: OutlinedButton(
                      onPressed: () => _onCategorySelected(category),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: selectedCategory == category
                            ? Colors.white
                            : const Color(0xFF514E4E),
                        backgroundColor: selectedCategory == category
                            ? const Color(0xFF514E4E)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          // Use RoundedRectangleBorder for customizing border radius
                          borderRadius: BorderRadius.circular(
                              18), // Set the border radius here, 4 is just an example
                        ),
                        side: BorderSide(
                          color: selectedCategory == category
                              ? Colors.transparent
                              : const Color(0xFFD3D2D2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      child: Text(
                        category.isEmpty ? '전체' : category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child:
                Platform.isIOS ? _buildIOSListView() : _buildDefaultListView(),
          )
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
      child: _postListView(),
    );
  }

  Widget _buildDefaultListView() {
    return _postListView();
  }

  // 게시물 리스트 위젯
  Widget _postListView() {
    if (houseProducts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (mounted) {
            setState(() {
              checkpoint = 0;
              selectedCategory = houseItems[0];

              // _lastMaxScrollExtent = 0;
              houseProducts.clear();
            });
          }
          // houseProducts.clear();
          await _loadHouseProducts();
        },
        child: Center(
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Center(
                child: Text(
              '등록된 게시글이 없습니다.',
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
            selectedCategory = houseItems[0];

            // _lastMaxScrollExtent = 0;
            houseProducts.clear();
          });
        }
        // houseProducts.clear();
        await _loadHouseProducts();
      },
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          cacheExtent: 3000,
          physics: const AlwaysScrollableScrollPhysics(),
          addAutomaticKeepAlives: true,
          controller: _scrollController,
          itemCount: houseProducts.length,
          itemBuilder: (context, index) {
            return ChangeNotifierProvider<ProductModel>.value(
              value: houseProducts[index],
              child: _postCard(context),
            );
          },
          separatorBuilder: (context, i) {
            return const Divider(
                height: 1); // Your existing divider for other items
          },
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
            "${houseItems[product.categoryId]} | ${timeAgo(product.createTime)}",
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
