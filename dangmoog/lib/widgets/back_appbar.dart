import 'package:flutter/material.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget MyTargetScreen;

  BackAppBar({required this.MyTargetScreen});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_backspace,
          color: Color(0xFF726E6E),
        ),
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MyTargetScreen,
            ),
          );
        },
      ),
    );
  }
}
