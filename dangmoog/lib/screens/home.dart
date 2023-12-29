import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/providers/websocket_provider.dart';
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
    const MainPage(), // Post List Page
    const TempPage(), // home page (추후 업데이트를 위한 여유 페이지)
    const ChatListPage(), // Chat List Page
    const MyPage(
      nickname: '',
      email: '',
    ) // MyPage
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
