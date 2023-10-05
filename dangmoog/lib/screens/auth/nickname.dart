import 'package:dangmoog/screens/auth/profile.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/widgets/auth_button.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({Key? key}) : super(key: key);

  @override
  _NicknamePageState createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  String nickname = '';
  String errorMessage = '';

  void onNicknameChanged(String value) {
    setState(() {
      nickname = value;
      if (nickname.length >= 2) {
        errorMessage = ''; // Clear error message when nickname is valid
      } else {
        errorMessage = '최소 2글자 이상 입력해주세요.';
      }
      Provider.of<UserProvider>(context, listen: false).setNickname(nickname);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.14),
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.04, 0, screenSize.width * 0.05, 0),
            child: const Text(
              '환영합니다!\n앱에서 사용하실 별명을 알려주세요!',
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
                screenSize.width * 0.04, 0, screenSize.width * 0.28, 0),
            child: const Text(
              '도토릿 앱 내에서는 별명을 이용하실 수 있으며 \n최초 1회 변경가능하오니 이점 참고바랍니다! ',
              style: TextStyle(
                color: Color(0xFF302E2E),
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
                              if (nickname.length >= 2) {
                                // Continue with the action
                              } else {
                                setState(() {
                                  errorMessage = '최소 2글자 이상 입력해주세요.';
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
                      color: Color(0xFF302E2E), // 갈색 배경색
                      alignment: Alignment.center,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            0, 0, screenSize.width * 0.55, 0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Color(0xFFE20529),
                            fontSize: 11,
                          ),
                        ),
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
                  ],
                ),
                AuthButton(
                  text: '도토릿 시작하기!',
                  textcolor: Colors.white,
                  color: Color(0xFFE20529),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
