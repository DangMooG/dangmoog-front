import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/websocket_provider.dart';

import 'package:dangmoog/screens/mypage/like/like_mainpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list_page.dart';
import 'package:dangmoog/screens/post/main_page.dart';
import 'package:dangmoog/screens/temp/temp_page.dart';

import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/nav_bar.dart';
import 'package:provider/provider.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int currentTabIndex = 0;

  final List<Widget> _bodyPage = <Widget>[
    const MainPage(key: ValueKey("MainPage")),
    const LikeMainPage(key: ValueKey("LikePage")),
    const ChatListPage(key: ValueKey("ChatListPage")),
    const MyPage(
      key: ValueKey("MyPage"),
      nickname: '',
      email: '',
    )
  ];

  late SocketClass socketChannel;

  void _handleMessageReceived(String message) {
    final roomId = message.substring(0, 36);
    final chatMessage = message.substring(36);

    final chatContent = ChatDetailContent(
      chatDateTime: DateTime.now(),
      chatText: chatMessage,
      isMe: false,
    );
    Provider.of<ChatProvider>(context, listen: false)
        .addChatContent(chatContent);
  }

  void _getAllMyChatList() async {
    Response response = await ApiService().getMyRoomIds();
    if (response.statusCode == 200) {
      final roomIdList = [
        for (var id in response.data["room_ids"]) id.toString()
      ];

      Response response2 = await ApiService().getChatUserNames(roomIdList);
      if (response2.statusCode == 200) {
        final userNameList = response2.data["usernames"];
        final userProfileUrlList = response2.data["profiles"];

        Response response3 =
            await ApiService().getAllMyChatRoomStatus(roomIdList);
        if (response3.statusCode == 200) {
          final lastMessageList = response3.data["last_messages"];
          final updateTimeList = response3.data["update_times"];
          final unreadCountList = response3.data["counts"];

          Response response4 =
              await ApiService().getAllMyChatRoomInfo(roomIdList);
          if (response4.statusCode == 200) {
            final postIdList = response4.data["post_id"];
            final imBuyerList = response4.data["iam_buyer"];
            final photoIdList = response4.data["repr_photo_id"];

            List<ChatListCell> combinedList = [];
            for (int i = 0; i < roomIdList.length; i++) {
              if (lastMessageList[i] != null) {
                combinedList.add(
                  ChatListCell(
                    roomId: roomIdList[i],
                    userName: userNameList[i],
                    userProfileUrl: userProfileUrlList[i],
                    photoId: photoIdList[i],
                    lastMessage: lastMessageList[i],
                    updateTime: DateTime.parse(updateTimeList[i]),
                    unreadCount: unreadCountList[i],
                    imBuyer: imBuyerList[i],
                    postId: postIdList[i],
                  ),
                );
              }
            }

            List<ChatListCell> buyChatList = [];
            List<ChatListCell> sellChatList = [];
            for (var chat in combinedList) {
              if (chat.imBuyer) {
                buyChatList.add(chat);
              } else {
                sellChatList.add(chat);
              }
            }
            if (!mounted) return;
            Provider.of<ChatListProvider>(context, listen: false)
                .setChatList(sellChatList, buyChatList);
          }
        }
      }
    }
  }

  @override
  void initState() {
    // String? fcmToken = await FirebaseMessaging.instance.getToken();
    // print(fcmToken);
    _getAllMyChatList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // websocket 연결
    socketChannel = Provider.of<SocketClass>(context);
    socketChannel.onConnect();
    socketChannel.onMessageReceived = _handleMessageReceived;

    return Scaffold(
      appBar: mainAppBar(currentTabIndex, context),
      body: Center(
        child: _bodyPage.elementAt(currentTabIndex),
      ),
      bottomNavigationBar: MainNavigationBar(
        currentTabIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
    );
  }
}
