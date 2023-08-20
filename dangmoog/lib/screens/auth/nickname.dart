import 'package:flutter/material.dart';
import 'package:dangmoog/screens/home.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({super.key});

  @override
  _NicknamePageState createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  bool isToggled = false;
  String nickname = '';
  String verificationCode = '';
  bool isVerificationCodeVisible = false; // New state variable
  String errorMessage = '';

  void toggleButton() {
    setState(() {
      isToggled = !isToggled;
      if (!isToggled) {
        verificationCode = '';
        isVerificationCodeVisible = false; // Reset visibility when toggled off
        errorMessage = '';
      }
    });
  }

  void showVerificationCodeTextField() {
    setState(() {
      isVerificationCodeVisible = true;
    });
  }

  void onNicknameChanged(String value) {
    setState(() {
      nickname = value;
      errorMessage = ''; // Clear error message when email is changed
    });
  }

  void onVerificationCodeChanged(String value) {
    setState(() {
      verificationCode = value;
    });
  }

  bool isNicknameValid(String email) {
    // Email validation using a regular expression
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]');
    return emailRegExp.hasMatch(nickname);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.13),
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.04, 0, screenSize.width * 0.05, 0),
            child: const Text(
              '환영합니다!\n앱에서 사용하실 별명을 알려주세요!',
              style: TextStyle(
                color: Color(0xFF552619),
                fontFamily: 'Pretendard-SemiBold',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.04, 0, screenSize.width * 0.28, 0),
            child: const Text(
              '도토릿 앱 내에서는 별명을 이용하실 수 있으며 \n최초 1회 변경가능하오니 이점 참고바랍니다! ',
              style: TextStyle(
                color: Color(0xFF552619),
                fontFamily: 'Pretendard-Regular',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            width: screenSize.width,
            height: screenSize.height * 0.58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: screenSize.width * 0.91,
                      height: screenSize.height * 0.044,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
                            child: Container(
                              width: screenSize.width * 0.56,
                              height: screenSize.height * 0.03,
                              alignment: Alignment.center,
                              child: TextField(
                                onChanged: onNicknameChanged,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '별명을 입력해주세요!',
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Pretendard-Regular',
                                      color: Color(0xFFCCBEBA)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.14),
                          ElevatedButton(
                            onPressed: () {
                              if (isNicknameValid(nickname)) {
                                showVerificationCodeTextField();
                              } else {
                                setState(() {
                                  errorMessage = '유효한 별명을 입력하세요.';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xFF552619), width: 1.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              minimumSize: Size(screenSize.width * 0.18,
                                  screenSize.height * 0.034),
                            ),
                            child: Container(
                              child: const Text(
                                '중복확인',
                                style: TextStyle(
                                  color: Color(0xFF552619),
                                  fontFamily: 'Pretendard-Medium',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: screenSize.width * 0.91,
                      height: 1,
                      color: Colors.brown, // 갈색 배경색
                      alignment: Alignment.center,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(screenSize.width * 0.48, 0, 0, 0),
                      child: TextButton(
                        onPressed: () {},
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            '별명은 어떻게 설정해야 하나요?',
                            style: TextStyle(
                              color: Color(0xFF552619),
                              fontFamily: 'Pretendard-Regular',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHome()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC30020),
                    side:
                        const BorderSide(color: Color(0xFFC30020), width: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fixedSize: Size(
                        screenSize.width * 0.91, screenSize.height * 0.056),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '도토릿 시작하기!',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard-Medium',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
