import 'package:flutter/material.dart';

class PostListScrollProvider with ChangeNotifier {
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  void setScrollController(ScrollController contoller) {
    _scrollController = contoller;
    notifyListeners();
  }

  void scrollToTop() {
    if (_scrollController!.position.pixels == 0) {
      return;
    }
    _scrollController!.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
