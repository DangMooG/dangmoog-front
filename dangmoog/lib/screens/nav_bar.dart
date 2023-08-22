import 'package:flutter/material.dart';

import 'package:dangmoog/constants/navbar_icon.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentTabIndex;
  final Function(int) onTap;

  const MainNavigationBar({
    super.key,
    required this.currentTabIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: BottomNavigationBar(
        currentIndex: currentTabIndex,
        onTap: onTap,
        items: navbarItems,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xffc30020),
        unselectedItemColor: const Color(0xffc30020),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}










// Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromARGB(96, 22, 21, 21),
//               spreadRadius: 1,
//               blurRadius: 8,
//             ),
//           ],
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(10.0),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(10.0),
//           ),
//           child: BottomNavigationBar(
//             backgroundColor: Colors.white,
//             currentIndex: currentTabIndex,
//             onTap: (index) {
//               setState(() {
//                 currentTabIndex = index;
//               });
//             },
//             //BottomNavigation item list
//             items: navbarItems,

//             // selected or unselected style
//             selectedItemColor: const Color(0xffc30020),
//             unselectedItemColor: const Color(0xffc30020),
//             selectedLabelStyle: const TextStyle(
//               fontSize: 11,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 11,
//             ),

//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//           ),
//         ),
//       ),