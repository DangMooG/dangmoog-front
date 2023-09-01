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
      ),
    );
  }
}
