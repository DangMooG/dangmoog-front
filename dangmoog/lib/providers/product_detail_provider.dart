import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductDetailProvider with ChangeNotifier {
  final ApiService apiService;
  ProductModel? product;
  bool isLoading = true;
  List<String> images = [];
  bool chatAvailable = true;

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
        await _checkChatAvailability();
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

  // 새로운 메서드: Chat 가능 여부 확인
  Future<void> _checkChatAvailability() async {
    const storage = FlutterSecureStorage();
    String? userId = await storage.read(key: "userId");

    if (product != null &&
        userId != null &&
        product!.accountId.toString() == userId.toString()) {
      chatAvailable = false;
    } else if (product!.status != 0) {
      chatAvailable = false;
    } else if (product?.userName=='하우스') {
      chatAvailable = false;
    }
    else {
      chatAvailable = true;
    }
  }

  List<int> likedProductIds = [];

  Future<void> _checkIfFavorited(int postId) async {
    try {
      final response = await apiService.getLikePostList();
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
    } catch (e) {
      rethrow;
    }
  }
}
