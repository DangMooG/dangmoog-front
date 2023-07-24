import 'package:flutter/material.dart';

import 'package:dangmoog/widgets/chat_cell.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    // var listView = ListView.separated(
    //   padding: const EdgeInsets.all(8),
    //   itemCount: chatListMock.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return ChatCell(chatListMock[index]);
    //   },
    //   separatorBuilder: (BuildContext context, int index) {
    //     return const Divider();
    //   },
    // );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 342,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: null,
                    child: const Center(child: Text('판매')),
                  ),
                  const ElevatedButton(
                    onPressed: null,
                    child: Center(child: Text('구매')),
                  )
                ],
              ),
            ),
            const Column(
              children: chatCellList,
            )
          ],
        ),
      ),
    );
  }
}

const List<Widget> chatCellList = [
  ChatCell(),
  ChatCell(),
  ChatCell(),
  ChatCell(),
  ChatCell(),
];
