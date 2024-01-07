import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:flutter/material.dart';

class ChatListProvider with ChangeNotifier {
  List<ChatListCell> _sellChatList = [];
  List<ChatListCell> _buyChatList = [];

  List<ChatListCell> get sellChatList => _sellChatList;
  List<ChatListCell> get buyChatList => _buyChatList;

  void setChatList(
      List<ChatListCell> sellChatList, List<ChatListCell> buyChatList) {
    _sellChatList = _sortChatListByUpdateTime(sellChatList);
    _buyChatList = _sortChatListByUpdateTime(buyChatList);
    notifyListeners();
  }

  // 1. 상세 채팅방 밖에서 채팅이 온 경우
  // 2. 상세 채팅방 안이지만, 현재 채팅방의 채팅이 아닌 경우
  void updateChatList(
      int index, String lastMessage, DateTime updateTime, bool isBuyChatList) {
    if (isBuyChatList) {
      _buyChatList[index].lastMessage = lastMessage;
      _buyChatList[index].updateTime = updateTime;
      _buyChatList[index].unreadCount = _buyChatList[index].unreadCount + 1;
      _buyChatList = _sortChatListByUpdateTime(_buyChatList);
    } else if (!isBuyChatList) {
      _sellChatList[index].lastMessage = lastMessage;
      _sellChatList[index].updateTime = updateTime;
      _sellChatList[index].unreadCount = _sellChatList[index].unreadCount + 1;
      _sellChatList = _sortChatListByUpdateTime(_sellChatList);
    }
  }

  // 채팅 목록이 업데이트되면 update time을 기준으로 정렬
  // provider 내부에서만 실행하기
  List<ChatListCell> _sortChatListByUpdateTime(List<ChatListCell> chatList) {
    List<ChatListCell> sortedList = List.from(chatList);
    sortedList.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return sortedList;
  }
}
