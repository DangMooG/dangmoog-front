import 'package:flutter/material.dart';

class SingleChatMessage extends StatelessWidget {
  final String text;
  final bool me;
  final bool profileOmit;
  final String time;

  const SingleChatMessage(
      {super.key,
      required this.text,
      required this.me,
      required this.profileOmit,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: profileOmit ? 4 : 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  _userProfileCircle(profileOmit),
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
  Widget _userProfileCircle(bool profileOmit) {
    return Container(
      width: 35,
      height: 35,
      margin: const EdgeInsets.only(right: 8.0),
      child: profileOmit
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
      child: SelectableText(
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
