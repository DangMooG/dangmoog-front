import 'package:dangmoog/screens/auth/profile.dart';

import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/widgets/bottom_popup.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'package:dangmoog/widgets/submit_button.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/user_provider.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({Key? key}) : super(key: key);

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  String nickname = '';
  String errorMessage = '';
  bool isRedText = true;

  bool _isChecked = false;
  bool _isRightFormat = false;

  bool isHelpVisible = false;

  bool isLoading = false;

  void setErrorMessage(String message, bool isRed) {
    setState(() {
      errorMessage = message;
      isRedText = isRed;
    });
  }

  void onNicknameChanged(String value) {
    RegExp wrongRegex = RegExp(r'[^a-zA-Z0-9가-힣]');
    double weightedLength = calculateWeightedLength(value);

    setState(() {
      nickname = value;
    });

    // 이미 중복확인하고 별명 수정하면 중복확인 다시 하도록 설정
    if (_isChecked == true) {
      _isChecked = false;
    }

    if (weightedLength < 2) {
      setErrorMessage('최소 2글자 이상 입력해주세요', true);
    } else if (wrongRegex.hasMatch(value)) {
      setErrorMessage('숫자, 한글, 또는 영문 조합으로 입력해주세요.', true);
    } else if (checkNicknameFormat(value)) {
      setErrorMessage("", false);
      _isRightFormat = true;
    }
    if (weightedLength > 7) {
      setErrorMessage('별명은 최대 7글자 입력 가능합니다', true);
      _isRightFormat = false;
    }
  }

  bool checkNicknameFormat(String value) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9가-힣]{2,15}$');
    return regex.hasMatch(value);
  }

  double calculateWeightedLength(String value) {
    double weightedLength = 0;
    for (int i = 0; i < value.length; i++) {
      String char = value[i];
      if (RegExp(r'^[a-zA-Z0-9]$').hasMatch(char)) {
        // 영어 알파벳 또는 숫자인 경우
        weightedLength += 0.5;
      } else if (RegExp(r'^[가-힣]$').hasMatch(char)) {
        // 한글인 경우
        weightedLength += 1;
      }
    }
    return weightedLength;
  }

  void isNicknameDuplicate() async {
    try {
      Response response = await ApiService().checkDuplicateNickname(nickname);
      if (response.statusCode == 200) {
        setErrorMessage('멋진 이름이에요! 별명을 사용하실 수 있습니다!', true);

        setState(() {
          _isChecked = true;
        });
      } else if (response.statusCode == 409) {
        setErrorMessage('중복된 별명입니다. 다른 별명을 입력해주세요.', true);
        setState(() {
          _isChecked = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void nickNameSubmit() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      Response response = await ApiService().setUserNickname(nickname);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setNickname(nickname);
        isLoading = false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
          (route) => false,
        );
      }
    } catch (e) {
      showPopup(context, "별명 설정에 실패했습니다.");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Padding(
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
                        children: [
                          _nicknameMessage(screenSize),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _inputField(screenSize)
                    ],
                  ),
                  SizedBox(
                    height: 144,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AuthSubmitButton(
                          onPressed: _isChecked
                              ? () {
                                  nickNameSubmit();
                                }
                              : () {},
                          buttonText: '도토릿 시작하기',
                          isActive: _isChecked ? true : false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _nicknameMessage(Size screenSize) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '환영합니다!\n별명을 알려주세요!',
          style: TextStyle(
            color: Color(0xFF302E2E),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 8,
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
                  maxLength: 15,
                  decoration: const InputDecoration(
                    counterText: "",
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
                  if (checkNicknameFormat(nickname)) {
                    isNicknameDuplicate();
                  }
                  FocusScope.of(context).unfocus();
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (errorMessage.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: TextStyle(
                  color: isRedText ? const Color(0xFFE20529) : Colors.blue,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        const SizedBox.shrink(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isHelpVisible = !isHelpVisible;
                });
              },
              child: const Text(
                '별명은 어떻게 설정해야 하나요?',
                style: TextStyle(
                  color: Color(0xFF726E6E),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget nicknameHelpMsg() {
    Size screenSize = MediaQuery.of(context).size;
    Widget textCell(String text) {
      return Padding(
        padding: EdgeInsets.only(
            left: screenSize.height * 0.009,
            bottom: screenSize.height * 0.0024),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "• ",
              style: TextStyle(
                fontSize: screenSize.height * 0.014,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: screenSize.height * 0.014,
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
      padding: EdgeInsets.only(top: screenSize.height * 0.012),
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
            padding: EdgeInsets.all(screenSize.height * 0.019),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: screenSize.height * 0.009),
                  child: Text(
                    '다음 사항을 꼭 확인해주세요!',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.017,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff302E2E),
                    ),
                  ),
                ),
                textCell("한글, 영문, 숫자 혼용 가능하며, 공백과 특수문자(-, #, @ 등)는 사용 불가합니다."),
                textCell("글자 수는 2자 이상, 15자 이하로 제한됩니다."),
                textCell("부적절한 닉네임은 제한되며, 관리자에 의해 예고없이 사용이 중지될 수 있습니다."),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: screenSize.height * 0.009),
                  child: Text(
                    '부적절한 별명 기준 안내',
                    style: TextStyle(
                      fontSize: screenSize.height * 0.013,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff302E2E),
                    ),
                  ),
                ),
                textCell("미풍양속 및 사회통념에 어긋나는 부절절한 표현"),
                textCell("욕설/음란성/혐오성 단어나 비속어를 사용하여 타인을 직/간접적으로 비방하는 표현"),
                textCell("다른 사용자에게 불쾌감을 줄 수 있는 표현"),
                textCell("도토릿 운영자, 관리자로 착오할 수 있는 표현"),
                textCell("본인 혹인 타인의 개인정보가 노출된 단어나 표현"),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
