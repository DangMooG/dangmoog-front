import 'package:flutter/material.dart';

class ChatDealStatus extends StatefulWidget {
  const ChatDealStatus({super.key});

  @override
  State<ChatDealStatus> createState() => _ChatDealStatusState();
}

class _ChatDealStatusState extends State<ChatDealStatus> {
  String dealStatus = "판매중";

  Color buttonColor = const Color(0xffE20529);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Text("가나다라마사사"),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: buttonColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dealStatus,
              style: TextStyle(
                color: buttonColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_sharp,
              color: buttonColor,
            ),
          ],
        ),
      ),
    );
  }
}
