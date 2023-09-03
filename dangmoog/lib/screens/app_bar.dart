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
          color: Color(0xFFE20529),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
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
          color: const Color(0xFF302E2E),
        ),
      ),
    ],
    bottom: appBarBottomLine(),
  );
}

AppBar _chatListAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: appBarTitle("채팅 내역"),
    bottom: appBarBottomLine(),
  );
}

AppBar _myPageAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: appBarTitle("마이 도토릿"),
    bottom: appBarBottomLine(),
  );
}

Text appBarTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      color: Color(0xff302E2E),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
}

PreferredSize appBarBottomLine() {
  return const PreferredSize(
    preferredSize: Size.fromHeight(0.0),
    child: Divider(
      color: Color(0xFFBEBCBC),
      height: 1,
      thickness: 1,
      indent: 0,
      endIndent: 0,
    ),
  );
}
