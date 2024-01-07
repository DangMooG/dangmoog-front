import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatDetailMessageModel> _chatContents = [];

  List<ChatDetailMessageModel> get chatContents => _chatContents;

  String _roomId = "";

  String get roomId => _roomId;

  bool? _imbuyer;

  bool? get imbuyer => _imbuyer;

  void setChatContents(List<ChatDetailMessageModel> contents) {
    _chatContents = contents;
    notifyListeners();
  }

  void addChatContent(ChatDetailMessageModel newMessage) {
    _chatContents.add(newMessage);
    notifyListeners();
  }

  void setRoomId(String roomId) {
    _roomId = roomId;
    notifyListeners();
  }

  void setImBuyer(bool imbuyer) {
    _imbuyer = imbuyer;
    notifyListeners();
  }

  void resetChatProvider() {
    _chatContents = [];
    _roomId = "";
    _imbuyer = null;
    notifyListeners();
  }
}
