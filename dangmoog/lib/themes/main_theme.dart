import 'package:flutter/material.dart';

ThemeData mainThemeData() {
  return ThemeData(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
                (states) => Colors.transparent))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
                (states) => Colors.transparent))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
                (states) => Colors.transparent))),
    buttonTheme: const ButtonThemeData(highlightColor: Colors.transparent),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
                (states) => Colors.transparent))),
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFE20529),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Pretendard',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
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
