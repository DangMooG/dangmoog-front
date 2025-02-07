import 'package:dangmoog/providers/post_list_scroll_provider.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/widgets/update_popup.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/models/chat_list_cell_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/socket_provider.dart';
import 'package:dangmoog/screens/mypage/like/like_mainpage.dart';

import 'package:dangmoog/services/api.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list/chat_list_page.dart';

import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentTabIndex = 0;

  // 소켓 연결해주기
  late SocketProvider socketChannel;

  final List<Widget> _bodyPage = <Widget>[
    const ProductList(key: ValueKey("ProductListPage")),
    const LikeMainPage(key: ValueKey("LikePage")),
    const ChatListPage(key: ValueKey("ChatListPage")),
    const MyPage(key: ValueKey("MyPage"))
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
            dynamic lastMessageList = response3.data["last_messages"];

            for (var entry in lastMessageList.asMap().entries) {
              if (entry.value.runtimeType == List<dynamic>) {
                lastMessageList[entry.key] = "사진";
              }
            }

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
      chatProvider.updateNewChatList(() {
        _getAllMyChatList();
      });
      chatListProvider = Provider.of<ChatListProvider>(context, listen: false);
    });
    _getAllMyChatList();
  }

  @override
  void dispose() {
    socketChannel.dispose();
    super.dispose();
  }

  void handleChatReceived(Map<String, dynamic> data) {
    final roomId = data["room"];
    final chatMessage = data["content"];
    final messageType = data["type"];
    final updateTime = DateTime.now();

    if (roomId != chatProvider.roomId) {
      // 이미 존재하는 채팅방이자, 내가 구매자인 채팅방의 채팅일 경우
      if (chatListProvider.buyChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        // chat list page의 정보 update
        int index = chatListProvider.buyChatList
            .indexWhere((chatListCell) => chatListCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          messageType == 'img' ? "사진" : chatMessage,
          updateTime,
          true,
        );
      }
      // 이미 존재하는 채팅방이자, 내가 판매자인 채팅방의 채팅일 경우
      else if (chatListProvider.sellChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        int index = chatListProvider.sellChatList
            .indexWhere((chatListCell) => chatListCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          messageType == 'img' ? "사진" : chatMessage,
          updateTime,
          false,
        );
      }
      // 새로운 채팅방의 채팅 => 구매자가 판매자인 나에게 보낸 채팅
      else {
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
        createTime: updateTime,
        isImage: messageType == 'img' ? true : false,
      );

      chatProvider.addChatContent(newChat);
      if (chatListProvider.buyChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        int index = chatListProvider.buyChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);

        chatListProvider.updateChatList(
          index,
          messageType == 'img' ? "사진" : chatMessage,
          updateTime,
          true,
        );

        chatListProvider.resetUnreadCount(index, true);
      } else if (chatListProvider.sellChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        int index = chatListProvider.sellChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          messageType == 'img' ? "사진" : chatMessage,
          updateTime,
          false,
        );
        chatListProvider.resetUnreadCount(index, false);
      }
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now; // 현재 시간 업데이트
      Fluttertoast.showToast(
        msg: "'뒤로' 버튼을 한번 더 누르시면 종료됩니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(0xff6E6E6E),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    }
    SystemNavigator.pop();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () {
      //   return Future(() => false);
      // },
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: mainAppBar(currentTabIndex, context),
        body: UpgradeAlert(
          upgrader: Upgrader(
            languageCode: 'ko',
            messages: MyUpgraderMessages(),
            // messages: UpgraderMessages(),
            durationUntilAlertAgain: const Duration(seconds: 0),
          ),
          showIgnore: false,
          showLater: false,
          showReleaseNotes: false,
          dialogStyle: UpgradeDialogStyle.cupertino,
          cupertinoButtonTextStyle: const TextStyle(
            color: Colors.black,
          ),
          child: IndexedStack(
            index: currentTabIndex,
            children: _bodyPage,
          ),
        ),
        bottomNavigationBar: MainNavigationBar(
          currentTabIndex: currentTabIndex,
          onTap: (index) {
            if (currentTabIndex == 0 && index == 0) {
              Provider.of<PostListScrollProvider>(context, listen: false)
                  .scrollToTop();
            }
            setState(() {
              currentTabIndex = index;
            });
          },
        ),
      ),
    );
  }
}
