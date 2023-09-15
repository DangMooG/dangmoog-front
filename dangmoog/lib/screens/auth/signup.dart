import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dangmoog/screens/auth/submit_button.dart';

import 'package:dangmoog/screens/auth/nickname.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // 이메일, 인증번호
  String inputEmail = '';
  String verificationCode = '';

  // 인증번호 입력 위젯 visible state
  bool isVerificationCodeVisible = false;

  // 에러 메시지
  String errorMessageEmail = '';
  String errorMessageVerificationCode = '';

  // 인증메일 발송 버튼 활성화 state
  bool isSubmitEmailVisible = false;
  // 인증메일 발송 여부
  bool isEmailSend = false;

  // 인증번호 인증 버튼 활성화 state
  bool isSubmitVerificationCodeActive = false;
  // 인증번호 활성화 여부
  bool isExpired = false;

  // 인증번호 오지 않을 경우 안내문
  bool isVerificationCodeMissing = false;

  void onEmailChanged(String value) {
    setState(() {
      inputEmail = value;
      errorMessageEmail = '';
    });
    // 이메일 형식이 올바를 경우 인증메일 발송 버튼 활성화
    if (isEmailFormatValid(inputEmail)) {
      setState(() {
        isSubmitEmailVisible = true;
      });
    } else {
      setState(() {
        isSubmitEmailVisible = false;
      });
    }
  }

  bool isEmailFormatValid(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@(gm\.)?gist\.ac\.kr$',
        caseSensitive: false);
    return emailRegExp.hasMatch(email);
  }

  void showVerificationCodeTextField() {
    setState(() {
      isVerificationCodeVisible = true;
    });
  }

  void submitEmail() {
    if (isEmailFormatValid(inputEmail)) {
      showVerificationCodeTextField();
      startTimer();
      setState(() {
        isEmailSend = true;
      });
    } else {
      setState(() {
        errorMessageEmail = '유효한 이메일을 입력하세요.';
      });
    }
  }

  void onVerificationCodeChanged(String value) {
    setState(() {
      verificationCode = value;
    });
    if (value.length == 6) {
      setState(() {
        isSubmitVerificationCodeActive = true;
      });
    } else {
      setState(() {
        isSubmitVerificationCodeActive = false;
      });
    }
  }

  // 인증번호 입력 제한 시간 타이머
  int secondsRemaining = 5 * 60;
  Timer? timer;
  void startTimer() {
    timer?.cancel();

    secondsRemaining = 5 * 60;

    setState(() {
      isExpired = false;
    });

    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
          setState(() {
            isExpired = true;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String getFormattedTime() {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _signUpMessage(screenSize),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.024),
                      _inputField(screenSize),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: isSubmitVerificationCodeActive
                  ? AuthSubmitButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NicknamePage()),
                          (route) => false,
                        );
                      },
                      buttonText: '인증',
                      isActive: true,
                    )
                  : AuthSubmitButton(
                      onPressed: () {},
                      buttonText: '인증',
                      isActive: false,
                    ),
            ),
            AnimatedContainer(
              duration: const Duration(microseconds: 100),
              curve: Curves.linear,
              child: SizedBox(
                height: keyboardHeight < 50 ? 40 : 15,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signUpMessage(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '안녕하세요!\nGIST 이메일로 간편가입해주세요!',
          style: TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        const Text(
          'GIST 이메일은 본인 확인 용도로 사용되며 다른 학우들에게\n공개되지 않습니다. ',
          style: TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  SizedBox _inputField(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height * 0.58,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _emailInput(screenSize),
          isVerificationCodeVisible
              ? _verificationNumberWidget(screenSize)
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  // 이메일 입력 위젯
  Widget _emailInput(Size screenSize) {
    return Column(
      children: [
        Container(
          height: screenSize.height * 0.05,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xffD3D2D2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  onChanged: onEmailChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'GIST 이메일 입력',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA19E9E),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: submitEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmailSend
                      ? const Color(0xFFFFFFFF)
                      : isSubmitEmailVisible
                          ? const Color(0xffE20529)
                          : const Color(0xffD3D2D2),
                  surfaceTintColor: isEmailSend
                      ? const Color(0xFFFFFFFF)
                      : isSubmitEmailVisible
                          ? const Color(0xffE20529)
                          : const Color(0xffD3D2D2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: isEmailSend
                          ? const BorderSide(color: Color(0xffE20529))
                          : const BorderSide(color: Colors.transparent)
                      //isEmailSend
                      ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 0),
                ),
                child: Text(
                  '인증메일 발송',
                  style: TextStyle(
                    color: isEmailSend
                        ? const Color(0xffE20529)
                        : const Color(0xFFFFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorMessageEmail.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessageEmail,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 인증번호 입력 위젯
  Widget _verificationNumberWidget(Size screenSize) {
    // input field
    Widget verificationNumberInputField(Size screenSize) {
      return Container(
        height: screenSize.height * 0.05,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Color(0xffD3D2D2),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                maxLength: 6,
                onChanged: (value) {
                  onVerificationCodeChanged(value);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: '인증번호 6자리 입력',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA19E9E),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  isDense: true,
                ),
              ),
            ),
            Text(
              getFormattedTime(),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF726E6E)),
            ),
          ],
        ),
      );
    }

    // 인증번호가 오지 않나요?
    Widget verificationNumberQuestion() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  isVerificationCodeMissing = !isVerificationCodeMissing;
                });
              },
              child: const Text(
                '인증번호가 오지 않나요?',
                style: TextStyle(
                  color: Color(0xFF726E6E),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 인증번호가 오지 않을 때 안내사항
    Widget verificationCodeMissing() {
      Widget TextCell(String text) {
        return ListTile(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.circle,
                size:
                    5.0), // 또는 CircleAvatar(backgroundColor: Colors.black, radius: 5.0),
            const SizedBox(width: 5.0),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            )
          ],
        ));
      }

      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: const Color(0xffD3D2D2),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '다음 사항을 꼭 확인해주세요!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff302E2E),
                    ),
                  ),
                  TextCell("이메일 주소에 오타가 없는지 다시 한 번 확인해주세요."),
                  TextCell("이메일 주소에 오타가 없는지 다시 한 번 확인해주세요."),
                ],
              ),
              // child: const Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       '다음 사항을 꼭 확인해주세요!',
              //       style: TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w600,
              //         color: Color(0xff302E2E),
              //       ),
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "∙ 이메일 주소에 오타가 없는지 다시 한 번 확인해주세요.",
              //           style: TextStyle(
              //             fontSize: 11,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xff302E2E),
              //           ),
              //         ),
              //         Text(
              //           "∙ 스팸메일함을 확인해주세요.",
              //           style: TextStyle(
              //             fontSize: 11,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xff302E2E),
              //           ),
              //         ),
              //         Text(
              //           "∙ 수신메일함의 용량이 부족하여 메일을 받지 못할 수 있습니다. 메일함의 용량을 정리해주세요.",
              //           style: TextStyle(
              //             fontSize: 11,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xff302E2E),
              //           ),
              //         ),
              //         Text(
              //           "∙ 위 모든 사항을 확인했음에도 인증번호가 발송되지 않을 경우 관리자 메일(dotorit@gmai.com)로 문의주시면 감사하겠습니다.",
              //           style: TextStyle(
              //             fontSize: 11,
              //             fontWeight: FontWeight.w400,
              //             color: Color(0xff302E2E),
              //           ),
              //         ),
              //       ],
              //     )
              //   ],
              // ),
            )),
          ],
        ),
      );
    }

    return Column(
      children: [
        verificationNumberInputField(screenSize),
        verificationNumberQuestion(),
        isVerificationCodeMissing
            ? verificationCodeMissing()
            : const SizedBox.shrink()
      ],
    );
  }
}
