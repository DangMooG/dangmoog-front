import 'package:dangmoog/constants/delete_reason.dart';
import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/mypage/bye_page.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class accountDeletePage extends StatefulWidget {
  const accountDeletePage({Key? key}) : super(key: key);

  @override
  _accountDeletePageState createState() => _accountDeletePageState();
}

class _accountDeletePageState extends State<accountDeletePage> {
  final storage = const FlutterSecureStorage();

  bool isSubmitVerificationCodeActive = false;
  String selectedBank = '';
  String account = '';

  bool _isSelectListVisible = false;
  String _selectedItem = '';

  String buttonext = '';
  bool isClicked = false;
  bool isShow = true;

  String text = '';

  VoidCallback onPressed = () {};

  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: appBarTitle("탈퇴하기"),
          bottom: appBarBottomLine(),
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.024),
                      const Text(
                        '계정을 탈퇴하시나요?',
                        style: TextStyle(
                          color: Color(0xFF302E2E),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.039),
                      Container(
                        width: screenSize.width * 0.91,
                        // height: screenSize.height * 0.123,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: const Color(0xFFF1F1F1), // 회색 배경색
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '탈퇴 전 꼭 확인해주세요.',
                                  style: TextStyle(
                                    color: Color(0xFF302E2E),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '계정을 삭제하면 게시글, 관심목록, 채팅 등의 모든 활동정보가 삭제되며, 계정 삭제 후 7일 간 다시 가입할 수 없습니다.',
                                  style: TextStyle(
                                    color: Color(0xFF302E2E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFFEC5870),
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          const Text(
                            '위의 안내사항을 모두 확인하였으며 이에 동의합니다.',
                            style: TextStyle(
                              color: Color(0xFF302E2E),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      _accountSelect(screenSize),
                      if (isShow) _inputField(screenSize),
                    ],
                  ),
                ),
              ],
            )));
  }

  SizedBox _inputField(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '떠나는 발걸음이 너무 아쉽지만 말씀해주신 의견을 반영하여 더 좋은 서비스를 만들어갈 수 있도록 노력하겠습니다. \n'
              '\n그동안 저희 서비스를 이용해주셔서 감사합니다.',
              style: TextStyle(
                color: Color(0xFF302E2E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xffffffff)),
                    surfaceTintColor:
                        MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Color(0xff726E6E), width: 1)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: Container(
                    width: screenSize.width * 0.28,
                    height: 46,
                    alignment: Alignment.center,
                    child: const Text(
                      '취소하기',
                      style: TextStyle(
                        color: Color(0xff726E6E),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DeleteButton(
                    screenSize,
                    text = '탈퇴하기',
                    onPressed = () async {
                      if (isChecked && _selectedItem.isNotEmpty) {
                        try {
                          Response response =
                              await ApiService().deleteAccount();
                          if (response.statusCode == 204) {
                            await storage.delete(key: 'accessToken');
                            await storage.delete(key: 'userId');
                            await storage.delete(key: 'encrypted_bank');
                            await storage.delete(key: 'encrypted_account');
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ByePage()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          print(e);
                        }
                      }
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 탈퇴 이유 선택
  Widget _accountSelect(Size screenSize) {
    void _toggleListVisibility() {
      FocusScope.of(context).unfocus();
      setState(() {
        _isSelectListVisible = !_isSelectListVisible;
        isClicked = true;
        isShow = !isShow;
      });
    }

    void _selectItem(String item) {
      setState(() {
        _selectedItem = item;
        _isSelectListVisible = false;
        isSubmitVerificationCodeActive = true;
        isShow = true;
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계정 탈퇴 이유를 알고 싶어요!',
            style: TextStyle(
              color: Color(0xFF302E2E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _toggleListVisibility();
              });
            },
            child: Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isClicked
                        ? const Color(0xFF302E2E)
                        : const Color(0xFFA19E9E),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (_selectedItem == "")
                        ? const Text(
                            '선택',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color(0xffA19E9E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Text(
                            _selectedItem,
                            style: const TextStyle(
                              color: Color(0xff302E2E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                    Icon(
                      _isSelectListVisible
                          ? Icons.keyboard_arrow_down_sharp
                          : Icons.keyboard_arrow_right_sharp,
                      color: _isSelectListVisible
                          ? const Color(0xff726E6E)
                          : const Color(0xffA19E9E),
                    )
                  ],
                )),
          ),
          if (_isSelectListVisible)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffD3D2D2)),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              constraints: const BoxConstraints(maxHeight: 6 * 41.0),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: deleteReason.map((category) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    hoverColor: const Color(0xffF1F1F1),
                    title: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xff302E2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () => _selectItem(category),
                  );
                }).toList(),
              ),
            ),
          if (isShow && isSubmitVerificationCodeActive)
            _accountNumber(screenSize),
        ],
      ),
    );
  }

  // 계좌번호 입력 위젯
  Widget _accountNumber(Size screenSize) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: screenSize.width * 0.91,
          height: screenSize.height * 0.06,
          child: TextField(
            onTap: () {},
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFA19E9E), // 클릭 시 테두리 색상
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF302E2E) // 원하는 색상으로 변경
                    ),
              ),
              hintText: '(선택사항) 더 자세한 의견을 공유해주세요',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA19E9E),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget DeleteButton(Size screenSize, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (!isSubmitVerificationCodeActive || !isChecked) {
              return const Color(0xff726E6E); // 비활성 상태 색상
            }
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFFEC5870);
            }
            return const Color(0xFFE20529);
          },
        ),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Container(
        width: 121,
        height: 47,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xffFFFFFF),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
