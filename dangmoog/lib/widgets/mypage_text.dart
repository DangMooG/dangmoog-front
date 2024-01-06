import 'package:flutter/material.dart';

class MypageText extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const MypageText(
      {super.key,
      required this.text,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height * 0.049,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: const Color(0xFF302E2E),
              size: 24,
            ),
            label: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF302E2E),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
