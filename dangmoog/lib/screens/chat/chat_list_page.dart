import 'package:flutter/material.dart';

import 'package:dangmoog/screens/chat/chat_list_cell.dart';
import 'package:dangmoog/models/chat_class.dart';

import 'dart:convert';
import 'package:flutter/services.dart';

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

  Color activeButtonColor = const Color(0xFF552619);
  Color activeTextColor = Colors.white;

  Color deActiveButtonColor = Colors.white;
  Color deActiveTextColor = const Color(0xFF552619);

  late Future<List<Chat>> futureSellChat;
  late Future<List<Chat>> futureBuyChat;

  @override
  void initState() {
    super.initState();

    futureSellChat = _loadChatListFromAsset('assets/chat_sell_list.json');
    futureBuyChat = _loadChatListFromAsset('assets/chat_buy_list.json');
  }

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
                  _buildChatListFutureBuilder(futureSellChat),
                  _buildChatListFutureBuilder(futureBuyChat)
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

  final Color activeButtonColor = const Color(0xFF552619);
  final Color activeTextColor = Colors.white;

  final Color deActiveButtonColor = Colors.white;
  final Color deActiveTextColor = const Color(0xFF552619);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: screenSize.width * 0.91,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenSize.width * 0.455,
            height: 45,
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
                  color: Color(0xFF552619),
                  width: 1.0,
                ),
              ),
              onPressed: onSellPressed,
              child: Center(
                child: Text(
                  '판매',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: sellSelected ? activeTextColor : deActiveTextColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: screenSize.width * 0.455,
            height: 45,
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
                  color: Color(0xFF552619),
                  width: 1.0,
                ),
              ),
              onPressed: onBuyPressed,
              child: Center(
                child: Text(
                  '구매',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: sellSelected ? deActiveTextColor : activeTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildChatListFutureBuilder(Future<List<Chat>> future) {
  return FutureBuilder<List<Chat>>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat list!'));
        }
        return ChatListView(
          chat: snapshot.data!,
        );
      }
      return const Center(child: CircularProgressIndicator());
    },
  );
}

class ChatListView extends StatelessWidget {
  final List<Chat> chat;

  const ChatListView({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: chat.length,
        itemBuilder: (context, index) {
          final chatItem = chat[index];
          return ChatCell(
            userNickName: chatItem.userNickName,
            lastMsg: chatItem.lastMsg,
            productId: chatItem.productId,
            userId: chatItem.userId,
            chatId: chatItem.chatId,
            lastDate: chatItem.lastDate,
          );
        },
        separatorBuilder: (context, _) {
          return const Divider(
            color: Color(0xFFCCBEBA),
          );
        });
  }
}
