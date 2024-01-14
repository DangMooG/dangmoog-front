import 'package:dangmoog/screens/auth/welcome.dart';

import 'package:dangmoog/widgets/submit_button.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ByePage extends StatefulWidget {
  const ByePage({Key? key}) : super(key: key);

  @override
  State<ByePage> createState() => _ByePageState();
}

class _ByePageState extends State<ByePage> {
  final storage = const FlutterSecureStorage();

  bool isSubmitVerificationCodeActive = false;
  String selectedBank = '';
  String account = '';

  final bool _isSelectListVisible = false;
  final String _selectedItem = '';

  String buttonext = '';
  bool isClicked = false;

  String text = '';

  VoidCallback onPressed = () {};

  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('탈퇴하기'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.024),
                  const Text(
                    '탈퇴가 완료되었습니다',
                    style: TextStyle(
                      color: Color(0xFF302E2E),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Image.asset(
                    'assets/images/bye_image.png',
                  ),
                  const Text(
                    '더 좋은 서비스로 돌아올께요! 우리 꼭 다시 만나요!',
                    style: TextStyle(
                      color: Color(0xFF514E4E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),
                  AuthSubmitButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
                      );
                    },
                    buttonText: '시작 페이지로 이동하기',
                    isActive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
