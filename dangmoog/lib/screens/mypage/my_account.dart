import 'package:dangmoog/constants/account_list.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/submit_button.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'dart:io';

class MyaccountPage extends StatefulWidget {
  const MyaccountPage({Key? key}) : super(key: key);

  @override
  _MyaccountPageState createState() => _MyaccountPageState();
}

class _MyaccountPageState extends State<MyaccountPage> {
  bool isSubmitVerificationCodeActive = false;
  String selectedBank = '';
  String account = '';

  bool _isSelectListVisible = false;
  String _selectedItem = '';

  final bool _first = false;
  String buttonext = '';
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String accountnumber = Provider.of<UserProvider>(context).account;
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 계좌정보'),
      ),
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
                      SizedBox(height: screenSize.height * 0.024),
                      _inputField(screenSize),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.03),
              child: isSubmitVerificationCodeActive
                  ? AuthSubmitButton(
                      onPressed: () {
                        _accountPopup(screenSize, context);
                      },
                      buttonText: '등록하기',
                      isActive: true,
                    )
                  : AuthSubmitButton(
                      onPressed: () {},
                      buttonText: '등록하기',
                      isActive: false,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _inputField(Size screenSize) {
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height * 0.58,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계좌번호',
            style: TextStyle(
              color: Color(0xFF302E2E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          _accountNumber(screenSize),
          _accountSelect()
        ],
      ),
    );
  }

  // 계좌번호 입력 위젯
  Widget _accountNumber(Size screenSize) {
    void onAccountChanged(String value) {
      setState(() {
        account = value;
        Provider.of<UserProvider>(context, listen: false).setAccount(account);
      });
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: screenSize.width * 0.91,
          height: screenSize.height * 0.06,
          child: TextField(
            onChanged: onAccountChanged,
            onTap: () {
              setState(() {
                isClicked = true;
              });
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isClicked
                      ? Color(0xFF302E2E)
                      : Color(0xFFA19E9E), // 클릭 시 테두리 색상
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFA19E9E), // 클릭 전 테두리 색상
                  width: 1.0,
                ),
              ),
              hintText: '계좌번호 입력(-제외)',
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

  // 계좌 선택 위젯
  Widget _accountSelect() {
    void _toggleListVisibility() {
      FocusScope.of(context).unfocus();
      setState(() {
        _isSelectListVisible = !_isSelectListVisible;
        isClicked = true;
      });
    }

    void _selectItem(String item) {
      setState(() {
        _selectedItem = item;
        _isSelectListVisible = false;
        isSubmitVerificationCodeActive = true;
      });
    }

    void _buttonName(String buttontext) {
      setState(() {
        if (_first == true) {
          buttontext = '수정하기';
        } else {
          buttontext = '등록하기';
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("은행 선택"),
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
                    color: isClicked ? Color(0xFFA19E9E) : Color(0xFFD3D2D2),
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
                            '은행 선택',
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
              constraints: const BoxConstraints(maxHeight: 3 * 41.0),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: accountItems.map((category) {
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
        ],
      ),
    );
  }

  Widget _titleEachSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF302E2E),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

//계좌 등록 안내 팝업
  Future<void> _accountPopup(Size screenSize, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          title: const Column(
            children: [
              Text(
                '계좌정보를 다시 한번 확인해주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF302E2E),
                ),
              ),
              Text(
                '해당정보는 구매자와 거래 시 활용됩니다.\n 다시 한 번 정확히 확인해주시기 바랍니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF302E2E),
                ),
              ),
            ],
          ),
          content: Text(
            '$account $_selectedItem',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF302E2E),
                decoration: TextDecoration.underline),
          ),
          actions: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showCustomPopup(context, screenSize);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE20529),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size(
                      screenSize.width * 0.67,
                      screenSize.height * 0.044,
                    ),
                  ),
                  child: const Text(
                    '등록하기',
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                SizedBox(height: screenSize.height * 0.02),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Color(0xFF726E6E),
                      size: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '운영자는 회원이 저장, 게시 또는 전송한 자료와\n관련하여 일체의 책임을 지지 않습니다.',
                        style: TextStyle(
                            color: Color(0xFF726E6E),
                            fontSize: 11,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        );
      },
    );
  }

  void showCustomPopup(BuildContext context, Size screenSize) {
    String text = '';
    if (text.isEmpty) {
      text = '등록이 완료되었습니다!';
    } else {
      text = '수정이 완료되었습니다!';
    }
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: screenSize.height * 0.86,
        left: screenSize.width * 0.26,
        child: Container(
          width: screenSize.width * 0.47,
          height: screenSize.height * 0.064,
          decoration: BoxDecoration(
            color: Color(0xFF302E2E).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }
}
