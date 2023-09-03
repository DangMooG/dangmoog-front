import 'package:flutter/material.dart';

import 'package:dangmoog/screens/chat/chat_detail_page.dart';

class ChatCell extends StatefulWidget {
  final String userNickName, lastMsg;
  final int productId, userId, chatId;
  final DateTime lastDate;

  const ChatCell({
    super.key,
    required this.userNickName,
    required this.lastMsg,
    required this.productId,
    required this.userId,
    required this.chatId,
    required this.lastDate,
  });

  @override
  State<ChatCell> createState() => _ChatCellState();
}

class _ChatCellState extends State<ChatCell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatDetail(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 2,
        ),
        child: SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Image(
                image: AssetImage('assets/images/temp_user_img.png'),
                width: 48,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 11, right: 11),
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.userNickName),
                            const Text(' ∙ '),
                            Text(
                                '${widget.lastDate.year}.${widget.lastDate.month}.${widget.lastDate.day}'),
                          ],
                        ),
                        Text(
                          widget.lastMsg,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Image(
                image: AssetImage('assets/images/temp_product_img.png'),
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
