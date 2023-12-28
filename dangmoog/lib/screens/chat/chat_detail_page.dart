import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/chat_setting_provider.dart';
import 'package:dangmoog/providers/websocket_provider.dart';

import 'package:dangmoog/screens/chat/chat_deal_status.dart';
import 'package:dangmoog/screens/chat/chat_detail_content.dart';
import 'package:dangmoog/screens/chat/chat_detail_options.dart';
import 'package:dangmoog/screens/chat/chat_detail_product.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/models/chat_detail_model.dart';

import 'dart:async';
import 'dart:math';
// import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// plugin
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// chat data 불러오기
Future<ChatDetailModel> _loadChatDetailFromAsset(String url) async {
  final String jsonChatDetail = await rootBundle.loadString(url);
  final Map<String, dynamic> jsonChatDetailResponse =
      json.decode(jsonChatDetail);

  return ChatDetailModel.fromJson(jsonChatDetailResponse);
}

class ChatDetail extends StatefulWidget {
  const ChatDetail({super.key});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  // 클릭 방지
  bool _blockInteraction = false;

  late Future<ChatDetailModel> _chatDetail;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // static const storage = FlutterSecureStorage();
  bool saveBankAccount = true;

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

  // // 카메라로 사진 추가
  // Future getImageFromCamera(BuildContext context) async {
  //   PermissionStatus status = await Permission.camera.request();

  //   final ImagePicker picker = ImagePicker();
  //   final List<String> imageList = <String>[];

  //   if (status.isGranted || status.isLimited) {
  //     try {
  //       final XFile? pickedImage =
  //           await picker.pickImage(source: ImageSource.camera);

  //       if (pickedImage != null) {
  //         String imagePath = pickedImage.path;

  //         setState(() {
  //           imageList.add(imagePath);
  //         });
  //       }
  //     } catch (e) {
  //       print("Error picking images: $e");
  //     }
  //   } else if (status.isPermanentlyDenied) {
  //     // 나중에 ios는 cupertino로 바꿔줄 필요 있음
  //     await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("사진 권한 필요"),
  //           content:
  //               const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text("취소"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             TextButton(
  //               child: const Text("설정으로 이동"),
  //               onPressed: () {
  //                 openAppSettings();
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

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

  late SocketClass socketChannel;

  @override
  void initState() {
    super.initState();

    setState(() {
      _chatDetail = _loadChatDetailFromAsset('assets/chat_detail.json');
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

  void _handleMessageReceived(String message) {
    final chatContent = ChatDetailContent(
      chatDateTime: DateTime.now(),
      chatText: message,
      isMe: false,
    );
    print(
        Provider.of<ChatProvider>(context, listen: false).chatContents.length);
    Provider.of<ChatProvider>(context, listen: false)
        .addChatContent(chatContent);
    print(
        Provider.of<ChatProvider>(context, listen: false).chatContents.length);
  }

  @override
  Widget build(BuildContext context) {
    socketChannel = Provider.of<SocketClass>(context);
    socketChannel.onMessageReceived = _handleMessageReceived;
    return Scaffold(
      resizeToAvoidBottomInset: resizeScreenKeyboard,
      appBar: _buildChatUserName(_chatDetail),
      body: Center(
        child: AbsorbPointer(
          absorbing: _blockInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _buildChatProductInfo(_chatDetail),
              ChatDetailProduct(futureChatDetail: _chatDetail),
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
    );
  }

  // chat input field + option box
  Widget _buildBottomField(BuildContext context) {
    // 채팅 전송
    void handleSubmitted() {
      if (_textController.text != '') {
        // 서버로 전송
        socketChannel.onSendMessage(_textController.text);

        var newMessage = ChatDetailContent(
          chatDateTime: DateTime.now(), // 현재 시간으로 설정
          chatText: _textController.text,
          isMe: true,
        );

        _textController.clear();

        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addChatContent(newMessage);

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
        _buildchatInputField(context, handleSubmitted),
        // _buildAdditionalWidget(context)
        ChatDetailOptions(
          isOptionOn: _isOptionOn,
          keyboardHeight: _keyboardHeight,
        )
      ],
    );
  }

  // option box button, chat input field, submit button
  Widget _buildchatInputField(
      BuildContext context, VoidCallback handleSubmitted) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.5, color: Color(0xffBEBCBC)),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
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
                          MediaQuery.of(context).viewInsets.bottom ?? 0;
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
                          MediaQuery.of(context).viewInsets.bottom ?? 0;
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
                onPressed: handleSubmitted,
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

  // // 채팅 옵션 contents: 사진, 계좌 정보, 사물함 정보
  // Widget _buildAdditionalWidget(BuildContext context) {
  //   Widget optionCircleWidget(IconData icon, String iconText, Function onTap) {
  //     return Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
  //       child: Column(
  //         children: [
  //           GestureDetector(
  //             onTap: () {
  //               onTap();
  //             },
  //             child: Container(
  //               width: 72,
  //               height: 72,
  //               margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
  //               decoration: const BoxDecoration(
  //                 color: Color(0xffE83754),
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(36),
  //                 ),
  //               ),
  //               child: Icon(
  //                 icon,
  //                 size: 33,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //           Text(
  //             iconText,
  //             style: const TextStyle(
  //               color: Color(0xff302E2E),
  //               fontSize: 13,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           )
  //         ],
  //       ),
  //     );
  //   }

  //   Widget accountButtonWidget(String text, Color btnColor, Color borderColor,
  //       Color textColor, VoidCallback onTap) {
  //     return SizedBox(
  //       width: 300,
  //       child: TextButton(
  //         onPressed: () {
  //           Navigator.pop(context);
  //           onTap();
  //         },
  //         style: ButtonStyle(
  //           backgroundColor: MaterialStateProperty.resolveWith<Color>(
  //             (Set<MaterialState> states) {
  //               return btnColor;
  //             },
  //           ),
  //           // foregroundColor: MaterialStateProperty.all<Color>(borderColor),
  //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //             RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(6),
  //                 side: BorderSide(color: borderColor)),
  //           ),
  //         ),
  //         child: Text(
  //           text,
  //           style: TextStyle(color: textColor),
  //         ),
  //       ),
  //     );
  //   }

  //   void setBankAccount() async {
  //     String accountNumber = '';
  //     String selectedBank = 'NH농협은행';
  //     List<String> bankList = ['NH농협은행', '기업은행', 'KB국민은행']; // 은행 리스트

  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //           backgroundColor: Colors.white,
  //           title: const Text(
  //             '새로운 계좌 정보를 입력해주세요!',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: Color(0xff302E2E),
  //             ),
  //           ),
  //           content: const Text(
  //             '은행과 계좌번호를 정확히 입력해주세요',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w400,
  //               color: Color(0xff302E2E),
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Column(
  //                   children: [
  //                     TextField(
  //                       decoration: const InputDecoration(
  //                         hintText: '계좌번호 입력',
  //                         labelText: null,
  //                         border: UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Color(0xffD3D2D2)),
  //                         ),
  //                         focusedBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Color(0xff726E6E)),
  //                         ),
  //                         contentPadding: EdgeInsets.symmetric(
  //                           vertical: 10.0,
  //                         ),
  //                         floatingLabelBehavior: FloatingLabelBehavior.never,
  //                       ),
  //                       style: const TextStyle(
  //                         color: Color(0xff302E2E),
  //                         fontSize: 14.0,
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                       keyboardType: TextInputType.number,
  //                       onChanged: (value) {
  //                         accountNumber = value;
  //                       },
  //                     ),
  //                     const SizedBox(height: 20),
  //                     DropdownButtonFormField<String>(
  //                       decoration: const InputDecoration(
  //                         hintText: '은행 선택',
  //                         labelText: null,
  //                         border: UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Color(0xffD3D2D2)),
  //                         ),
  //                         focusedBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(color: Color(0xff726E6E)),
  //                         ),
  //                         contentPadding: EdgeInsets.symmetric(vertical: 10.0),
  //                         // filled: true, // Needed for fillColor to take effect
  //                         // fillColor: Colors.grey[200], // Background color
  //                         floatingLabelBehavior: FloatingLabelBehavior.never,
  //                       ),
  //                       icon: const Icon(
  //                         Icons.chevron_right,
  //                         color: Color(0xffA19E9E),
  //                       ),
  //                       style: const TextStyle(
  //                         color: Color(0xff302E2E),
  //                         fontSize: 14.0,
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                       items: bankList
  //                           .map<DropdownMenuItem<String>>((String value) {
  //                         return DropdownMenuItem<String>(
  //                           value: value,
  //                           child: Text(value),
  //                         );
  //                       }).toList(),
  //                       onChanged: (String? newValue) {
  //                         // Update selected bank
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 16,
  //                 ),
  //                 Column(
  //                   children: [
  //                     accountButtonWidget('바로 발송하기', const Color(0xFFE20529),
  //                         Colors.transparent, Colors.white, () {}),
  //                     accountButtonWidget(
  //                       '취소하기',
  //                       Colors.transparent,
  //                       const Color(0xFF726E6E),
  //                       const Color(0xff726E6E),
  //                       () {},
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Text(
  //                       '현재 작성한 정보를 기본 계좌정보로 저장합니다.',
  //                       style: TextStyle(
  //                         color: Color(0xff726E6E),
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                     ),
  //                     Checkbox(
  //                       overlayColor:
  //                           MaterialStateProperty.all(const Color(0xffBEBCBC)),
  //                       value: saveBankAccount,
  //                       splashRadius: 12,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(3),
  //                         side: const BorderSide(
  //                           color: Color(0xffBEBCBC),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       activeColor: const Color(0xffBEBCBC),
  //                       fillColor: MaterialStateProperty.resolveWith<Color>(
  //                         (Set<MaterialState> states) {
  //                           if (states.contains(MaterialState.selected)) {
  //                             return const Color(0xFFE20529);
  //                           }
  //                           return Colors.white;
  //                         },
  //                       ),
  //                       checkColor: Colors.white,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           saveBankAccount = !saveBankAccount;
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ]),
  //     );
  //   }

  //   // 계좌 정보 전송
  //   void sendBankAccount() async {
  //     final bankAccountName = await storage.read(key: 'bankAccountName');
  //     final bankAccountNumber = await storage.read(key: 'bankAccountNumber');

  //     // 이미 등록된 계좌가 존재하는 경우
  //     if (bankAccountName != null && bankAccountNumber != null) {
  //       if (!mounted) return;
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(14),
  //             ),
  //             title: const Text(
  //               '이미 계좌 정보가 존재합니다.',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Color(0xff302E2E),
  //               ),
  //             ),
  //             content: const Text(
  //               '해당 정보를 구매자에게 발송하시겠습니까?',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w400,
  //                 color: Color(0xff302E2E),
  //               ),
  //             ),
  //             actions: <Widget>[
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisSize: MainAxisSize
  //                     .min, // Use minimum space required by children
  //                 children: [
  //                   Text(
  //                     '$bankAccountNumber $bankAccountName',
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       decoration: TextDecoration.underline,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w400,
  //                       color: Color(0xff302E2E),
  //                     ),
  //                   ),
  //                   Column(
  //                     children: [
  //                       SizedBox(
  //                         width: 300,
  //                         child: TextButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           style: ButtonStyle(
  //                             backgroundColor:
  //                                 MaterialStateProperty.resolveWith<Color>(
  //                               (Set<MaterialState> states) {
  //                                 if (states.contains(MaterialState.pressed)) {
  //                                   return Colors
  //                                       .red[600]!; // Color when pressed
  //                                 }
  //                                 return const Color(
  //                                     0xFFE20529); // Regular color
  //                               },
  //                             ),
  //                             foregroundColor: MaterialStateProperty.all<Color>(
  //                                 Colors.white),
  //                             shape: MaterialStateProperty.all<
  //                                 RoundedRectangleBorder>(
  //                               RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(6),
  //                               ),
  //                             ),
  //                           ),
  //                           child: const Text('발송하기'),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: 300,
  //                         child: TextButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           style: ButtonStyle(
  //                             backgroundColor:
  //                                 MaterialStateProperty.resolveWith<Color>(
  //                               (Set<MaterialState> states) {
  //                                 if (states.contains(MaterialState.pressed)) {
  //                                   return Colors
  //                                       .red[600]!; // Color when pressed
  //                                 }
  //                                 return Colors.transparent; // Regular color
  //                               },
  //                             ),
  //                             foregroundColor: MaterialStateProperty.all<Color>(
  //                                 const Color(0xFFE20529)),
  //                             shape: MaterialStateProperty.all<
  //                                 RoundedRectangleBorder>(
  //                               RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(6),
  //                                   side: const BorderSide(
  //                                       color: Color(0xFFE20529))),
  //                             ),
  //                           ),
  //                           child: const Text('새로작성'),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: 300,
  //                         child: TextButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           style: ButtonStyle(
  //                             backgroundColor:
  //                                 MaterialStateProperty.resolveWith<Color>(
  //                               (Set<MaterialState> states) {
  //                                 // if (states.contains(MaterialState.pressed)) {
  //                                 //   return Colors.red[600]!; // Color when pressed
  //                                 // }
  //                                 return Colors.transparent; // Regular color
  //                               },
  //                             ),
  //                             foregroundColor: MaterialStateProperty.all<Color>(
  //                                 const Color(0xFF726E6E)),
  //                             shape: MaterialStateProperty.all<
  //                                 RoundedRectangleBorder>(
  //                               RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(6),
  //                                   side: const BorderSide(
  //                                       color: Color(0xFF726E6E))),
  //                             ),
  //                           ),
  //                           child: const Text('취소하기'),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ]),
  //       );
  //     }
  //     // 등록된 계좌가 없는 경우
  //     else {
  //       if (!mounted) return;
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           title: const Text('작성된 계좌 정보가 없습니다!',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xff302E2E))),
  //           content: const Text(
  //             '계좌 정보를 입력하시겠어요?',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w400,
  //               color: Color(0xff302E2E),
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Column(
  //                   children: [
  //                     accountButtonWidget('작성하기', const Color(0xFFE20529),
  //                         Colors.transparent, Colors.white, setBankAccount),
  //                     accountButtonWidget(
  //                       '취소하기',
  //                       Colors.transparent,
  //                       const Color(0xFF726E6E),
  //                       const Color(0xff726E6E),
  //                       () {},
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }

  //   return SizedBox(
  //     height: _isOptionOn ? _keyboardHeight : 0,
  //     child: Center(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               optionCircleWidget(Icons.camera_alt_outlined, '카메라', () {
  //                 getImageFromCamera(context);
  //               }),
  //               optionCircleWidget(Icons.image_outlined, '앨범', () {}),
  //             ],
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               optionCircleWidget(Icons.credit_card_outlined, '거래정보 발송', () {
  //                 sendBankAccount();
  //               }),
  //               optionCircleWidget(Icons.vpn_key_outlined, '사물함 정보 발송', () {}),
  //             ],
  //           ),
  //           // option box가 정중앙에 있으면 살짝 아래에 있는 느낌이 들어서 추가한 위젯
  //           const SizedBox(
  //             height: 15,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // 채팅 상대방 닉네임
  AppBar _buildChatUserName(Future<ChatDetailModel> futureChatDetail) {
    return AppBar(
      title: FutureBuilder<ChatDetailModel>(
        future: futureChatDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading chat list!'),
              );
            }
            return Text(
              snapshot.data!.chatInfo.userNickName,
              style: const TextStyle(
                color: Color(0xFF302E2E),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
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
