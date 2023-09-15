import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final Color color;
  final VoidCallback onPressed;

  AuthButton(
      {required this.text,
      required this.textcolor,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Container(
        width: screenSize.width * 0.81,
        height: screenSize.height * 0.056,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textcolor,
            fontFamily: 'Pretendard-Medium',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
