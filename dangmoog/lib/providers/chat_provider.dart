import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatDetailContent> _chatContents = [];

  List<ChatDetailContent> get chatContents => _chatContents;

  void setChatContents(List<ChatDetailContent> contents) {
    _chatContents = contents;
    notifyListeners();
  }

  void addChatContent(ChatDetailContent newMessage) {
    print(newMessage.chatText);

    _chatContents.add(newMessage);
    notifyListeners();
  }
}
