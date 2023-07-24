import 'package:flutter/material.dart';

List<BottomNavigationBarItem> navbarItems = [
  const BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: '홈',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.assignment_outlined),
    activeIcon: Icon(Icons.assignment),
    label: '게시판',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.add_circle_outline),
    activeIcon: Icon(Icons.add_circle),
    label: '추가하기',
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
