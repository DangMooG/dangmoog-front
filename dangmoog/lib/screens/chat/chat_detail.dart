import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:dangmoog/constants/mock_data/chat_detail_mock.dart';
import 'package:dangmoog/models/chat_cell_class.dart';
import 'package:dangmoog/screens/chat/chat_detail_cell.dart';

class ChatDetail extends StatefulWidget {
  const ChatDetail({super.key});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  late List<ChatCell> _chatDetail = <ChatCell>[];
  final TextEditingController _textController = TextEditingController();

  bool optionButton = false;

  bool _isKeyboardOn = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '상대 닉네임',
          style: TextStyle(color: Color(0xFF552619)),
        ),
        backgroundColor: Colors.white,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFA07272),
            width: 1,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 제품 정보
            Container(
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
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Image(
                      image: AssetImage('assets/images/temp_product_img.png'),
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
                          const Text(
                            '게시글 제목',
                            style: TextStyle(color: Color(0xFF552619)),
                          )
                        ],
                      ),
                      const Text(
                        '제품 가격',
                        style: TextStyle(color: Color(0xFF552619)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if (_isKeyboardOn == true) {
                    setState(() {
                      _isKeyboardOn = false;
                    });
                  }
                },
                child: Expanded(
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            reverse: true,
                            itemBuilder: (_, index) {
                              if (_chatDetail.isNotEmpty) {
                                final chatDetailItem = _chatDetail[index];

                                // 전 cell과 같은 user인지
                                var omit = false;
                                if (index != _chatDetail.length - 1) {
                                  if (_chatDetail[index + 1].me ==
                                      chatDetailItem.me) {
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
                      ),
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
                        child: _buildTextInputField(optionButton),
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

  Widget _buildTextInputField(bool optionOn) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    optionOn = !optionOn;
                  });
                },
                icon: Transform.rotate(
                  angle: optionButton ? 0 : 90 * (math.pi / 180),
                  child: const Icon(Icons.add_circle_outline),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    if (_isKeyboardOn == false) {
                      setState(() {
                        _isKeyboardOn = true;
                      });
                    }
                  },
                  child: SizedBox(
                    child: TextField(
                      onTap: () {
                        if (_isKeyboardOn == false) {
                          setState(() {
                            _isKeyboardOn = true;
                          });
                        }
                      },
                      style: const TextStyle(fontSize: 14.0),
                      textAlignVertical: TextAlignVertical.center,
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      maxLines: 5,
                      minLines: 1,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 5.0),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: Transform.rotate(
                    angle: 90 * (math.pi / 180),
                    child: const Icon(Icons.navigation),
                  ),
                  onPressed: () {
                    if (_textController.text != '') {
                      _handleSubmitted(_textController.text);
                    }
                  }),
            ],
          ),
          AnimatedContainer(
            height: _isKeyboardOn ? 0 : 25,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    var message = ChatCell(
      text: text,
      me: true,
    );
    setState(() {
      _chatDetail.insert(0, message);
    });
  }
}
