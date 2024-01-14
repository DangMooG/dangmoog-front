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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        // vertical: 8,
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          height: screenSize.height * 0.052,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: const Color(0xFF302E2E),
                size: 24,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
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
        ),
      ),
    );
    // return SizedBox(
    //   height: screenSize.height * 0.052,
    //   child: Row(
    //     children: [
    //       TextButton.icon(
    //         onPressed: onPressed,
    //         icon: Icon(
    //           icon,
    //           color: const Color(0xFF302E2E),
    //           size: 24,
    //         ),
    //         label: Text(
    //           text,
    //           style: const TextStyle(
    //             color: Color(0xFF302E2E),
    //             fontSize: 16,
    //             fontWeight: FontWeight.w400,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
