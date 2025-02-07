import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/socket_provider.dart';

import 'package:dangmoog/screens/chat/chat_detail/chat_detail_content.dart';
import 'package:dangmoog/screens/chat/chat_detail/chat_detail_options.dart';
import 'package:dangmoog/screens/chat/chat_detail/chat_detail_product.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

// plugin
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:provider/provider.dart';

class ChatDetail extends StatefulWidget {
  final String? roomId;
  const ChatDetail({
    required this.roomId,
    super.key,
  });

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  String? roomId;
  bool? imBuyer;
  int? postId;
  String? userName;

  ProductModel? product;

  List<ChatDetailMessageModel>? _chatDetail;

  bool saveBankAccount = true;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 클릭 방지
  bool _blockInteraction = false;

  // // Keyboard, Optionbox Related // //

  // keyboard에 focus 주기 위함
  FocusNode chatInputFocus = FocusNode();
  // 현재 option box가 on이면 true
  bool _isOptionOn = false;
  // 현재 키보드가 on이면 true
  bool _isKeyboardOn = false;
  // keyboard 높이
  double _keyboardHeight = 291;
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
  bool resizeScreenKeyboard = true;
  Timer? timer;
  // // // // // // // // // // // // // //

  // keyboard focus 제거
  void unFocusKeyBoard() {
    FocusScope.of(context).unfocus();
    if (_isKeyboardOn == true) {
      setState(() {
        _isKeyboardOn = false;
      });
    }
  }

  final StreamController<double> keyboardHeightController =
      StreamController<double>();

  // 조건 확인 함수
  void isKeyboardRemoved() {
    final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 키보드 높이가 0인지 확인하고, 해당 조건이 충족되면 스트림에 이벤트 추가
    if (currentKeyboardHeight == 0.0) {
      keyboardHeightController.sink.add(currentKeyboardHeight);
    }
  }

  Color submitBtnColor = const Color(0xffBEBCBC);

  void onChangedKeyboard(String value) {
    if (value != "") {
      setState(() {
        submitBtnColor = const Color(0xffEC5870);
      });
    } else {
      setState(() {
        submitBtnColor = const Color(0xffBEBCBC);
      });
    }
  }

  late SocketProvider socketChannel;

  void getPostContent() async {
    Response response = await ApiService().loadProduct(postId!);
    if (response.statusCode == 200) {
      final post = response.data;
      if (mounted) {
        setState(() {
          product = ProductModel.fromJson(post);
        });
        Provider.of<ChatProvider>(context, listen: false)
            .setDealStatus(post['status'] ?? 0);
      }
    }
  }

  void getAllMessages() async {
    if (roomId != null && roomId != "") {
      Response response = await ApiService().getChatAllMessages(roomId!);
      if (response.statusCode == 200) {
        final List<dynamic> messages = response.data;

        setState(() {
          _chatDetail = messages
              .map((msg) => ChatDetailMessageModel.fromJson(msg, imBuyer!))
              .toList();
        });

        Provider.of<ChatProvider>(context, listen: false)
            .setChatContents(_chatDetail!);

        Provider.of<ChatProvider>(context, listen: false).setImBuyer(imBuyer!);

        final chatListProvider =
            Provider.of<ChatListProvider>(context, listen: false);
        if (chatListProvider.buyChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.buyChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);

          chatListProvider.resetUnreadCount(index, true);
        } else if (chatListProvider.sellChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.sellChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);

          chatListProvider.resetUnreadCount(index, false);
        }
      }
    }
  }

  void setRoomId(String? newRoomId) {
    setState(() {
      roomId = newRoomId;
    });
  }

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        userName = Provider.of<ChatProvider>(context, listen: false).userName;
        postId = Provider.of<ChatProvider>(context, listen: false).postId;
        imBuyer = Provider.of<ChatProvider>(context, listen: false).imBuyer;
      });
      // setRoomId(widget.roomId);
      Provider.of<ChatProvider>(context, listen: false)
          .setRoomId(widget.roomId);

      if (widget.roomId != null && widget.roomId != "") {
        Provider.of<SocketProvider>(context, listen: false)
            .beginChat(widget.roomId!);
      }

      getPostContent();
      getAllMessages();
    });

    // 키보드의 높이가 바뀌면 update
    // 키보드가 unfocus돼서 내려가는 건 update 안함
    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if (height != 0) {
        setState(() {
          _keyboardHeight = height;
        });
      }
    });

    // 키보드 높이 감지 로직 추가
    keyboardHeightController.stream.listen((height) {
      if (height == 0.0) {
        setState(() {
          resizeScreenKeyboard = true;
          _blockInteraction = false;
        });
      }
    });
  }

  @override
  void dispose() {
    keyboardHeightController.close();
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketChannel = Provider.of<SocketProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        Provider.of<ChatProvider>(context, listen: false).resetChatProvider();

        if (roomId != null && roomId != "") {
          socketChannel.exitChat(roomId!);
        }
        Navigator.pop(context);
        return true;
      },
      child: AbsorbPointer(
        absorbing: _blockInteraction,
        child: Scaffold(
          resizeToAvoidBottomInset: resizeScreenKeyboard,
          appBar: _buildChatUserName(userName),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                product != null && imBuyer != null
                    ? ChatDetailProduct(
                        product: product!,
                        imBuyer: imBuyer!,
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: GestureDetector(
                    onTap: unFocusKeyBoard,
                    child: ChatContents(scrollController: _scrollController),
                  ),
                ),
                _buildBottomField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // chat input field + option box
  Widget _buildBottomField(BuildContext context) {
    // 채팅 전송
    void handleTextChatSubmitted() async {
      if (roomId == null || roomId == "") {
        try {
          Response response = await ApiService().getChatRoomId(postId!);
          if (response.statusCode == 200) {
            String newRoomId = response.data["room_id"];

            if (!mounted) return;
            Provider.of<ChatProvider>(context, listen: false)
                .setRoomId(newRoomId);
            setRoomId(newRoomId);

            if (newRoomId != "") {
              Provider.of<SocketProvider>(context, listen: false)
                  .beginChat(newRoomId);
            }
          }
        } catch (e) {
          print(e);
        }
      }

      if (_textController.text != '' && roomId != null && roomId != "") {
        // 서버로 전송
        await socketChannel.onSendMessage(
            _textController.text, null, roomId!, false);

        final currentTime = DateTime.now();
        final chatMessage = _textController.text;

        var newMessage = ChatDetailMessageModel(
          isMine: true,
          message: chatMessage,
          read: true,
          createTime: currentTime,
          isImage: false,
        );

        _textController.clear();

        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addChatContent(newMessage);

        final chatListProvider =
            Provider.of<ChatListProvider>(context, listen: false);
        if (chatListProvider.buyChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.buyChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);

          chatListProvider.updateChatList(
            index,
            chatMessage,
            currentTime,
            true,
          );
          chatListProvider.resetUnreadCount(index, true);
        } else if (chatListProvider.sellChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.sellChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);
          chatListProvider.updateChatList(
            index,
            chatMessage,
            currentTime,
            false,
          );
          chatListProvider.resetUnreadCount(index, false);
        } else {
          chatProvider.addNewChatList();
        }

        if (chatProvider.chatContents.length > 1) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }

    return Column(
      children: [
        _buildchatInputField(context, handleTextChatSubmitted),
        ChatDetailOptions(
          isOptionOn: _isOptionOn,
          keyboardHeight: _keyboardHeight,
          useLocker: product?.useLocker,
          roomId: roomId,
          setRoomId: setRoomId,
        )
      ],
    );
  }

  Widget _buildchatInputField(
      BuildContext context, VoidCallback handleTextChatSubmitted) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.5, color: Color(0xffBEBCBC)),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      // margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Option Button
              IconButton(
                onPressed: () async {
                  // 이미 option box가 올라와있었을 경우
                  // // chat input field에 focus를 주고 keyboard를 올려준다
                  if (_isOptionOn == true && _isKeyboardOn == false) {
                    setState(() {
                      // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
                      resizeScreenKeyboard = false;
                      // 다른 동작이 수행되지 않도록 방지
                      _blockInteraction = true;
                      _isKeyboardOn = true;
                    });
                    FocusScope.of(context).requestFocus(chatInputFocus);

                    timer = Timer.periodic(const Duration(milliseconds: 100),
                        (timer) {
                      double keyboardHeight =
                          MediaQuery.of(context).viewInsets.bottom;
                      if (keyboardHeight == _keyboardHeight) {
                        timer.cancel();
                        // 다시 키보드가 Screen 영역에 영향을 주도록 변경
                        setState(() {
                          resizeScreenKeyboard = true;
                          _blockInteraction = false;
                          _isOptionOn = false;
                        });
                      }
                    });

                    return;
                  }
                  // 키보드가 올라와있지 않았을 경우
                  if (_isKeyboardOn == false) {
                    setState(() {
                      _isOptionOn = true;
                    });
                    return;
                  }

                  // 키보드가 올라외있었을 경우
                  if (_isKeyboardOn == true) {
                    setState(() {
                      // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
                      resizeScreenKeyboard = false;
                      // 다른 동작이 수행되지 않도록 방지
                      _blockInteraction = true;
                      _isOptionOn = true;
                    });

                    unFocusKeyBoard();
                    // isKeyboardRemoved();
                    // 키보드의 높이가 0이 될 때가지 0.1초를 주기로 확인
                    timer = Timer.periodic(const Duration(milliseconds: 100),
                        (timer) {
                      double keyboardHeight =
                          MediaQuery.of(context).viewInsets.bottom;
                      if (keyboardHeight == 0) {
                        timer.cancel();
                        // 다시 키보드가 Screen 영역에 영향을 주도록 변경
                        setState(() {
                          resizeScreenKeyboard = true;
                          _blockInteraction = false;
                        });
                      }
                    });
                  }
                },
                icon: Icon(
                  _isKeyboardOn
                      ? Icons.add_circle_outline
                      : _isOptionOn
                          ? Icons.highlight_remove_outlined
                          : Icons.add_circle_outline,
                  color: const Color(0xFFBEBCBC),
                ),
              ),
              // Text Input
              Flexible(
                child: TextField(
                  focusNode: chatInputFocus,
                  onTap: () {
                    if (_isKeyboardOn == false) {
                      setState(() {
                        _isKeyboardOn = true;
                      });
                    }
                    // option box가 띄워져있었을 경우
                    if (_isOptionOn == true) {
                      setState(() {
                        // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
                        resizeScreenKeyboard = false;
                        // 다른 동작이 수행되지 않도록 방지
                        _blockInteraction = true;
                      });

                      // 키보드가 완전히 올라올 떄가지 0.1초를 주기로 확인
                      Timer.periodic(const Duration(milliseconds: 100),
                          (timer) {
                        if (MediaQuery.of(context).viewInsets.bottom ==
                            _keyboardHeight) {
                          timer.cancel();
                          setState(() {
                            _isOptionOn = false;
                            // 다시 keyboard가 screen에 영향을 주도록 설정
                            resizeScreenKeyboard = true;

                            _blockInteraction = false; // 다시 상호작용을 허용
                          });
                        }
                      });
                    }
                  },
                  style: const TextStyle(fontSize: 14.0),
                  textAlignVertical: TextAlignVertical.center,
                  controller: _textController,
                  onChanged: onChangedKeyboard,
                  maxLines: 5,
                  minLines: 1,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                        color: Color(0xFFBEBCBC),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      borderSide: BorderSide(
                        color: Color(0xFFBEBCBC),
                        width: 1,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                  ),
                ),
              ),
              // Submit Button
              IconButton(
                icon: Transform.rotate(
                  angle: 90 * (pi / 180),
                  child: Icon(
                    Icons.navigation,
                    color: submitBtnColor,
                  ),
                ),
                onPressed: handleTextChatSubmitted,
              )
            ],
          ),
          AnimatedContainer(
            duration: const Duration(microseconds: 300),
            height: _isKeyboardOn || _isOptionOn ? 0 : 25,
            curve: Curves.easeOut,
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }

  // 채팅 상대방 닉네임
  AppBar _buildChatUserName(String? userName) {
    return AppBar(
      title: Text(
        userName ?? "",
        style: const TextStyle(
          color: Color(0xFF302E2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.keyboard_backspace,
          size: 24,
        ),
        onPressed: () {
          Provider.of<ChatProvider>(context, listen: false).resetChatProvider();
          Navigator.pop(context);
          if (roomId != null && roomId != "") {
            socketChannel.exitChat(roomId!);
          }
        },
      ),
      backgroundColor: Colors.white,
      shape: const Border(
        bottom: BorderSide(
          color: Color(0xFFBEBCBC),
          width: 1,
        ),
      ),
    );
  }
}
