import 'package:flutter/material.dart';

class AuthSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isActive;

  const AuthSubmitButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (isActive) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFFEC5870);
            }
            return const Color(0xFFE20529);
          } else {
            return const Color(0xffD3D2D2);
          }
        }),
        // padding: MaterialStateProperty.all(EdgeInsets.zero),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Container(
        width: screenSize.width * 0.80,
        height: 47,
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Color(0xffFFFFFF),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
