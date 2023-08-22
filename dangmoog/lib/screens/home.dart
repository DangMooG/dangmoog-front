import 'package:flutter/material.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list.dart';
import 'package:dangmoog/screens/post/main_page.dart';
import 'package:dangmoog/screens/temp/temp_page.dart';

import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/nav_bar.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int currentTabIndex = 0;

  final List<Widget> _bodyPage = <Widget>[
    const MainPage(), // Post List Page
    const TempPage(), // home page (추후 업데이트를 위한 여유 페이지)
    const ChatList(), // Chat List Page
    const MyPage() // MyPage
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(currentTabIndex),
      body: Center(
        child: _bodyPage.elementAt(currentTabIndex),
      ),
      floatingActionButton: currentTabIndex == 0
          ? FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              highlightElevation: 0,
              disabledElevation: 0,
              onPressed: () {},
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset('assets/images/add_icon.png'),
            )
          : null,
      bottomNavigationBar: MainNavigationBar(
        currentTabIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
    );
  }
}
