import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:dangmoog/screens/chat/chat_detail_cell.dart';
import 'package:dangmoog/utils/convert_day_format.dart';
import 'package:dangmoog/utils/convert_time_format.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class ChatContents extends StatefulWidget {
  const ChatContents({super.key});

  @override
  State<ChatContents> createState() => _ChatContentsState();
}

class _ChatContentsState extends State<ChatContents> {
  ChatDetailModel? _chatDetail;

  // 채팅 데이터 로딩
  Future<void> _loadChatDetailInit(String url) async {
    final String jsonChatDetail = await rootBundle.loadString(url);
    final Map<String, dynamic> jsonChatDetailResponse =
        json.decode(jsonChatDetail);

    setState(() {
      _chatDetail = ChatDetailModel.fromJson(jsonChatDetailResponse);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadChatDetailInit('assets/chat_detail.json');
  }

  @override
  Widget build(BuildContext context) {
    if (_chatDetail == null) {
      return const CircularProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        reverse: false,
        itemCount: _chatDetail!.chatContents.isNotEmpty
            ? _chatDetail!.chatContents.length
            : 1, // 비어 있을 경우 하나의 빈 아이템을 가진 리스트를 만듭니다.
        itemBuilder: (context, index) {
          final singleChat = _chatDetail!.chatContents[index];

          var omit = false;
          var dateVisible = false;

          // 맨 첫 채팅이 아니라면
          if (index != 0) {
            // // 이전 채팅과 같은 유저인지 -> 프로필 중복 표시 제거
            if (_chatDetail!.chatContents[index - 1].isMe == singleChat.isMe) {
              omit = true;
            }
            // // 이전 채팅과 다른 날짜인지 -> 날짜 위젯 표시
            if (isDifferentDate(
                _chatDetail!.chatContents[index - 1].chatDateTime,
                singleChat.chatDateTime)) {
              dateVisible = true;
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

          // if (index == 0) {
          //   return Column(
          //     children: [
          //       dateVisible
          //           ? _buildChatDay(singleChat.chatDateTime)
          //           : const SizedBox.shrink(),
          //       SingleChatMessage(
          //         text: singleChat.chatText,
          //         me: singleChat.isMe,
          //         omit: omit,
          //         time: convertTimeFormat(singleChat.chatDateTime),
          //       )
          //     ],
          //   );
          // }

          // return SingleChatMessage(
          //   text: singleChat.chatText,
          //   me: singleChat.isMe,
          //   omit: omit,
          //   time: convertTimeFormat(singleChat.chatDateTime),
          // );
        },
      ),
    );
  }
}

Widget _buildChatDay(DateTime dateTime) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
    margin: const EdgeInsets.only(top: 8),
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

bool isDifferentDate(DateTime date1, DateTime date2) {
  return date1.day != date2.day ||
      date1.month != date2.month ||
      date1.year != date2.year;
}
