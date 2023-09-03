import 'package:flutter/material.dart';

import 'package:dangmoog/constants/mock_data/chat_detail_mock.dart';
import 'package:dangmoog/models/chat_cell_class.dart';
import 'package:dangmoog/screens/chat/chat_detail_cell.dart';
import 'package:dangmoog/models/chat_detail_model.dart';

import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  late List<ChatCell> _chatDetail = <ChatCell>[];

  late Future<ChatDetailModel> _chatDetail2;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isOptionOn = false;
  bool _isKeyboardOn = false;

  void toggleOption() {
    setState(() {
      _isOptionOn = !_isOptionOn;
    });
  }

  void hideOption() {
    setState(() {
      _isOptionOn = false;
    });
  }

  void unFocusKeyBoard() {
    FocusScope.of(context).unfocus();
    if (_isKeyboardOn == true) {
      setState(() {
        _isKeyboardOn = false;
      });
    }
  }

  List<ChatCell> convertMockToChatDetail(List<dynamic> mockData) {
    return mockData.map((item) {
      var data = item as Map<String, dynamic>;
      return ChatCell(
        text: data['text'],
        me: data['me'],
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _chatDetail = convertMockToChatDetail(chatDetailMock);
    });

    _chatDetail2 = _loadChatDetailFromAsset('assets/chat_detail.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildChatDetailAppBar(_chatDetail2),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildChatProductInfo(_chatDetail2),
            Expanded(
              child: GestureDetector(
                onTap: unFocusKeyBoard,
                child: Expanded(
                  child: Column(
                    children: <Widget>[
                      _buildChatContents(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildInputField(),
                          Positioned(
                            right: 15,
                            top: -60,
                            child: FloatingActionButton(
                              onPressed: () {
                                _scrollController.animateTo(
                                  _scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                              mini: true,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              backgroundColor: const Color(0xFFCCBEBA),
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Flexible _buildChatContents() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          reverse: true,
          controller: _scrollController,
          itemBuilder: (_, index) {
            if (_chatDetail.isNotEmpty) {
              final chatDetailItem = _chatDetail[index];

              // 전 cell과 같은 user인지
              var omit = false;
              if (index != _chatDetail.length - 1) {
                if (_chatDetail[index + 1].me == chatDetailItem.me) {
                  omit = true;
                }
              }

              return ChatMessage(
                text: chatDetailItem.text,
                me: chatDetailItem.me,
                omit: omit,
              );
            }
            return Container();
          },
          itemCount: _chatDetail.isNotEmpty
              ? _chatDetail.length
              : 1, // 비어 있을 경우 하나의 빈 아이템을 가진 리스트를 만듭니다.
        ),
      ),
    );
  }

  Widget _buildInputField() {
    void handleSubmitted(String text) {
      _textController.clear();
      var message = ChatCell(
        text: text,
        me: true,
      );
      setState(() {
        _chatDetail.insert(0, message);
      });
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Container(
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
                      onPressed: () {
                        if (_isKeyboardOn == false) {
                          toggleOption();
                        }
                        if (_isKeyboardOn == true) {
                          unFocusKeyBoard();
                          toggleOption();
                        }
                      },
                      icon: Transform.rotate(
                        angle: _isOptionOn ? (pi / 4) : 0,
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFFA07272),
                        ),
                      ),
                    ),
                    // Text Input
                    Flexible(
                      child: TextField(
                        onTap: () {
                          if (_isKeyboardOn == false) {
                            setState(() {
                              _isKeyboardOn = true;
                            });
                          }

                          if (_isOptionOn == true) {
                            toggleOption();
                          }
                        },
                        style: const TextStyle(fontSize: 14.0),
                        textAlignVertical: TextAlignVertical.center,
                        controller: _textController,
                        onSubmitted: handleSubmitted,
                        maxLines: 5,
                        minLines: 1,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                            borderSide: BorderSide(
                              color: Color(0xFFA07272),
                              width: 3,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5.0),
                        ),
                      ),
                    ),
                    // Submit Button
                    IconButton(
                        icon: Transform.rotate(
                          angle: 90 * (pi / 180),
                          child: const Icon(
                            Icons.navigation,
                            color: Color(0xFFA07272),
                          ),
                        ),
                        onPressed: () {
                          if (_textController.text != '') {
                            handleSubmitted(_textController.text);
                          }
                        }),
                  ],
                ),
                AnimatedContainer(
                  height: _isKeyboardOn || _isOptionOn ? 0 : 25,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                ),
              ],
            ),
          ),
        ),
        _buildAdditionalWidget()
      ],
    );
  }

  Widget _buildAdditionalWidget() {
    return AnimatedContainer(
      height: _isOptionOn ? 250.0 : 0,
      duration: const Duration(milliseconds: 0),
      curve: Curves.ease,
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '사진 업로드',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFFCCBEBA),
              ),
              TextButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '사진 촬영',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFFCCBEBA),
              ),
              TextButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '계좌 정보 전송',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFFCCBEBA),
              ),
              TextButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '위탁 사물함 번호 및 비밀번호 발송',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AppBar
AppBar _buildChatDetailAppBar(Future<ChatDetailModel> futureChatDetail) {
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
            style: const TextStyle(color: Color(0xFF552619)),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ),
    backgroundColor: Colors.white,
    shape: const Border(
      bottom: BorderSide(
        color: Color(0xFFA07272),
        width: 1,
      ),
    ),
  );
}

// ProductInfo
Container _buildChatProductInfo(Future<ChatDetailModel> futureChatDetail) {
  return Container(
    decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                width: 1,
                color: Color(
                  0xFFCCBEBA,
                )))),
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    child: FutureBuilder<ChatDetailModel>(
      future: futureChatDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading chat list!'),
            );
          }
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image(
                  image: AssetImage(snapshot.data!.chatInfo.productPhotoUrl),
                  width: 48,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          child: const Text('거래상태'), // 공통 widget으로 교체 예정
                        ),
                      ),
                      Text(
                        snapshot.data!.chatInfo.postTitle,
                        style: const TextStyle(
                          color: Color(0xFF552619),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Text(
                    NumberFormat('###,###,###원', 'ko_KR')
                        .format(snapshot.data!.chatInfo.productPrice),
                    style: const TextStyle(
                      color: Color(0xFF552619),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ),
  );
}
    

// Container _buildChatProductInfo(
//     String imgUrl, String postTitle, int productPrice) {
//   return Container(
//     decoration: const BoxDecoration(
//         border: Border(
//             bottom: BorderSide(
//                 width: 1,
//                 color: Color(
//                   0xFFCCBEBA,
//                 )))),
//     padding: const EdgeInsets.symmetric(
//       horizontal: 20,
//       vertical: 12,
//     ),
//     child: Row(
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(right: 8),
//           child: Image(
//             image: AssetImage('assets/images/temp_product_img.png'),
//             width: 48,
//           ),
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 10),
//                   child: Container(
//                     padding: const EdgeInsets.all(3),
//                     decoration: BoxDecoration(border: Border.all(width: 1)),
//                     child: const Text('거래상태'), // 공통 widget으로 교체 예정
//                   ),
//                 ),
//                 const Text(
//                   '게시글 제목',
//                   style: TextStyle(color: Color(0xFF552619)),
//                 )
//               ],
//             ),
//             const Text(
//               '제품 가격',
//               style: TextStyle(color: Color(0xFF552619)),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }






// AppBar _buildChatDetailAppBar(String nickName) {
//   return AppBar(
//     title: Text(
//       nickName,
//       style: const TextStyle(color: Color(0xFF552619)),
//     ),
//     backgroundColor: Colors.white,
//     shape: const Border(
//       bottom: BorderSide(
//         color: Color(0xFFA07272),
//         width: 1,
//       ),
//     ),
//   );
// }




// Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: _buildChatDetailAppBar('상대 닉네임'),
//       appBar: _buildChatDetailAppBar(_chatInfo.userNickName),
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // _buildChatProductInfo(
//             // 'assets/images/temp_product_img.png', '게시글 제목', 30000), 
//             _buildChatProductInfo(_chatInfo.productPhotoUrl,
//                 _chatInfo.postTitle, _chatInfo.productPrice),
//             Expanded(
//               child: GestureDetector(
//                 onTap: unFocusKeyBoard,
//                 child: Expanded(
//                   child: Column(
//                     children: <Widget>[
//                       Flexible(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: ListView.builder(
//                             padding: const EdgeInsets.all(8.0),
//                             reverse: true,
//                             itemBuilder: (_, index) {
//                               if (_chatDetail.isNotEmpty) {
//                                 final chatDetailItem = _chatDetail[index];

//                                 // 전 cell과 같은 user인지
//                                 var omit = false;
//                                 if (index != _chatDetail.length - 1) {
//                                   if (_chatDetail[index + 1].me ==
//                                       chatDetailItem.me) {
//                                     omit = true;
//                                   }
//                                 }

//                                 return ChatMessage(
//                                   text: chatDetailItem.text,
//                                   me: chatDetailItem.me,
//                                   omit: omit,
//                                 );
//                               }
//                               return Container();
//                             },
//                             itemCount: _chatDetail.isNotEmpty
//                                 ? _chatDetail.length
//                                 : 1, // 비어 있을 경우 하나의 빈 아이템을 가진 리스트를 만듭니다.
//                           ),
//                         ),
//                       ),
//                       _buildInputField(),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }