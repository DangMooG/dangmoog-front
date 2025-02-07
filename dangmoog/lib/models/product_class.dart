// /models/product_class.dart
import 'package:flutter/material.dart';

class ProductModel extends ChangeNotifier {
  final String title;
  final int price;
  final String description;
  final int categoryId;
  int status; // 예약중 판매중 거래완료
  final int accountId;
  final String userName;
  final int representativePhotoId;
  final int postId;
  int likeCount;
  int chatCount;
  final DateTime createTime;
  final DateTime updateTime;
  // 직접 거래 0
  // 사물함 거래 인증안된 상태 1
  // 사물함 거래 인증된 상태 2
  int useLocker;
  bool _isFavorited = false;
  bool isUpdatingLike = false;
  bool isTimeEnded;

  ProductModel({
    required this.title,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.status,
    required this.accountId,
    required this.userName,
    required this.representativePhotoId,
    required this.postId,
    required this.likeCount,
    required this.chatCount,
    required this.createTime,
    required this.updateTime,
    required this.useLocker,
    required bool isFavorited,
    this.isTimeEnded = false,
  }) : _isFavorited = isFavorited;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title'] ?? 'Default Title',
      price: json['price'] ?? 0,
      description: json['description'] ?? 'Default Description',
      categoryId: json['category_id'] ?? 0,
      status: json['status'] ?? 0,
      useLocker: json['use_locker'] ?? 0,
      accountId: json['account_id'] ?? 0,
      userName: json['username'] ?? 'Default Username',
      representativePhotoId: json['representative_photo_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      likeCount: json['liked'] ?? 0,
      chatCount: json['room_count'] ?? 0,
      createTime:
          DateTime.tryParse(json['create_time'].toString()) ?? DateTime.now(),
      updateTime:
          DateTime.tryParse(json['update_time'].toString()) ?? DateTime.now(),
      isFavorited: json['isFavorited'] ?? false,
      isTimeEnded: json['isTimeEnded'] ?? false,
    );
  }

  bool get isFavorited => _isFavorited;

  set isFavorited(bool value) {
    _isFavorited = value;
    notifyListeners();
  }
}
