import 'package:flutter/material.dart';

import 'package:dangmoog/constants/navbar_icon.dart';

import 'package:dangmoog/screens/mypage/my_page.dart';
import 'package:dangmoog/screens/chat/chat_list.dart';
import 'package:dangmoog/screens/post/main_page.dart';
import 'package:dangmoog/screens/addpage/add_page.dart';
import 'package:dangmoog/screens/temp/temp_page.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int currentTapIndex = 0;

  final List<Widget> _bodyPage = <Widget>[
    // 아래 임시 widgets을 각자 구현한 widget으로 교체해주시면 됩니다
    const MainPage(), // Post List Page
    const TempPage(), // home page (추후 업데이트를 위한 여유 페이지)
    // const TempPage(), // 게시글 작성 페이지로 가야하는데, 일단 임시로
    const ChatList(), // Chat List Page
    const MyPage() // MyPage
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentTapIndex != 2 // Check if the current page is not UploadProductPage
          ? AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "전역 변수로 받아서 사용할 예정", // Header는 일단 빼고 진행해주세요
          ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0), // You can change the height
          child: Container(
            color: const Color(0xffA07272), // Your line color
            height: 2.0, // You can change the height
          ),
        ),
      ):null,
      body: Center(
        child: Container(child: _bodyPage.elementAt(currentTapIndex)),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
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
            currentIndex: currentTapIndex,
            onTap: (index) {
              setState(() {
                currentTapIndex = index;
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
