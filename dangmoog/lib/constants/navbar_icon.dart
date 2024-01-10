import 'package:flutter/material.dart';

List<BottomNavigationBarItem> navbarItems = [
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
  const BottomNavigationBarItem(
    icon: Icon(Icons.forum_outlined),
    activeIcon: Icon(Icons.forum),
    label: '채팅 내역',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.person_outline),
    activeIcon: Icon(Icons.person),
    label: '마이도토릿',
  ),
];
