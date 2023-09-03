import 'package:flutter/material.dart';

class ProductListModel extends ChangeNotifier {
  final int postId;
  final String title;
  final int price;
  final String image;
  final String category;
  final DateTime uploadTime;
  final String saleMethod;
  final String userName;
  final int dealStatus;
  final int viewCount;
  final int chatCount;
  final int likeCount;

  bool _isFavorited;

  ProductListModel({
    required this.postId,
    required this.title,
    required this.price,
    required this.image,
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
