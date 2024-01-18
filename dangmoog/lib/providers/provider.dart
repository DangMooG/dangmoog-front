import 'dart:io';

import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _inputEmail = '';

  String get inputEmail => _inputEmail;

  String _nickname = '';

  String get nickname => _nickname;

  String userImage = '';

  String _account = '';

  String get account => _account;

  late int _isButtonDisabled = 1;

  int get isButtonDisabled => _isButtonDisabled;

  List<String> _myPostListId = <String>[];

  List<String> get myPostListId => _myPostListId;

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

  void setUserImage(String newImage) {
    userImage = newImage;
    notifyListeners();
  }

  void updateNicknameButton(int newValue) {
    _isButtonDisabled = newValue;
    notifyListeners();
  }

  void setMyPostListId(List<String> myPostListId) {
    _myPostListId = myPostListId;
    notifyListeners();
  }

  void getMyPostListId() async {
    try {
      Response response = await ApiService().getMyPostListId();

      if (response.statusCode == 200) {
        List<dynamic> dynamicList =
            response.data["result"].map((item) => item.toString()).toList();
        List<String> stringList =
            dynamicList.map((item) => item.toString()).toList();

        setMyPostListId(stringList);
      }
    } catch (e) {
      print(e);
    }
  }
}
