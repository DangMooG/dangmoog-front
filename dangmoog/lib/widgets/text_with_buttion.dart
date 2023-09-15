import 'package:flutter/material.dart';
import 'dart:async';

class CustomTextFieldButton extends StatefulWidget {
  final String hintText;
  final String error;
  final Function(String) onPressed;
  final Function resetTimer;

  const CustomTextFieldButton({
    Key? key,
    required this.hintText,
    required this.error,
    required this.onPressed,
    required this.resetTimer,
  }) : super(key: key);

  @override
  _CustomTextFieldButtonState createState() => _CustomTextFieldButtonState();
}

class _CustomTextFieldButtonState extends State<CustomTextFieldButton> {
  final TextEditingController emailController = TextEditingController();
  String email = '';
  String errorMessage = '';
  bool _isEditingEnabled = true;
  bool _isButton1Pressed = false;
  bool _isButton2Pressed = false;
  bool isVerificationCodeVisible = false;
  late Color buttonColor = const Color(0xFFD3D2D2);
  late Color textColor = const Color(0xFFFFFFFF);
  late Color borderColor = const Color(0xFFD3D2D2);
  int secondsRemaining = 4 * 60;
  Timer? timer;

  void onEmailChanged(String value) {
    setState(() {
      email = value;
      errorMessage = '';
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    bool isValidEmailFormat = isEmailValid(email);
    setState(() {
      _isButton1Pressed = isValidEmailFormat; // 이메일 형식이 유효하면 true
      if (_isButton2Pressed) {
        // 버튼을 눌렀을 때
        buttonColor = _isButton1Pressed
            ? const Color(0xFFFFFFFF) // 이메일 형식이 유효한 경우 버튼 색상 변경
            : const Color(0xFFD3D2D2); // 그렇지 않은 경우 버튼 색상 유지
        textColor = _isButton1Pressed
            ? const Color(0xFFE20529) // 이메일 형식이 유효한 경우 텍스트 색상 변경
            : const Color(0xFFFFFFFF); // 그렇지 않은 경우 텍스트 색상 유지
        borderColor = _isButton1Pressed
            ? const Color(0xFFE20529) // 이메일 형식이 유효한 경우 텍스트 색상 변경
            : const Color(0xFFFFFFFF); // 그렇지 않은 경우 텍스트 색상 유지
      } else {
        buttonColor = _isButton1Pressed
            ? const Color(0xFFE20529) // 이메일 형식이 유효한 경우 버튼 색상 변경
            : const Color(0xFFD3D2D2); // 그렇지 않은 경우 버튼 색상 유지
      }
    });
  }

  bool isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@gm\.gist\.ac\.kr$');
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.91,
      height: screenSize.height * 0.08,
      decoration: const BoxDecoration(
          // border: Border(
          //   bottom: BorderSide(
          //     color: Colors.brown,
          //     width: 1.0,
          //   ),
          // ),
          ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: screenSize.width * 0.02),
              Expanded(
                child: Container(
                  height: screenSize.height * 0.06,
                  child: TextField(
                    controller: emailController,
                    onChanged: onEmailChanged,
                    readOnly: !_isEditingEnabled,
                    maxLength: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Pretendard-Regular',
                        color: Color(0xFFA19E9E),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isEmailValid(email)) {
                    setState(() {
                      _isEditingEnabled = false;
                      _isButton2Pressed = true;
                      _updateButtonState();
                      widget.onPressed(email);
                      widget.resetTimer();
                    });
                    widget.onPressed(emailController.text); // 버튼 색 업데이트
                  } else {
                    setState(() {
                      errorMessage = widget.error;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: borderColor,
                      width: 1.0, // 원하는 두께로 변경
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size(
                    screenSize.width * 0.25,
                    screenSize.height * 0.034,
                  ),
                ),
                child: Container(
                  child: const Text(
                    '인증메일 발송',
                    style: TextStyle(
                      //color: textColor,
                      fontFamily: 'Pretendard-Medium',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: screenSize.width * 0.91,
            height: 1,
            color: Colors.brown, // 갈색 배경색
            alignment: Alignment.center,
          ),
          SizedBox(height: screenSize.height * 0.01),
          if (errorMessage.isNotEmpty) // Show error message if not empty
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, screenSize.width * 0.3, 0),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Color(0xFFE20529),
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
