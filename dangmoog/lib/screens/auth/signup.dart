import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:dio/dio.dart';

import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dangmoog/screens/auth/nickname.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/widgets/back_appbar.dart';
import 'package:dangmoog/widgets/submit_button.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;

  const AuthPage({super.key, required this.isLogin});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // 로그인인지 회원가입인지 구분
  late bool isLogin;

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
  bool isbuttonClicked = false;
  // 인증번호 오지 않을 경우 안내문
  bool isVerificationCodeMissing = false;

  bool isLoading = false;

  bool isSending = false;

  // 토큰과 user ID 저장
  static const storage = FlutterSecureStorage();

  void onEmailChanged(String value) {
    setState(() {
      inputEmail = value;
      errorMessageEmail = '';
      Provider.of<UserProvider>(context, listen: false).setEmail(inputEmail);
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

  void submitEmail(BuildContext context) async {
    Size screenSize = MediaQuery.of(context).size;
    if (isEmailFormatValid(inputEmail)) {
      showVerificationCodeTextField();
      startTimer();
      setState(() {
        isEmailSend = true;
        isSending = true;
      });

      try {
        Response response = await ApiService().emailSend(inputEmail);
        if (response.statusCode == 200) {
          // 이미 존재하는 계정 : true
          // 존재하지 않는 계정 : false
          int status = int.parse(response.data[0]['status'].toString());
          bool isExistingAccount = status == 1 ? true : false;

          // 유저가 선택한 플로우와 이메일의 계정 존재 여부가 일치하지 않을 경우
          // // 로그인 and 존재하지 않는 계정
          // // 회원가입 and 이미 존재하는 계정
          isSending = false;
          if (isLogin != isExistingAccount) {
            setState(() {});
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  // titlePadding: const EdgeInsets.only(top: 24),
                  // contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                  title: isExistingAccount
                      ? const Text(
                          "어라? 이미 가입된 계정이에요!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF302E2E),
                          ),
                        )
                      : const Text(
                          "존재하지 않는 이메일입니다",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF302E2E),
                          ),
                        ),
                  content: isExistingAccount
                      ? const Text(
                          "로그인을 진행할까요?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF302E2E),
                          ),
                        )
                      : const Text(
                          "회원가입을 진행할까요?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF302E2E),
                          ),
                        ),
                  actions: <Widget>[
                    Column(
                      children: [
                        isExistingAccount
                            ? ElevatedButton(
                                onPressed: () {
                                  isLogin = isExistingAccount;
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE20529),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  minimumSize: Size(
                                    screenSize.width * 0.67,
                                    screenSize.height * 0.044,
                                  ),
                                ),
                                child: const Text(
                                  "로그인하기",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  isLogin = isExistingAccount;
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE20529),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  minimumSize: Size(
                                    screenSize.width * 0.67,
                                    screenSize.height * 0.044,
                                  ),
                                ),
                                child: const Text(
                                  "회원가입하기",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                  color: Color(0xFF726E6E), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            minimumSize: Size(
                              screenSize.width * 0.67,
                              screenSize.height * 0.044,
                            ),
                          ),
                          child: const Text(
                            '다시 입력하기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF726E6E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
        }
      } catch (e) {
        print("Exception: $e");
      }
    } else {
      setState(() {
        errorMessageEmail = '유효한 이메일을 입력하세요.';
      });
    }
  }

  void onVerificationCodeChanged(String value) {
    setState(() {
      verificationCode = value;
      errorMessageVerificationCode = '';
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

  void _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response =
          await ApiService().verifyCode(inputEmail, verificationCode);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        String accessToken = response.data['access_token'];
        int userId = response.data['account_id'];

        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'userId', value: userId.toString());

        // 인증에 성공한 이메일을 전역 상태로 저장
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setEmail(inputEmail);

        // 내가 올린 게시글들의 ID 목록 전역 상태로 저장
        Provider.of<UserProvider>(context, listen: false).getMyPostListId();

        if (isLogin) {
          bool hasNickname =
              int.parse(response.data["is_username"].toString()) == 1
                  ? true
                  : false;
          if (!hasNickname) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const NicknamePage()),
              (route) => false,
            );
          } else {
            try {
              final response = await ApiService().autoLogin();
              if (response.statusCode == 200) {
                final userNickname = response.data['username'];
                Provider.of<UserProvider>(context, listen: false)
                    .setNickname(userNickname);
              }
            } catch (e) {
              print(e);
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHome()),
              (route) => false,
            );
          }
        } else {
          // 별명 설정 페이지로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NicknamePage()),
            (route) => false,
          );
        }
      } else {
        errorMessageVerificationCode = '인증번호를 잘못 입력하셨습니다. 다시 입력해주세요.';
      }
    } catch (e) {
      print("Exception: $e");
      errorMessageVerificationCode = '인증번호를 잘못 입력하셨습니다. 다시 입력해주세요.';
      print(errorMessageVerificationCode);
    }
    setState(() {
      isLoading = false;
    });
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

    isLogin = widget.isLogin;
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

    return Scaffold(
      appBar: const BackAppBar(),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _signUpMessage(screenSize, isLogin),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _inputField(screenSize),
                    ],
                  ),
                  const Expanded(
                      child: SizedBox(
                    width: double.infinity,
                    child: Text(""),
                  )),
                  SizedBox(
                    height: screenSize.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AuthSubmitButton(
                          onPressed: isSubmitVerificationCodeActive
                              ? () {
                                  _login(context);
                                }
                              : () {},
                          buttonText: '인증',
                          isActive:
                              isSubmitVerificationCodeActive ? true : false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isLoading || isSending
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink(), // 로딩 상태가 아닐 때는 아무것도 표시하지 않음
          ],
        ),
      ),
    );
  }

  Widget _signUpMessage(Size screenSize, bool isLogin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin
              ? '안녕하세요!\nGIST 이메일로 로그인해주세요!'
              : '안녕하세요!\nGIST 이메일로 간편가입해주세요!',
          style: const TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        const Text(
          'GIST 이메일은 GIST 학생 인증 용도로 사용되며 \n다른 사용자에게 공개되지 않습니다. ',
          style: TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _inputField(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _emailInput(screenSize),
        isVerificationCodeVisible
            ? _verificationNumberWidget(screenSize)
            : const SizedBox.shrink()
      ],
    );
  }

  // 이메일 입력 위젯
  Widget _emailInput(Size screenSize) {
    return Column(
      children: [
        Container(
          // height: screenSize.height * 0.05,
          height: 40,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF302E2E),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  submitEmail(context);
                  FocusScope.of(context).unfocus();
                },
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
                    fontSize: 12,
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
          ),
          if (errorMessageVerificationCode.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessageVerificationCode,
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
      Widget textCell(String text) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "• ",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff302E2E),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff302E2E),
                  ),
                ),
              )
            ],
          ),
        );
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '다음 사항을 꼭 확인해주세요!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff302E2E),
                      ),
                    ),
                  ),
                  textCell("이메일 주소에 오타가 없는지 다시 한 번 확인해주세요."),
                  textCell("스팸메일함을 체크해주세요."),
                  textCell(
                      "수신메일함의 용량이 부족하여 메일을 받지 못할 수 있습니다. 받은 메일함의 용량을 정리해주세요."),
                  textCell(
                      "위 모든 사항을 확인했음에도 인증번호가 발송되지 않을 경우 관리자 메일(dotorit@gmail.com)로 문의주시면 감사하겠습니다."),
                ],
              ),
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
