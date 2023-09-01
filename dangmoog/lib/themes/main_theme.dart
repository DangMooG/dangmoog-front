import 'package:flutter/material.dart';

ThemeData mainThemeData() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFE20529),
    fontFamily: 'Pretendard',
    // textTheme: const TextTheme(
    //   displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    //   titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    //   bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    // ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xffE20529),
      unselectedItemColor: Color(0xffA19E9E),
      selectedLabelStyle: TextStyle(
        color: Color(0xffE20529),
        fontFamily: 'Pretendard',
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color(0xffE20529),
        fontFamily: 'Pretendard',
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
