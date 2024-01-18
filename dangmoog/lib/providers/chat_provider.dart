import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatDetailMessageModel> _chatContents = [];
  List<ChatDetailMessageModel> get chatContents => _chatContents;

  String _roomId = "";
  String get roomId => _roomId;

  bool? _imbuyer;
  bool? get imbuyer => _imbuyer;

  // 상세 게시글에서 상세 채팅방 접근해서 첫 채팅 시, 내 채팅방 목록 새로 불러오기
  late VoidCallback addNewChatList;

  void setChatContents(List<ChatDetailMessageModel> contents) {
    _chatContents.addAll(contents);

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

  void updateNewChatList(VoidCallback callback) {
    addNewChatList = callback;
  }
}
