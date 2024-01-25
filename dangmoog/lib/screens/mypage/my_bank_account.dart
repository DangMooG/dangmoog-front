import 'package:dangmoog/constants/account_list.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyBankAccountPage extends StatefulWidget {
  const MyBankAccountPage({Key? key}) : super(key: key);

  @override
  State<MyBankAccountPage> createState() => _MyBankAccountPageState();
}

class _MyBankAccountPageState extends State<MyBankAccountPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  late TextEditingController _accountController = TextEditingController();
  late TextEditingController _bankController = TextEditingController();

  String _storedAccount = '';
  String _storedBank = '';

  bool isSubmitVerificationCodeActive = false;
  String selectedBank = '';
  String accountNumber = '';
  bool data = true;
  bool _isSelectListVisible = false;
  String _selectedItem = '';

  String buttonext = '';
  bool Pressed = false;

  String text = '';
  String text2 = '등록하기';
  String text3 = '등록하기';

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController();
    _bankController = TextEditingController();

    _loadAccount().then((_) {
      // Check if both account number and bank name are stored
      if (_storedAccount.isNotEmpty && _storedBank.isNotEmpty) {
        setState(() {
          text = '수정이 완료되었습니다';
          text2 = '수정하기';
          text3 = '수정하기';
        });
      }
    });
  }

  Future<void> _loadAccount() async {
    String? storedAccount = await storage.read(key: 'encrypted_account');
    String? storedBank = await storage.read(key: 'encrypted_bank');
    if (storedAccount != null && storedAccount.isNotEmpty) {
      setState(() {
        _storedAccount = storedAccount;
        _storedBank = storedBank!;
      });
    }
  }

  Future<void> _saveAccount(String accountNumber, String bankName) async {
    await storage.write(key: 'encrypted_account', value: accountNumber);
    await storage.write(key: 'encrypted_bank', value: bankName);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: appBarTitle("내 계좌정보"),
        bottom: appBarBottomLine(),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInputField(screenSize),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenSize.height * 0.03),
              child: isSubmitVerificationCodeActive
                  ? AuthSubmitButton(
                      onPressed: () {
                        if (text.isEmpty) {
                          text = '등록이 완료되었습니다!';
                          text2 = '등록하기';
                          text3 = '수정하기';
                        } else {
                          text = '수정이 완료되었습니다!';
                          text2 = '수정하기';
                          text3 = '수정하기';
                        }
                        _accountPopup(screenSize, context);

                        setState(() {
                          _isSelectListVisible = false;
                        });
                      },
                      buttonText: text3,
                      isActive: Pressed,
                    )
                  : AuthSubmitButton(
                      onPressed: () {},
                      buttonText: text3,
                      isActive: Pressed,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(Size screenSize) {
    return Padding(
      // width: screenSize.width,
      // height: screenSize.height * 0.58,
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountNumber(screenSize),
          const SizedBox(height: 24),
          _buildAccountSelect(_storedBank),
        ],
      ),
    );
  }

  Widget _buildAccountNumber(Size screenSize) {
    String hintText = _storedAccount.isEmpty ? '계좌번호 입력(-제외)' : _storedAccount;

    void onAccountChanged(String value) {
      setState(() {
        accountNumber = value;
        // Provider.of<UserProvider>(context, listen: false)
        //     .setAccount(accountNumber);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleEachSection("계좌번호"),
        Container(
          alignment: Alignment.center,
          width: screenSize.width * 0.91,
          height: screenSize.height * 0.06,
          child: TextField(
            onChanged: onAccountChanged,
            controller: _accountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFA19E9E),
                  width: 1.0,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF302E2E)),
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA19E9E),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

//은행 선택
  Widget _buildAccountSelect(String bankText) {
    void toggleListVisibility() {
      FocusScope.of(context).unfocus();
      setState(() {
        _isSelectListVisible = !_isSelectListVisible;
      });
    }

    void _selectItem(String item) {
      setState(() {
        _selectedItem = item;
        _storedBank = item;
        _isSelectListVisible = false;
        isSubmitVerificationCodeActive = true;
        Pressed = true;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleEachSection("은행 선택"),
        GestureDetector(
          onTap: () {
            setState(() {
              toggleListVisibility();
            });
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isSelectListVisible
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
                (bankText.isEmpty)
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
                        bankText,
                        style: TextStyle(
                          color: _isSelectListVisible
                              ? const Color(0xff302E2E)
                              : const Color(0xFFA19E9E),
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
            ),
          ),
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
              children: bankNameList.map((bankItem) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  hoverColor: const Color(0xffF1F1F1),
                  title: Text(
                    bankItem,
                    style: const TextStyle(
                      color: Color(0xff302E2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () => _selectItem(bankItem),
                );
              }).toList(),
            ),
          ),
      ],
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

  Future<void> _accountPopup(Size screenSize, BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
            '$accountNumber $_selectedItem',
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
                    data = false;

                    String accountNumber = _accountController.text;
                    _saveAccount(accountNumber, _storedBank);
                    setState(() {
                      _storedAccount = accountNumber;
                      _accountController.clear();
                    });
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
                  child: Text(
                    text2,
                    style: const TextStyle(
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
                      side:
                          const BorderSide(color: Color(0xFF726E6E), width: 1),
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
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: screenSize.height * 0.86,
        left: screenSize.width * 0.26,
        child: Container(
          width: screenSize.width * 0.47,
          height: screenSize.height * 0.064,
          decoration: BoxDecoration(
            color: const Color(0xFF302E2E).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                text,
                style: const TextStyle(
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

    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }
}
