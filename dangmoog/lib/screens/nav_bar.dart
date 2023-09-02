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
        border: Border(
          top: BorderSide(
            color: Color(
              0xffBEBCBC,
            ),
            width: 0.5,
          ),
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
