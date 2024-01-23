import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/constants/navbar_icon.dart';
import 'package:provider/provider.dart';

class MainNavigationBar extends StatefulWidget {
  final int currentTabIndex;
  final Function(int) onTap;

  const MainNavigationBar({
    super.key,
    required this.currentTabIndex,
    required this.onTap,
  });

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
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
        currentIndex: widget.currentTabIndex,
        onTap: widget.onTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: '관심 목록',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.forum_outlined),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Consumer<ChatListProvider>(
                      builder: (context, chatProvider, _) {
                    int buyUnreadCount = chatProvider.buyUnreadCount;
                    int sellUnreadCount = chatProvider.sellUnreadCount;

                    if (buyUnreadCount + sellUnreadCount == 0) {
                      return const SizedBox.shrink();
                    }

                    return ClipOval(
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xffD3D2D2),
                        ),
                        child: Text(
                          '${buyUnreadCount + sellUnreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.forum),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Consumer<ChatListProvider>(
                      builder: (context, chatProvider, _) {
                    int buyUnreadCount = chatProvider.buyUnreadCount;
                    int sellUnreadCount = chatProvider.sellUnreadCount;

                    if (buyUnreadCount + sellUnreadCount == 0) {
                      return const SizedBox.shrink();
                    }

                    return ClipOval(
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xffF28C9D),
                        ),
                        child: Text(
                          '${buyUnreadCount + sellUnreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            label: '채팅 내역',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이도토릿',
          ),
        ],
      ),
    );
  }
}
