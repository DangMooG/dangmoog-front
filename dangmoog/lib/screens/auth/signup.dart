import 'dart:async';
import 'package:dangmoog/screens/auth/nickname.dart';
import 'package:dangmoog/screens/auth/welcome.dart';
import 'package:dangmoog/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:flutter/services.dart';
import 'package:dangmoog/widgets/back_appbar.dart';
import 'package:dangmoog/widgets/text_with_buttion.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isToggled = false;
  // String email = '';
  String number = '';
  String verificationCode = '';
  bool isVerificationCodeVisible = false; // New state variable
  String errorMessage = '';
  // bool _isButton1Pressed = false;
  // bool _isButton2Pressed = false;
  // bool isButtonDisabled = false;
  // bool _isEditingEnabled = true;
  bool isContainerVisible = false;
  bool isEmail = false; // New state variable to track email validity

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

  void resetTimer() {
    setState(() {
      secondsRemaining = 4 * 60;
      timer?.cancel();
    });
  }

  final TextEditingController emailController = TextEditingController();

  // void _login(BuildContext context) {
  //   String enteredEmail = emailController.text;
  //   Provider.of<UserProvider>(context, listen: false).setEmail(enteredEmail);
  //   // 로그인 처리 로직 추가
  // }

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
            height: screenSize.height * 0.58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CustomTextFieldButton(
                      hintText: '이메일을 입력하세요',
                      error: '이메일 양식이 올바르지 않습니다. 다시 입력해주세요',
                      onPressed: (email) {
                        showVerificationCodeTextField();
                        startTimer();
                        Provider.of<UserProvider>(context, listen: false)
                            .setEmail(emailController.text);
                        // 이메일이 유효한지 확인하고 상태 업데이트
                      },
                      resetTimer: () {
                        resetTimer(); // CustomTextFieldButton을 누를 때 타이머 리셋
                      },
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
                                    onChanged:
                                        onVerificationCodeChanged, // 인증번호 입력 변경 리스너 추가
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
                      textcolor: Colors.white,
                      color: verificationCode.length == 6
                          ? const Color(
                              0xFFE20529) // 인증번호 6자리 입력 및 이메일 유효성 검사 완료 시 빨간색으로 변경
                          : const Color(0xFFDADADA),
                      onPressed: () {
                        if (verificationCode.length == 6) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NicknamePage()),
                            (route) => false,
                          );
                        } else {
                          errorMessage = '인증번호를 잘못 입력하셨습니다. 다시 입력해주세요.';
                        }
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
