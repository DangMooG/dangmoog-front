import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:flutter/material.dart';

class ChatListProvider with ChangeNotifier {
  List<ChatListCell> _sellChatList = [];
  List<ChatListCell> _buyChatList = [];

  List<ChatListCell> get sellChatList => _sellChatList;
  List<ChatListCell> get buyChatList => _buyChatList;

  void setChatList(
      List<ChatListCell> setChatList, List<ChatListCell> buyChatList) {
    _sellChatList = _sortChatListByUpdateTime(setChatList);
    _buyChatList = _sortChatListByUpdateTime(buyChatList);
    notifyListeners();
  }

  // 채팅 목록이 업데이트되면 update time을 기준으로 정렬
  // provider 내부에서만 실행하기
  List<ChatListCell> _sortChatListByUpdateTime(List<ChatListCell> chatList) {
    List<ChatListCell> sortedList = List.from(chatList);
    sortedList.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return sortedList;
  }
}
