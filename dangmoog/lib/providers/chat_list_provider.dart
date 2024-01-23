import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:flutter/material.dart';

class ChatListProvider with ChangeNotifier {
  List<ChatListCell> _sellChatList = [];
  List<ChatListCell> _buyChatList = [];

  List<ChatListCell> get sellChatList => _sellChatList;
  List<ChatListCell> get buyChatList => _buyChatList;

  int _sellUnreadCount = 0;
  int _buyUnreadCount = 0;

  int get sellUnreadCount => _sellUnreadCount;
  int get buyUnreadCount => _buyUnreadCount;

  void setChatList(
      List<ChatListCell> sellChatList, List<ChatListCell> buyChatList) {
    _sellChatList = _sortChatListByUpdateTime(sellChatList);
    _buyChatList = _sortChatListByUpdateTime(buyChatList);
    updateUnreadCount();
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
      _buyChatList = List.from(_sortChatListByUpdateTime(_buyChatList));
    } else if (!isBuyChatList) {
      _sellChatList[index].lastMessage = lastMessage;
      _sellChatList[index].updateTime = updateTime;
      _sellChatList[index].unreadCount = _sellChatList[index].unreadCount + 1;
      _sellChatList = List.from(_sortChatListByUpdateTime(_sellChatList));
    }
    updateUnreadCount();
    notifyListeners();
  }

  void resetUnreadCount(int index, bool isBuyChatList) {
    if (isBuyChatList) {
      _buyChatList[index].unreadCount = 0;
    } else if (!isBuyChatList) {
      _sellChatList[index].unreadCount = 0;
    }
    updateUnreadCount();
    notifyListeners();
  }

  void updateUnreadCount() {
    _sellUnreadCount =
        _sellChatList.fold(0, (sum, item) => sum + item.unreadCount);
    _buyUnreadCount =
        _buyChatList.fold(0, (sum, item) => sum + item.unreadCount);
  }

  // 채팅 목록이 업데이트되면 update time을 기준으로 정렬
  // provider 내부에서만 실행하기
  List<ChatListCell> _sortChatListByUpdateTime(List<ChatListCell> chatList) {
    List<ChatListCell> sortedList = List.from(chatList);
    sortedList.sort((a, b) => b.updateTime.compareTo(a.updateTime));
    return sortedList;
  }
}
