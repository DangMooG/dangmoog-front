import 'package:flutter/material.dart';

class ChatCell extends StatefulWidget {
  // final Object cellInfo;

  const ChatCell({
    super.key,
    // required this.cellInfo,
  });

  @override
  State<ChatCell> createState() => _ChatCellState();
}

class _ChatCellState extends State<ChatCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xffCCBEBA),
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('유저 사진'),
          Column(
            children: [
              Row(
                children: [
                  Text('닉네임'),
                  Text('2000-00-00'),
                ],
              ),
              Text('물건 잘 받았습니다...!'),
            ],
          ),
          Text('물품 사진')
        ],
      ),
    );
  }
}
