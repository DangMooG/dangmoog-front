// 나중에 코드 분리 예정


// import 'dart:async';

// import 'package:dangmoog/models/chat_detail_model.dart';
// import 'package:dangmoog/providers/chat_provider.dart';
// import 'package:dangmoog/providers/chat_setting_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// import 'dart:math';

// class ChatBottom extends StatefulWidget {
//   final ScrollController scrollController;

//   const ChatBottom({Key? key, required this.scrollController})
//       : super(key: key);

//   @override
//   State<ChatBottom> createState() => _ChatBottomState();
// }

// class _ChatBottomState extends State<ChatBottom> {
//   final TextEditingController _textController = TextEditingController();

//   // 클릭 방지
//   bool _blockInteraction = false;

//   // keyboard에 focus 주기 위함
//   FocusNode chatInputFocus = FocusNode();

//   // 현재 option box가 on이면 true
//   bool _isOptionOn = false;
//   // 현재 키보드가 on이면 true
//   bool _isKeyboardOn = false;
//   // 키보드가 한 번이라도 쓰였으면 true

//   // keyboard 높이
//   final double _keyboardHeight = 291;
//   final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();
//   bool resizeScreenKeyboard = true;
//   Timer? timer;

//   void handleSubmitted() {
//     if (_textController.text != '') {
//       // 서버로 전송

//       // 채팅 보내고 서버에서 응답 오면 clear, scroll down
//       _textController.clear();

//       widget.scrollController.animateTo(
//         widget.scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );

//       var newMessage = ChatDetailContent(
//         chatDateTime: DateTime.now().toUtc()..toIso8601String(),
//         chatText: _textController.text,
//         isMe: true,
//       );
//       final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//       chatProvider.addChatContent(newMessage);
//     }
//   }

//   // keyboard focus 제거
//   void unFocusKeyBoard() {
//     FocusScope.of(context).unfocus();
//     if (_isKeyboardOn == true) {
//       setState(() {
//         _isKeyboardOn = false;
//       });
//     }
//   }

//   Color submitBtnColor = const Color(0xffBEBCBC);

//   void onChangedKeyboard(String value) {
//     if (value != "") {
//       setState(() {
//         submitBtnColor = const Color(0xffEC5870);
//       });
//     } else {
//       setState(() {
//         submitBtnColor = const Color(0xffBEBCBC);
//       });
//     }
//   }

//   // 카메라로 사진 추가
//   Future getImageFromCamera(BuildContext context) async {
//     PermissionStatus status = await Permission.camera.request();

//     final ImagePicker picker = ImagePicker();
//     final List<String> imageList = <String>[];

//     if (status.isGranted || status.isLimited) {
//       try {
//         final XFile? pickedImage =
//             await picker.pickImage(source: ImageSource.camera);

//         if (pickedImage != null) {
//           String imagePath = pickedImage.path;

//           setState(() {
//             imageList.add(imagePath);
//           });
//         }
//       } catch (e) {
//         print("Error picking images: $e");
//       }
//     } else if (status.isPermanentlyDenied) {
//       // 나중에 ios는 cupertino로 바꿔줄 필요 있음
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("사진 권한 필요"),
//             content:
//                 const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text("취소"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: const Text("설정으로 이동"),
//                 onPressed: () {
//                   openAppSettings();
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatSettingProvider =
//         Provider.of<ChatSettingProvider>(context, listen: false);
//     // chatSettingProvider.setChatContents(chatDetail.chatContents);

//     return Column(
//       children: [
//         _chatInputField(context, handleSubmitted),
//         _buildAdditionalWidget()
//       ],
//     );
//   }

//   // option box button, chat input field, submit button
//   Widget _chatInputField(BuildContext context, VoidCallback handleSubmitted) {
//     return Container(
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(width: 0.5, color: Color(0xffBEBCBC)),
//         ),
//         color: Colors.white,
//       ),
//       padding: const EdgeInsets.only(top: 12, bottom: 12),
//       margin: const EdgeInsets.symmetric(horizontal: 6.0),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // Option Button
//               IconButton(
//                 onPressed: () async {
//                   // 이미 option box가 올라와있었을 경우
//                   // // chat input field에 focus를 주고 keyboard를 올려준다
//                   if (_isOptionOn == true && _isKeyboardOn == false) {
//                     setState(() {
//                       // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
//                       resizeScreenKeyboard = false;
//                       // 다른 동작이 수행되지 않도록 방지
//                       _blockInteraction = true;
//                       _isKeyboardOn = true;
//                     });
//                     FocusScope.of(context).requestFocus(chatInputFocus);

//                     timer = Timer.periodic(const Duration(milliseconds: 100),
//                         (timer) {
//                       double keyboardHeight =
//                           MediaQuery.of(context).viewInsets.bottom ?? 0;
//                       if (keyboardHeight == _keyboardHeight) {
//                         timer.cancel();
//                         // 다시 키보드가 Screen 영역에 영향을 주도록 변경
//                         setState(() {
//                           resizeScreenKeyboard = true;
//                           _blockInteraction = false;
//                           _isOptionOn = false;
//                         });
//                       }
//                     });

//                     return;
//                   }
//                   // 키보드가 올라와있지 않았을 경우
//                   if (_isKeyboardOn == false) {
//                     setState(() {
//                       _isOptionOn = true;
//                     });
//                     return;
//                   }

//                   // 키보드가 올라외있었을 경우
//                   if (_isKeyboardOn == true) {
//                     setState(() {
//                       // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
//                       resizeScreenKeyboard = false;
//                       // 다른 동작이 수행되지 않도록 방지
//                       _blockInteraction = true;
//                       _isOptionOn = true;
//                     });

//                     unFocusKeyBoard();
//                     // isKeyboardRemoved();
//                     // 키보드의 높이가 0이 될 때가지 0.1초를 주기로 확인
//                     timer = Timer.periodic(const Duration(milliseconds: 100),
//                         (timer) {
//                       double keyboardHeight =
//                           MediaQuery.of(context).viewInsets.bottom ?? 0;
//                       if (keyboardHeight == 0) {
//                         timer.cancel();
//                         // 다시 키보드가 Screen 영역에 영향을 주도록 변경
//                         setState(() {
//                           resizeScreenKeyboard = true;
//                           _blockInteraction = false;
//                         });
//                       }
//                     });
//                   }
//                 },
//                 icon: Icon(
//                   _isKeyboardOn
//                       ? Icons.add_circle_outline
//                       : _isOptionOn
//                           ? Icons.highlight_remove_outlined
//                           : Icons.add_circle_outline,
//                   color: const Color(0xFFBEBCBC),
//                 ),
//               ),
//               // Text Input
//               Flexible(
//                 child: TextField(
//                   focusNode: chatInputFocus,
//                   onTap: () {
//                     if (_isKeyboardOn == false) {
//                       setState(() {
//                         _isKeyboardOn = true;
//                       });
//                     }
//                     // option box가 띄워져있었을 경우
//                     if (_isOptionOn == true) {
//                       setState(() {
//                         // 잠깐 keyboard가 screen에 영향을 주지 않도록 설정
//                         resizeScreenKeyboard = false;
//                         // 다른 동작이 수행되지 않도록 방지
//                         _blockInteraction = true;
//                       });

//                       // 키보드가 완전히 올라올 떄가지 0.1초를 주기로 확인
//                       Timer.periodic(const Duration(milliseconds: 100),
//                           (timer) {
//                         if (MediaQuery.of(context).viewInsets.bottom ==
//                             _keyboardHeight) {
//                           timer.cancel();
//                           setState(() {
//                             _isOptionOn = false;
//                             // 다시 keyboard가 screen에 영향을 주도록 설정
//                             resizeScreenKeyboard = true;

//                             _blockInteraction = false; // 다시 상호작용을 허용
//                           });
//                         }
//                       });
//                     }
//                   },
//                   style: const TextStyle(fontSize: 14.0),
//                   textAlignVertical: TextAlignVertical.center,
//                   controller: _textController,
//                   onChanged: onChangedKeyboard,
//                   maxLines: 5,
//                   minLines: 1,
//                   decoration: const InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(30.0),
//                       ),
//                       borderSide: BorderSide(
//                         color: Color(0xFFBEBCBC),
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(30.0),
//                       ),
//                       borderSide: BorderSide(
//                         color: Color(0xFFBEBCBC),
//                         width: 1,
//                       ),
//                     ),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
//                   ),
//                 ),
//               ),
//               // Submit Button
//               IconButton(
//                 icon: Transform.rotate(
//                   angle: 90 * (pi / 180),
//                   child: Icon(
//                     Icons.navigation,
//                     color: submitBtnColor,
//                   ),
//                 ),
//                 onPressed: handleSubmitted,
//               )
//             ],
//           ),
//           AnimatedContainer(
//             duration: const Duration(microseconds: 300),
//             height: _isKeyboardOn || _isOptionOn ? 0 : 25,
//             curve: Curves.easeOut,
//             child: const SizedBox(),
//           ),
//         ],
//       ),
//     );
//   }

//   // option box contents
//   Widget _buildAdditionalWidget() {
//     Widget circelWidget(IconData icon, String iconText, Function onTap) {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
//         child: Column(
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
//               decoration: const BoxDecoration(
//                 color: Color(0xffE83754),
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(36),
//                 ),
//               ),
//               child: GestureDetector(
//                 onTap: () {
//                   onTap();
//                 },
//                 child: Icon(
//                   icon,
//                   size: 33,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Text(
//               iconText,
//               style: const TextStyle(
//                 color: Color(0xff302E2E),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w400,
//               ),
//             )
//           ],
//         ),
//       );
//     }

//     return SizedBox(
//       height: _isOptionOn ? _keyboardHeight : 0,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 circelWidget(Icons.camera_alt_outlined, '카메라', () {
//                   getImageFromCamera(context);
//                 }),
//                 circelWidget(Icons.image_outlined, '앨범', () {}),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 circelWidget(Icons.credit_card_outlined, '거래정보 발송', () {}),
//                 circelWidget(Icons.vpn_key_outlined, '사물함 정보 발송', () {}),
//               ],
//             ),
//             // option box가 정중앙에 있으면 살짝 아래에 있는 느낌이 들어서 추가한 위젯
//             const SizedBox(
//               height: 15,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
