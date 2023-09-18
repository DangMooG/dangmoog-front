import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';

import 'package:dangmoog/screens/auth/submit_button.dart';
import 'package:dangmoog/screens/auth/profile.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({Key? key}) : super(key: key);

  @override
  _NicknamePageState createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  String nickname = '';
  String errorMessage = '';

  bool _isChecked = false;
  bool _isRightFormat = false;

  bool isHelpVisible = false;

  void onNicknameChanged(String value) {
    setState(() {
      nickname = value;
      if (nickname.length >= 2) {
        errorMessage = '';
        setState(() {
          _isRightFormat = true;
        });
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
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [_NicknameMessage(screenSize)],
                  ),
                  SizedBox(height: screenSize.height * 0.024),
                  _inputField(screenSize)
                ],
              ),
              SizedBox(
                height: screenSize.height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AuthSubmitButton(
                      onPressed: _isChecked
                          ? () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePage()),
                                (route) => false,
                              );
                            }
                          : () {},
                      buttonText: '인증',
                      isActive: _isChecked ? true : false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _NicknameMessage(Size screenSize) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '환영합니다!\n앱에서 사용하실 별명을 알려주세요!',
          style: TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '도토릿 앱 내에서는 별명을 이용하실 수 있으며 \n최초 1회 변경가능하오니 이점 참고바랍니다! ',
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
        _nicknameInput(screenSize),
        const SizedBox(
          height: 8,
        ),
        errorMsgHelpMsg(),
        isHelpVisible ? nicknameHelpMsg() : const SizedBox.shrink()
      ],
    );
  }

  // 닉네임 입력 위젯
  Widget _nicknameInput(Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  onChanged: (value) {
                    onNicknameChanged(value);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '별명을 입력해주세요!',
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
                onPressed: () {
                  setState(() {
                    _isChecked = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isChecked
                      ? const Color(0xFFFFFFFF)
                      : _isRightFormat
                          ? const Color(0xffE20529)
                          : const Color(0xffD3D2D2),
                  surfaceTintColor: _isChecked
                      ? const Color(0xFFFFFFFF)
                      : _isRightFormat
                          ? const Color(0xffE20529)
                          : const Color(0xffD3D2D2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: _isChecked
                          ? const BorderSide(color: Color(0xffE20529))
                          : const BorderSide(color: Colors.transparent)
                      //isEmailSend
                      ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 0),
                ),
                child: Text(
                  '중복확인',
                  style: TextStyle(
                    color: _isChecked
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
      ],
    );
  }

  // 인증번호가 오지 않나요?
  Widget errorMsgHelpMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (errorMessage.isNotEmpty)
          Text(
            errorMessage,
            style: const TextStyle(
              color: Color(0xFFE20529),
              fontSize: 11,
            ),
          ),
        const SizedBox.shrink(),
        InkWell(
          onTap: () {
            setState(() {
              isHelpVisible = !isHelpVisible;
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
      ],
    );
  }

  // 인증번호가 오지 않을 때 안내사항
  Widget nicknameHelpMsg() {
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
                  '가ㅣ나다라마바사',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff302E2E),
                  ),
                ),
                TextCell("도도도도도ㅗㄷㄱ"),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
