import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/screens/chat/chat_list/chat_list_cell.dart';
import 'package:dangmoog/models/chat_class.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<List<Chat>> _loadChatListFromAsset(String domain) async {
  final String jsonChatList = await rootBundle.loadString(domain);
  final List<dynamic> jsonChatListResponse = json.decode(jsonChatList);

  DateTime splitDate(String chatItem) {
    var date = chatItem.split('-').map((e) => int.parse(e)).toList();

    return DateTime(date[0], date[1], date[2]);
  }

  return jsonChatListResponse
      .map((chatItem) => Chat(
            userNickName: chatItem['userNickName'],
            lastMsg: chatItem['lastMsg'],
            productId: chatItem['productId'],
            userId: chatItem['userId'],
            chatId: chatItem['chatId'],
            lastDate: splitDate(chatItem['lastDate']),
          ))
      .toList();
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool sellSelected = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ChatSelectionButton(
              sellSelected: sellSelected,
              onSellPressed: () {
                setState(() {
                  if (!sellSelected) {
                    sellSelected = true;
                  }
                });
              },
              onBuyPressed: () {
                setState(() {
                  if (sellSelected) {
                    sellSelected = false;
                  }
                });
              },
            ),
            Expanded(
              child: IndexedStack(
                index: sellSelected ? 0 : 1,
                children: [
                  Consumer<ChatListProvider>(
                    builder: (context, chatListProvider, child) {
                      return ChatListView(
                        chatList: List.from(chatListProvider.sellChatList),
                      );
                    },
                  ),
                  Consumer<ChatListProvider>(
                    builder: (context, chatListProvider, child) {
                      return ChatListView(
                        chatList: List.from(chatListProvider.buyChatList),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatSelectionButton extends StatelessWidget {
  final bool sellSelected;
  final Function() onSellPressed;
  final Function() onBuyPressed;

  const ChatSelectionButton({
    super.key,
    required this.sellSelected,
    required this.onSellPressed,
    required this.onBuyPressed,
  });

  final Color activeButtonColor = const Color(0xFFE20529);
  final Color activeTextColor = Colors.white;
  final Color activeUnreadColor = const Color(0xffF28C9D);

  final Color deActiveButtonColor = Colors.white;
  final Color deActiveTextColor = const Color(0xffA19E9E);
  final Color deActiveUnreadColor = const Color(0xffD3D2D2);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: screenSize.width * 0.91,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenSize.width * 0.455,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    sellSelected ? activeButtonColor : deActiveButtonColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                side: const BorderSide(
                  color: Color(0xFFE20529),
                  width: 1.0,
                ),
              ),
              onPressed: onSellPressed,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    '판매',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: sellSelected ? activeTextColor : deActiveTextColor,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 28,
                    child: Consumer<ChatListProvider>(
                        builder: (context, chatProvider, _) {
                      int sellUnreadCount = chatProvider.sellUnreadCount;

                      if (sellUnreadCount == 0) {
                        return const SizedBox.shrink();
                      }

                      return ClipOval(
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sellSelected
                                ? activeUnreadColor
                                : deActiveUnreadColor,
                          ),
                          child: Text(
                            '$sellUnreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: screenSize.width * 0.455,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    sellSelected ? deActiveButtonColor : activeButtonColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                side: const BorderSide(
                  color: Color(0xFFE20529),
                  width: 1.0,
                ),
              ),
              onPressed: onBuyPressed,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    '구매',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: sellSelected ? deActiveTextColor : activeTextColor,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 28,
                    child: Consumer<ChatListProvider>(
                        builder: (context, chatProvider, _) {
                      int buyUnreadCount = chatProvider.buyUnreadCount;
                      // 데이터가 비어 있으면 아무것도 반환하지 않음
                      if (buyUnreadCount == 0) {
                        return const SizedBox.shrink();
                      }

                      return ClipOval(
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sellSelected
                                ? deActiveUnreadColor
                                : activeUnreadColor,
                          ),
                          child: Text(
                            '$buyUnreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListView extends StatefulWidget {
  final List<ChatListCell> chatList;

  const ChatListView({
    super.key,
    required this.chatList,
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: UniqueKey(),
      itemCount: widget.chatList.length,
      itemBuilder: (context, index) {
        ChatListCell chatItem = widget.chatList[index];
        return ChatCell(
          key: ValueKey(chatItem.roomId),
          roomId: chatItem.roomId,
          userName: chatItem.userName,
          userProfileUrl: chatItem.userProfileUrl,
          photoId: chatItem.photoId,
          lastMessage: chatItem.lastMessage,
          updateTime: chatItem.updateTime,
          unreadCount: chatItem.unreadCount,
          imBuyer: chatItem.imBuyer,
          postId: chatItem.postId,
        );
      },
      separatorBuilder: (context, _) {
        return const Divider(
          color: Color(0xFFD3D2D2),
        );
      },
    );
  }
}
