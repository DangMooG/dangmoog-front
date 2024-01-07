import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/websocket_provider.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  final List<Widget> _bodyPage = <Widget>[
    const MainPage(key: ValueKey("MainPage")), // Post List Page
    const TempPage(key: ValueKey("TempPage")), // Temp Page
    const ChatListPage(key: ValueKey("ChatListPage")), // Chat List Page
    const MyPage(
      key: ValueKey("MyPage"),
      nickname: '',
      email: '',
    )
  ];

  // 소켓 연결해주기,
  late SocketClass socketChannel;
  void _handleMessageReceived(String message) {
    // chat provider를 확인해서
    // 1. 현재 사용자가 들어가있는 채팅방과 방금 들어온 메시지의 채팅방이 일치하는지
    //    - 물론 사용자가 현재 어떤 채팅방에도 들어있지 않을 수 있음
    //    - 그런 경우에는 chatprovider의 roomId가 빈 문자열이다.
    // 2. 만약 일치하지 않는다면
    //    1) 현재 chat list provider에 속해있는 채팅방에 대한 채팅인지 확인
    //       - chat list provider의 sellChatList과 buyChatList에서 확인
    //       - 만약 속해있다면, 해당 채팅방에 대한 최근 메시지, 시각, 안 읽은 메시지 수를 업데이트해준다
    //       - 그리고 chat list provider의 해당 list를 최근 메시지 시각으로 정렬해주기
    //    2) 현재 chat list provider에 속해있지 않은 채팅인 경우(새로운 채팅)
    //       - Chat List를 아예 다시 불러오기(간단하쥬?)
    //       - 다시 불러온다면 당연히 방금 온 새로운 채팅도 포함되어 있을 거임
    // 3. 만약 일치한다면
    //    - 헷갈릴 수 있는데, 이 경우에는 무조건 이미 채팅이 하나 있을 거임(잘 생각해봐)
    //    - 그럼 당연히 현재 chat list provider에 속해있는 채팅방에 대한 채팅일 거임
    //    - ChatDetailMessageModel class로 새롭게 변수 선언해서 chat provider에 해당 채팅 추가
    // 내가 구매자로서 처음 보내는 채팅의 플로우도 작성해보자 //

    final roomId = message.substring(0, 36);
    final chatMessage = message.substring(36);
    final updateTime = DateTime.now();

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chatListProvider =
        Provider.of<ChatListProvider>(context, listen: false);

    // 현재 사용자가 보고 있는 채팅방의 채팅이 아닐 경우
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
      // ChatDetailMessageModel class로 새롭게 변수 선언해서 chat provider에 해당 채팅 추가
      if (chatListProvider.buyChatList
          .any((chatCell) => chatCell.roomId == roomId)) {
        final newChat = ChatDetailMessageModel(
            fromBuyer: false,
            message: chatMessage,
            read: true,
            createTime: updateTime);

        chatProvider.addChatContent(newChat);
      }
      // 이미 존재하는 채팅방이자, 내가 판매자인 채팅방의 채팅일 경우
      else if (chatListProvider.sellChatList
          .any((chatCell) => chatCell.roomId == roomId)) {
        final newChat = ChatDetailMessageModel(
            fromBuyer: true,
            message: chatMessage,
            read: true,
            createTime: updateTime);
        chatProvider.addChatContent(newChat);
      }
    }
  }

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
