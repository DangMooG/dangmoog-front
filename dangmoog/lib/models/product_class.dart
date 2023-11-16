// /models/product_class.dart
import 'package:flutter/material.dart';

class ProductModel extends ChangeNotifier {
  final String title;
  final int price;
  final String description;
  final int categoryId;
  int status; // 예약중 판매중 거래완료
  final int accout_id;
  final String userName;
  final int representativePhotoId;
  final int postId;
  int likeCount;
  final DateTime createTime;
  final DateTime updateTime;
  int useLocker; //사물함 1 or 직접 0
  bool _isFavorited = false;
  bool isUpdatingLike = false;


  ProductModel({
    required this.title,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.status,
    required this.accout_id,
    required this.userName,
    required this.representativePhotoId,
    required this.postId,
    required this.likeCount,
    required this.createTime,
    required this.updateTime,
    required this.useLocker,
    required bool isFavorited,
  }):_isFavorited = isFavorited;


  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title'] ?? 'Default Title',
      price: json['price'] ?? 0,
      description: json['description'] ?? 'Default Description',
      categoryId: json['category_id'] ?? 0,
      status: json['status'] ?? 0,
      useLocker: json['saleMethod'] ?? 0,
      accout_id: json['account_id'] ?? 0,
      userName: json['username'] ?? 'Default Username',
      representativePhotoId: json['representative_photo_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      likeCount: json['liked'] ?? 0,
      createTime: DateTime.tryParse(json['create_time'].toString()) ?? DateTime.now(),
      updateTime: DateTime.tryParse(json['update_time'].toString()) ?? DateTime.now(),
      isFavorited: json['isFavorited'] ?? false,
    );
  }


  bool get isFavorited => _isFavorited;

  set isFavorited(bool value) {
    _isFavorited = value;
    notifyListeners();
  }


}


