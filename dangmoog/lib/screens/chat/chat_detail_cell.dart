import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool me;
  final bool omit;

  const ChatMessage(
      {super.key, required this.text, required this.me, required this.omit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: omit ? 8.0 : 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: me
            ? <Widget>[
                CellBox(
                  text: text,
                  me: me,
                ),
              ]
            : <Widget>[
                omit
                    ? const SizedBox(
                        width: 42,
                      )
                    : const UserProfileCircle(),
                CellBox(
                  text: text,
                  me: me,
                ),
              ],
      ),
    );
  }
}

class UserProfileCircle extends StatelessWidget {
  const UserProfileCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      margin: const EdgeInsets.only(right: 8.0),
      child: const CircleAvatar(
        child: Image(
          image: AssetImage('assets/images/temp_user_img.png'),
          width: 35,
        ),
      ),
    );
  }
}

class CellBox extends StatelessWidget {
  const CellBox({
    super.key,
    required this.text,
    required this.me,
  });

  final String text;
  final bool me;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      padding: const EdgeInsets.only(top: 9, bottom: 9, left: 12, right: 12),
      decoration: BoxDecoration(
          color: me ? const Color(0xFF552619) : const Color(0xFFCCBEBA),
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14.0, color: Colors.white),
        maxLines: null,
      ),
    );
  }
}
