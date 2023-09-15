import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _email = '';

  String get email => _email;

  String _nickname = '';

  String get nickname => _nickname;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }
}
