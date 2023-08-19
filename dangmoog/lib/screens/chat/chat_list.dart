import 'package:flutter/material.dart';

// Chat Celll Widget
import 'package:dangmoog/screens/chat/chat_cell.dart';

// Chat Item Class
import 'package:dangmoog/models/chat_class.dart';

// Chat Mock Data
import 'package:dangmoog/constants/mock_data/chat_list_mock.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  bool sellSelected = true;

  Color sellButtonColor = const Color(0xFF552619);
  Color buyButtonColor = Colors.white;

  Color sellTextColor = Colors.white;
  Color buyTextColor = const Color(0xFF552619);

  List<Chat> convertMockToChat(List<dynamic> mockData) {
    return mockData.map((item) {
      var data = item as Map<String, dynamic>;
      return Chat(
        userNickName: data['userNickName'],
        lastMsg: data['lastMsg'],
        productId: data['productId'] ?? 0,
        userId: data['userId'] ?? 0,
        chatId: data['chatId'],
        lastDate: data['lastDate'],
      );
    }).toList();
  }

  late List<Chat> sellChat;
  late List<Chat> buyChat;

  @override
  void initState() {
    super.initState();

    sellChat = convertMockToChat(sellChatListMock);
    buyChat = convertMockToChat(buyChatListMock);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
            SizedBox(
              width: screenSize.width * 0.91,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width * 0.455,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sellButtonColor,
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
                      onPressed: () => {
                        setState(
                          () {
                            if (sellSelected == false) {
                              sellButtonColor = const Color(0xFF552619);
                              buyButtonColor = Colors.white;

                              sellTextColor = Colors.white;
                              buyTextColor = const Color(0xFF552619);

                              sellSelected = true;
                            }
                          },
                        ),
                      },
                      child: Center(
                        child: Text(
                          '판매',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: sellTextColor,
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
                        backgroundColor: buyButtonColor,
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
                      onPressed: () => {
                        setState(
                          () {
                            if (sellSelected == true) {
                              sellButtonColor = Colors.white;
                              buyButtonColor = const Color(0xFF552619);

                              sellTextColor = const Color(0xFF552619);
                              buyTextColor = Colors.white;

                              sellSelected = false;
                            }
                          },
                        ),
                      },
                      child: Center(
                        child: Text(
                          '구매',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: buyTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sellSelected ? sellChat.length : buyChat.length,
                itemBuilder: sellSelected
                    ? (context, index) {
                        final chatItem = sellChat[index];

                        return ChatCell(
                          userNickName: chatItem.userNickName,
                          lastMsg: chatItem.lastMsg,
                          productId: chatItem.productId,
                          userId: chatItem.userId,
                          chatId: chatItem.chatId,
                          lastDate: chatItem.lastDate,
                        );
                      }
                    : (context, index) {
                        final chatItem = buyChat[index];
                        return ChatCell(
                          userNickName: chatItem.userNickName,
                          lastMsg: chatItem.lastMsg,
                          productId: chatItem.productId,
                          userId: chatItem.userId,
                          chatId: chatItem.chatId,
                          lastDate: chatItem.lastDate,
                        );
                      },
              ),
            )
          ],
        ),
      ),
    );
  }
}
