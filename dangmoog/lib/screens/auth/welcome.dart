import 'package:dangmoog/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/signup.dart';

import 'package:dangmoog/widgets/submit_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: screenSize.height * 0.26),
              Image.asset(
                'assets/images/dotorit_welcome.png',
                width: screenSize.width * 0.31,
              ),
              SizedBox(height: screenSize.height * 0.02),
              const Text(
                'HOUSE 안에서 편하게 거래하자!',
                style: TextStyle(
                  color: Color(0xFF302E2E),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenSize.height * 0.009),
              const Text(
                'GIST 기숙사 내에서의 간편한 중고거래!\n지금 가입하고 시작해보세요!',
                style: TextStyle(
                  color: Color(0xFF302E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(
            height: screenSize.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AuthSubmitButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                  buttonText: '시작하기',
                  isActive: true,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있나요?',
                      style: TextStyle(
                        color: Color(0xFF726E6E),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      width: screenSize.height * 0.01,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            color: Color(0xFFE20529),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
