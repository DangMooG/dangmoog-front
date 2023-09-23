import 'package:flutter/material.dart';

class SingleChatMessage extends StatelessWidget {
  final String text;
  final bool me;
  final bool omit;
  final String time;

  const SingleChatMessage(
      {super.key,
      required this.text,
      required this.me,
      required this.omit,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: omit ? 4 : 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Row의 자식들이 가능한 높이까지 확장되도록 설정
          mainAxisAlignment:
              me ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: me
              ? <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      _chatTime(time, me),
                    ],
                  ),
                  _chatTextBox(text, me),
                ]
              : <Widget>[
                  _userProfileCircle(omit),
                  _chatTextBox(text, me),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      _chatTime(time, me),
                    ],
                  ),
                ],
        ),
      ),
    );
  }

// user profile
  Widget _userProfileCircle(bool omit) {
    return Container(
      width: 35,
      height: 35,
      margin: const EdgeInsets.only(right: 8.0),
      child: omit
          ? const SizedBox(
              width: 35,
            )
          : const CircleAvatar(
              backgroundImage: AssetImage('assets/images/basic_profile.png'),
            ),
    );
  }

  Widget _chatTextBox(String text, bool me) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: me ? const Color(0xFFEC5870) : const Color(0xFFF1F1F1),
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: me ? Colors.white : const Color(0xff302E2E),
        ),
        maxLines: null,
      ),
    );
  }

  Widget _chatTime(String time, bool me) {
    return Padding(
      padding:
          me ? const EdgeInsets.only(right: 4) : const EdgeInsets.only(left: 4),
      child: Text(
        time,
        style: const TextStyle(
          color: Color(0xff726E6E),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
