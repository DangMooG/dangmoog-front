import 'dart:io';

import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String _inputEmail = '';

  String get inputEmail => _inputEmail;

  String _nickname = '';

  String get nickname => _nickname;

  File? userImage;

  String _account = '';

  String get account => _account;

  late bool _isButtonDisabled = true;

  bool get isButtonDisabled => _isButtonDisabled;

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

  void setUserImage(File newImage) {
    userImage = newImage;
    notifyListeners();
  }

  void updateBoolValue(bool newValue) {
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
