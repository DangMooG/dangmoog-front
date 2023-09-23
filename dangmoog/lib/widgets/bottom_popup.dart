import 'package:flutter/material.dart';

void showPopup(BuildContext context, String message) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100.0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Center(child: FadePopup(message: message)),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

class FadePopup extends StatefulWidget {
  final String message;

  const FadePopup({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<FadePopup> createState() => _FadePopupState();
}

class _FadePopupState extends State<FadePopup> {
  double opacityLevel = 0.8;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        opacityLevel = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1000),
      opacity: opacityLevel,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xff302E2E)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Text(
          widget.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
