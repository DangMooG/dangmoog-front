// /models/product_class.dart


import 'package:flutter/material.dart';

class Product extends ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final DateTime uploadTime;
  final String comments;
  final String saleMethod;
  final String user;
  int viewCount;
  int likes;
  bool _isFavorited;

  Product({

    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.uploadTime,
    required this.comments,
    required this.saleMethod,
    required this.user, //id 도 만들기
    this.viewCount = 0,
    bool?isFavorited,
    this.likes = 0,
  }): _isFavorited = isFavorited ?? false;

  bool get isFavorited => _isFavorited;

  set isFavorited(bool value) {
    _isFavorited = value;
    notifyListeners();
  }
}



