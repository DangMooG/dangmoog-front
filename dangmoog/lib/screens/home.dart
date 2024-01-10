import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/socket_provider.dart';
import 'package:dangmoog/services/api.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list/chat_list_page.dart';
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

  // 소켓 연결해주기
  late SocketProvider socketChannel;

  final List<Widget> _bodyPage = <Widget>[
    const MainPage(key: ValueKey("MainPage")), // Post List Page
    const TempPage(key: ValueKey("TempPage")), // Temp Page
    const ChatListPage(key: ValueKey("ChatListPage")), // Chat List Page
    const MyPage(key: ValueKey("MyPage"), nickname: '', email: '')
  ];

  void _getAllMyChatList() async {
    try {
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

              // print(postIdList);

              // print(photoIdList[13]);
              // print(unreadCountList[13]);
              // print(postIdList[13]);

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
    } catch (e) {
      print(e);
    }
  }

  late ChatProvider chatProvider;
  late ChatListProvider chatListProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketChannel = Provider.of<SocketProvider>(context, listen: false);
      socketChannel.onConnect();
      socketChannel.setChatReceivedCallback(handleChatReceived);

      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatListProvider = Provider.of<ChatListProvider>(context, listen: false);
    });
    _getAllMyChatList();
  }

  void handleChatReceived(String message) {
    final roomId = message.substring(0, 36);
    final chatMessage = message.substring(36);
    final updateTime = DateTime.now();

    if (roomId != chatProvider.roomId) {
      // 이미 존재하는 채팅방이자, 내가 구매자인 채팅방의 채팅일 경우
      if (chatListProvider.buyChatList
          .any((chatCell) => chatCell.roomId == roomId)) {
        // chat list page의 정보 update
        int index = chatListProvider.buyChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          chatMessage,
          updateTime,
          true,
        );
      }
      // 이미 존재하는 채팅방이자, 내가 판매자인 채팅방의 채팅일 경우
      else if (chatListProvider.sellChatList
          .any((chatCell) => chatCell.roomId == roomId)) {
        int index = chatListProvider.sellChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          chatMessage,
          updateTime,
          false,
        );
      }
      // 새로운 채팅방의 채팅 => 구매자가 판매자인 나에게 보낸 채팅
      else {
        // 채팅 목록 다시 불러오기
        _getAllMyChatList();
      }
    }
    // 현재 사용자가 보고 있는 채팅방의 채팅인 경우
    else if (roomId == chatProvider.roomId) {
      // chat list에도 업데이트해줄 필요 있음
      // chat provider에 해당 채팅 추가
      final newChat = ChatDetailMessageModel(
          isMine: false,
          message: chatMessage,
          read: true,
          createTime: updateTime);

      chatProvider.addChatContent(newChat);
    }
  }

  @override
  Widget build(BuildContext context) {
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
