import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // 기본 AppBar 높이

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        child: const Icon(
          Icons.keyboard_backspace,
          color: Color(0xFF726E6E),
          size: 24,
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
