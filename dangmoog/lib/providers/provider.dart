import 'dart:io';

import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _inputEmail = '';

  String get inputEmail => _inputEmail;

  String _nickname = '';

  String get nickname => _nickname;

  File? userImage;

  String _account = '';

  String get account => _account;

  void setEmail(String inputEmail) {
    _inputEmail = inputEmail;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  void setAccount(String account) {
    _account = account;
    notifyListeners();
  }

  void updateVariable(String newValue) {
    _nickname = newValue;
    notifyListeners(); // 상태 업데이트를 구독하는 위젯에 알리기
  }

  void setUserImage(File newImage) {
    userImage = newImage;
    notifyListeners();
  }
}
