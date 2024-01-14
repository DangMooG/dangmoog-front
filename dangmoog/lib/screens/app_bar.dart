import 'package:flutter/material.dart';

import 'package:dangmoog/widgets/bottom_popup.dart';

AppBar? mainAppBar(int currentTabIndex, BuildContext context) {
  switch (currentTabIndex) {
    case 0:
      return _postListAppbar(context);
    case 1:
      return null;
    case 2:
      return _chatListAppbar();
    case 3:
      return _myPageAppbar();
    default:
      return _postListAppbar(context);
  }
}

AppBar _postListAppbar(BuildContext context) {
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
          onPressed: () {
            showPopup(context, "서비스 예정입니다");
          },
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
    centerTitle: true,
    bottom: appBarBottomLine(),
  );
}

AppBar _myPageAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    title: appBarTitle("마이 도토릿"),
    centerTitle: true,
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
