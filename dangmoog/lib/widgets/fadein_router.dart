import 'package:flutter/material.dart';

Route fadeInRouting(Widget routedWidget) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => routedWidget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeIn;
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      var tween = Tween(begin: 0.0, end: 1.0);
      var fadeAnimation = tween.animate(curvedAnimation);

      return FadeTransition(
        opacity: fadeAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}
