import 'package:dangmoog/screens/mypage/profile_change.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';

import 'dart:io';

class NicknameChangePage extends StatefulWidget {
  const NicknameChangePage({Key? key}) : super(key: key);

  @override
  State<NicknameChangePage> createState() => _NicknameChangePageState();
}

class _NicknameChangePageState extends State<NicknameChangePage> {
  late String imagePath;

  Color buttonColor = const Color(0xFFDADADA); // 초기 버튼 색상

  String nickname = '';
  String errorMessage = '';

  bool isRedText = true;

  bool _isChecked = false;
  bool _isRightFormat = false;

  bool isHelpVisible = false;

  String? profileUrl;

  void setErrorMessage(String message, bool isRed) {
    setState(() {
      errorMessage = message;
      isRedText = isRed;
    });
  }

  void onNicknameChanged(String value) {
    RegExp wrongRegex = RegExp(r'[^a-zA-Z0-9가-힣]');

    setState(() {
      nickname = value;
    });

    // 이미 중복확인하고 별명 수정하면 중복확인 다시 하도록 설정
    if (_isChecked == true) {
      _isChecked = false;
    }

    if (value.length < 2) {
      setErrorMessage('2글자 이상 입력해주세요', true);
    } else if (wrongRegex.hasMatch(value)) {
      setErrorMessage('숫자, 한글, 또는 영문 조합으로 입력해주세요.', true);
    } else if (checkNicknameFormat(value)) {
      setErrorMessage("", false);
      _isRightFormat = true;
    }
  }

  bool checkNicknameFormat(String value) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9가-힣]{2,15}$');
    return regex.hasMatch(value);
  }

  void isNicknameDuplicate() async {
    try {
      Response response = await ApiService().checkDuplicateNickname(nickname);
      if (response.statusCode == 200) {
        setErrorMessage('사용 가능한 별명입니다.', false);

        setState(() {
          _isChecked = true;
        });
      } else if (response.statusCode == 409) {
        setErrorMessage('이미 존재하는 별명입니다.', true);
        setState(() {
          _isChecked = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //API에서 사진 가져오기
  Future<String> fetchProfileImageUrl() async {
    try {
      final Response response = await ApiService().autoLogin(); // API 호출

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String profileUrl = data["profile_url"]; // "profile_url" 값을 가져옴
        return profileUrl;
      } else {
        // API 응답에 문제가 있는 경우 오류 처리
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 URL 가져오기 오류: $e');
      rethrow;
    }
  }

  void nickNameSubmit() async {
    try {
      Response response = await ApiService().setUserNickname(nickname);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setNickname(nickname);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const ProfileChangePage(),
            transitionDuration: const Duration(seconds: 0), // No animation
            reverseTransitionDuration:
                const Duration(seconds: 2), // No animation when pop
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/sample.png';
    fetchProfileImageUrl().then((url) {
      setState(() {
        profileUrl = url;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String changeUserNickname = Provider.of<UserProvider>(context).nickname;
    File? userImage = Provider.of<UserProvider>(context).userImage;
    final user = Provider.of<UserProvider>(context);
    bool isButtonDisabled = user.isButtonDisabled;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 뒤로 가기 아이콘
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        actions: [
          _changeNicknameButton(screenSize, context, nickname,
              changeUserNickname, isButtonDisabled, _isChecked),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.19),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: screenSize.width * 0.56,
                height: screenSize.width * 0.56,
                child: ClipOval(
                  child: profileUrl != null
                      ? Image.network(
                          profileUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Container(
            alignment: Alignment.center,
            width: screenSize.width * 0.91,
            height: screenSize.height * 0.05,
            child: TextField(
              onChanged: onNicknameChanged,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFA19E9E), // 원하는 border 색상 설정
                    width: 2.0, // 원하는 border 너비 설정
                  ),
                ),
                hintText: '변경할 닉네임 이름을 입력해주세요.',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFA19E9E),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
            ),
          ),
          Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          Container(
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  Widget _changeNicknameButton(
    Size screenSize,
    BuildContext context,
    String nickname,
    String changeUserNickname,
    bool isButtonDisabled,
    bool isChecked,
  ) {
    return TextButton(
      onPressed: () {
        if (nickname.length >= 2) {
          // 닉네임이 유효한 경우에만 업데이트합니다.

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                title: Column(
                  children: [
                    const Text(
                      '바꿀 닉네임을 다시 한번 확인해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302E2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nickname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302E2E),
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  '닉네임 변경은 단 1번만 가능하며,\n 그 이후에는 닉네임을 바꿀 수 없습니다.\n 그래도 변경하시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF302E2E),
                  ),
                ),
                actions: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          nickNameSubmit();

                          Provider.of<UserProvider>(context, listen: false)
                              .updateBoolValue(false);

                          Navigator.of(context).pop();
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
                          '닉네임 변경하기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 팝업 창을 닫을 때 수행할 작업을 여기에 추가하세요.
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
                          '취소하기',
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
        } else {}
      },
      child: const Text(
        '변경하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}
