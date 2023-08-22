import 'package:flutter/material.dart';

AppBar mainAppBar(int currentTabIndex) {
  switch (currentTabIndex) {
    case 0:
      return _postListAppbar();
    case 1:
      return _postListAppbar();
    case 2:
      return _chatListAppbar();
    case 3:
      return _myPageAppbar();
    default:
      return _postListAppbar();
  }
}

AppBar _postListAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    leadingWidth: 200,
    leading: Container(
      margin: const EdgeInsets.only(left: 15, top: 13),
      child: const Text(
        'DOTORIT',
        style: TextStyle(
            color: Color(0xFFC30020),
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(
          top: 5,
          right: 10,
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            size: 26,
          ),
          color: const Color(0xFFA07272),
        ),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: Container(
        color: const Color(0xFFA07272),
        height: 2.0,
      ),
    ),
  );
}

AppBar _chatListAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Text(
      "채팅 내역",
      style: TextStyle(
        color: Color(0xff552619),
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: Container(
        color: const Color(0xFFA07272),
        height: 2.0,
      ),
    ),
  );
}

AppBar _myPageAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Text(
      "마이 도토릿",
      style: TextStyle(
        color: Color(0xff552619),
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: Container(
        color: const Color(0xFFA07272),
        height: 2.0,
      ),
    ),
  );
}
