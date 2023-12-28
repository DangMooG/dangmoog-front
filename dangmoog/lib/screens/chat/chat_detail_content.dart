import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/screens/chat/chat_detail_cell.dart';
import 'package:dangmoog/utils/convert_day_format.dart';
import 'package:dangmoog/utils/convert_time_format.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class ChatContents extends StatefulWidget {
  final ScrollController scrollController;

  const ChatContents({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<ChatContents> createState() => _ChatContentsState();
}

class _ChatContentsState extends State<ChatContents> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          List<ChatDetailContent> chatContents = chatProvider.chatContents;

          // 데이터가 비어 있으면 아무것도 반환하지 않음
          if (chatContents.isEmpty) {
            return Container(
              height: double.infinity,
            );
          }

          return Stack(
            children: [
              ListView.builder(
                controller: widget.scrollController,
                reverse: false,
                itemCount: chatContents.isNotEmpty
                    ? chatContents.length
                    : 1, // 비어 있을 경우 하나의 빈 아이템을 가진 리스트를 만듭니다.
                itemBuilder: (context, index) {
                  final singleChat = chatContents[index];

                  var omit = false;
                  var dateVisible = false;

                  // 맨 첫 채팅이 아니라면
                  if (index != 0) {
                    // 이전 채팅과 같은 유저이면서 같은 날짜이면
                    // -> 프로필 중복 표시 제거
                    if ((chatContents[index - 1].isMe == singleChat.isMe) &&
                        (isDifferentDate(chatContents[index - 1].chatDateTime,
                                singleChat.chatDateTime) ==
                            false)) {
                      omit = true;
                    } else {
                      // 이전 채팅과 다른 유저이면서 이전 채팅과 다른 날짜이면 -> 날짜 위젯 표시
                      if (isDifferentDate(chatContents[index - 1].chatDateTime,
                          singleChat.chatDateTime)) {
                        dateVisible = true;
                      }
                    }
                  } else {
                    dateVisible = true;
                  }
                  return Column(
                    children: [
                      dateVisible
                          ? _buildChatDay(singleChat.chatDateTime)
                          : const SizedBox.shrink(),
                      SingleChatMessage(
                        text: singleChat.chatText,
                        me: singleChat.isMe,
                        omit: omit,
                        time: convertTimeFormat(singleChat.chatDateTime),
                      )
                    ],
                  );
                },
              ),
              Positioned(
                right: 0,
                bottom: 23,
                child: GestureDetector(
                  onTap: () {
                    widget.scrollController.animateTo(
                      widget.scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                        decoration:
                            const BoxDecoration(color: Color(0xffF28C9D)),
                        height: 48,
                        width: 48,
                        child: Transform.rotate(
                          angle: -pi / 2,
                          child: const Icon(
                            Icons.keyboard_backspace,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// 채팅 간 날짜 다를 경우 구분
Widget _buildChatDay(DateTime dateTime) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    decoration: const BoxDecoration(
      color: Color(0xffD3D2D2),
      borderRadius: BorderRadius.all(Radius.circular(11)),
    ),
    child: Text(
      convertDayFormat(dateTime),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
  );
}

// 다른 날짜 인지 확인
bool isDifferentDate(DateTime date1, DateTime date2) {
  return date1.day != date2.day ||
      date1.month != date2.month ||
      date1.year != date2.year;
}
