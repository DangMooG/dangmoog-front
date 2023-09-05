import 'dart:async';
import 'package:dangmoog/screens/auth/nickname.dart';
import 'package:dangmoog/screens/auth/welcome.dart';
import 'package:dangmoog/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:flutter/services.dart';
import 'package:dangmoog/widgets/back_appbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isToggled = false;
  String email = '';
  String number = '';
  String verificationCode = '';
  bool isVerificationCodeVisible = false; // New state variable
  String errorMessage = '';
  bool _isButton1Pressed = false;
  bool _isButton2Pressed = false;
  bool isButtonDisabled = false;
  bool _isEditingEnabled = true;
  bool isContainerVisible = false;
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

  void onEmailChanged(String value) {
    setState(() {
      email = value;
      errorMessage = ''; // Clear error message when email is changed
      _updateButtonState();
    });
  }

  void _updateButtonState() {
    bool isValidEmailFormat = isEmailValid(email);
    if (isValidEmailFormat) {
      setState(() {
        _isButton1Pressed = true; // 이메일 형식 맞으면 버튼 색 업데이트
      });
    }
  }

  void onVerificationCodeChanged(String value) {
    setState(() {
      verificationCode = value;
    });
  }

  bool isEmailValid(String email) {
    // Email validation using a regular expression
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@gm\.gist\.ac\.kr$');
    return emailRegExp.hasMatch(email);
  }

  void toggleContainerVisibility() {
    setState(() {
      isContainerVisible = !isContainerVisible; // 상태를 토글
    });
  }

  int secondsRemaining = 4 * 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String getFormattedTime() {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  final TextEditingController emailController = TextEditingController();

  void _login(BuildContext context) {
    String enteredEmail = emailController.text;
    Provider.of<UserProvider>(context, listen: false).setEmail(enteredEmail);
    // 로그인 처리 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: BackAppBar(
        MyTargetScreen: WelcomePage(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.04, 0, screenSize.width * 0.1, 0),
            child: const Text(
              '안녕하세요!\nGIST 이메일로 간편가입해주세요!',
              style: TextStyle(
                color: Color(0xFF302E2E),
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
                screenSize.width * 0.04, 0, screenSize.width * 0.1, 0),
            child: const Text(
              'GIST 이메일은 본인 확인 용도로 사용되며 다른 학우들에게\n공개되지 않습니다. ',
              style: TextStyle(
                color: Color(0xFF302E2E),
                fontFamily: 'Pretendard-Regular',
                fontSize: 14,
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
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: screenSize.width * 0.02),
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              onChanged: onEmailChanged,
                              readOnly: !_isEditingEnabled,
                              maxLength: null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'GIST 이메일 입력',
                                hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Pretendard-Regular',
                                    color: Color(0xFFA19E9E)),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _isEditingEnabled
                                ? () {
                                    if (isEmailValid(email)) {
                                      setState(() {
                                        _isEditingEnabled = false; // 입력 비활성화
                                        _isButton2Pressed = true; // 버튼 비활성화
                                      });
                                      showVerificationCodeTextField();
                                      startTimer();

                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .setEmail(emailController.text);
                                      //_updateButtonState();
                                    } else {
                                      setState(() {
                                        errorMessage =
                                            '이메일 양식이 올바르지 않습니다. 다시 입력해주세요.';
                                      });
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButton1Pressed
                                  ? const Color(0xFFE20529)
                                  : const Color(0xFFD3D2D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              minimumSize: Size(screenSize.width * 0.25,
                                  screenSize.height * 0.034),
                            ),
                            child: Container(
                              child: const Text(
                                '인증메일 발송',
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
                    Container(
                      width: screenSize.width * 0.91,
                      height: 1,
                      color: Color(0xFF726E6E),
                      alignment: Alignment.center,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    if (errorMessage
                        .isNotEmpty) // Show error message if not empty
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, 0, screenSize.width * 0.3, 0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Color(0xFFE20529),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (isVerificationCodeVisible) // 메일발송 후
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: screenSize.width * 0.06),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0, screenSize.height * 0.02, 0, 0),
                                child: Container(
                                  width: screenSize.width * 0.56,
                                  height: screenSize.height * 0.03,
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '인증번호 6자리 입력',
                                      hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Pretendard-Regular',
                                          color: Color(0xFFCCBEBA)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.25),
                              Text(
                                getFormattedTime(),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Pretendard-Regular',
                                    color: Color(0xFF726E6E)),
                              ),
                            ],
                          ),
                          Container(
                            width: screenSize.width * 0.91,
                            height: 1,
                            color: Colors.brown, // 갈색 배경색
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                screenSize.width * 0.55, 0, 0, 0),
                            child: TextButton(
                              onPressed: () {
                                toggleContainerVisibility();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  '인증번호가 오지 않나요?',
                                  style: TextStyle(
                                    color: Color(0xFF726E6E),
                                    fontFamily: 'Pretendard-Regular',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          isContainerVisible
                              ? Container(
                                  width: screenSize.width * 0.91,
                                  //height: screenSize.height * 0.15,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFD3D2D2),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '다음 사항을 꼭 확인해주세요!',
                                          style: TextStyle(
                                            color: Color(0xFF302E2E),
                                            fontFamily: 'Pretendard-SemiBold',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '∙ 이메일 주소에 오타가 없는지 다시 한번 확인해주세요.\n'
                                          '∙ 스팸메일함을 체크해주세요.\n'
                                          '∙ 수신메일함의 용량이 부족하여 메일을 받지 못할 수 있습니다.\n'
                                          '  받은메일함의 용량을 정리해주세요.\n'
                                          '∙ 위 모든 사항을 확인했음에도 인증번호가 발송되지 않을 경우\n'
                                          '  관리자 메일(dotorit@gmail.com)로 문의주시면 감사하겠습니다.',
                                          style: TextStyle(
                                            color: Color(0xFF302E2E),
                                            fontFamily: 'Pretendard-Regular',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    else
                      Container(),
                  ],
                ),
                Column(
                  children: [
                    AuthButton(
                      text: '인증',
                      color: _isButton2Pressed
                          ? const Color(0xFFE20529)
                          : const Color(0xFFDADADA),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NicknamePage()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
