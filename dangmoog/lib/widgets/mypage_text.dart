import 'package:flutter/material.dart';

class MypageText extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  MypageText({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: screenSize.width * 0.04),
      child: Container(
        height: screenSize.height * 0.049,
        child: Row(
          children: [
            Icon(
              icon,
              color: Color(0xFF302E2E),
              size: 24,
            ),
            SizedBox(width: 8),
            TextButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: TextStyle(
                  color: Color(0xFF302E2E),
                  fontFamily: 'Pretendard-Regular',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
