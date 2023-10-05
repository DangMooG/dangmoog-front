// /models/product_class.dart

import 'package:flutter/material.dart';

class ProductModel extends ChangeNotifier {
  final int postId;
  final String title;
  final String description;
  final int price;
  final List<String> images;
  final String category;
  final DateTime uploadTime;
  final String saleMethod;
  final String userName;
  final int dealStatus; // "거래 중" "예약 중" "거래 완료" ""
  final int viewCount;
  final int chatCount;
  final int likeCount;
  bool _isFavorited;

  ProductModel({
    required this.postId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.uploadTime,
    required this.saleMethod,
    required this.userName,
    required this.dealStatus,
    required this.viewCount,
    required this.chatCount,
    required this.likeCount,
    bool? isFavorited,
  }) : _isFavorited = isFavorited ?? false;

  bool get isFavorited => _isFavorited;

  set isFavorited(bool value) {
    _isFavorited = value;
    notifyListeners();
  }
}
