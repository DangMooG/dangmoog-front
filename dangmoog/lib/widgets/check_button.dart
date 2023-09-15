import 'package:flutter/material.dart';

class CheckButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  CheckButton(
      {required this.text, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size(
          screenSize.width * 0.25,
          screenSize.height * 0.034,
        ),
      ),
      child: Container(
        width: screenSize.width * 0.81,
        height: screenSize.height * 0.056,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard-Medium',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
