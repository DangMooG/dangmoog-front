import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatDetailMessageModel> _chatContents = [];
  List<ChatDetailMessageModel> get chatContents => _chatContents;

  String? _roomId;
  String? get roomId => _roomId;

  bool? _imBuyer;
  bool? get imBuyer => _imBuyer;

  int? _postId;
  int? get postId => _postId;

  String? _userName;
  String? get userName => _userName;

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

  void setRoomId(String? roomId) {
    _roomId = roomId;
    notifyListeners();
  }

  void setImBuyer(bool? imbuyer) {
    _imBuyer = imbuyer;
    notifyListeners();
  }

  void setPostId(int? postId) {
    _postId = postId;
    notifyListeners();
  }

  void setuserName(String? userName) {
    _userName = userName;
    notifyListeners();
  }

  void getInChatRoom(bool? imbuyer, int? postId, String? userName) {
    _chatContents = [];
    _imBuyer = imbuyer;
    _postId = postId;
    _userName = userName;
    notifyListeners();
  }

  void resetChatProvider() {
    _chatContents = [];
    _roomId = null;
    _imBuyer = null;
    _postId = null;
    _userName = null;
    notifyListeners();
  }

  void updateNewChatList(VoidCallback callback) {
    addNewChatList = callback;
  }
}
