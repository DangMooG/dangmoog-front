import 'package:dangmoog/screens/mypage/profile_change.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';

import 'dart:io';

class NicknameChangePage extends StatefulWidget {
  const NicknameChangePage({Key? key}) : super(key: key);

  @override
  _NicknameChangePageState createState() => _NicknameChangePageState();
}

class _NicknameChangePageState extends State<NicknameChangePage> {
  late String imagePath;

  Color buttonColor = Color(0xFFDADADA); // 초기 버튼 색상

  String nickname = '';
  String errorMessage = '';

  void onNicknameChanged(String value) {
    setState(() {
      nickname = value;
      if (nickname.length >= 2) {
        errorMessage = ''; // 닉네임이 유효한 경우 오류 메시지를 지웁니다.
      } else {
        errorMessage = '최소 2글자 이상 입력해주세요.';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/sample.png';
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
          icon: Icon(Icons.arrow_back), // 뒤로 가기 아이콘
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          _changeNicknameButton(screenSize, context, nickname,
              changeUserNickname, isButtonDisabled),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.19),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: screenSize.width * 0.56,
                height: screenSize.width * 0.56,
                child: ClipOval(
                  child: userImage != null
                      ? Image.file(
                          userImage,
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
              decoration: InputDecoration(
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
            style: TextStyle(
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
}

Widget _changeNicknameButton(Size screenSize, BuildContext context,
    String nickname, String changeUserNickname, bool isButtonDisabled) {
  return TextButton(
    onPressed: () {
      if (nickname.length >= 2) {
        // 닉네임이 유효한 경우에만 업데이트합니다.

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFFFFFFFF),
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
                  SizedBox(height: 8),
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
                        Provider.of<UserProvider>(context, listen: false)
                            .setNickname(nickname);
                        Provider.of<UserProvider>(context, listen: false)
                            .updateBoolValue(false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileChangePage(),
                          ),
                        );
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
                          side: BorderSide(color: Color(0xFF726E6E), width: 1),
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
    child: Text(
      '변경하기',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.red,
      ),
    ),
  );
}
