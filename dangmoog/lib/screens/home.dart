import 'package:flutter/material.dart';

import 'package:dangmoog/constants/navbar_icon.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list.dart';
import 'package:dangmoog/screens/post/main_page.dart';
import 'package:dangmoog/screens/temp/temp_page.dart';

import 'package:dangmoog/screens/app_bar.dart';

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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(96, 22, 21, 21),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: currentTabIndex,
            onTap: (index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            //BottomNavigation item list
            items: navbarItems,

            // selected or unselected style
            selectedItemColor: const Color(0xffc30020),
            unselectedItemColor: const Color(0xffc30020),
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),

            showUnselectedLabels: true,

            //BottomNavigationBar Type -> fixed = bottom item size고정
            //BottomNavigationBar Type -> shifting = bottom item selected 된 item이 확대
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
