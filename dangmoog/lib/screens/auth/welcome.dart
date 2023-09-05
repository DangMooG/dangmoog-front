import 'package:dangmoog/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/signup.dart';
import 'package:dangmoog/widgets/auth_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

Future<double?> tillGetSource(Stream<double> source) async {
  await for (double value in source) {
    if (value > 0) {
      return value;
    }
  }
  return null; // No positive value found
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double?>(
      future: tillGetSource(Stream<double>.periodic(
          const Duration(milliseconds: 100),
          (_) => MediaQuery.of(context).size.width)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future가 완료되지 않았을 때 표시할 UI
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Future가 성공적으로 완료되었을 때 표시할 UI
          double value = snapshot.data!;
          Size screenSize = MediaQuery.of(context).size;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    fontFamily: 'Pretendard-Regular',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.009),
                const Text(
                  'GIST 기숙사 내에서의 간편한 중고거래!',
                  style: TextStyle(
                    color: Color(0xFF302E2E),
                    fontFamily: 'Pretendard-Regular',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const Text(
                  '지금 가입하고 시작해보세요!',
                  style: TextStyle(
                    color: Color(0xFF302E2E),
                    fontFamily: 'Pretendard-SemiBold',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.208),
                AuthButton(
                  text: '시작하기',
                  color: Color(0xFFE20529),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignupPage()), // LoginPage로 이동합니다.
                    );
                  },
                ),
                SizedBox(height: screenSize.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있나요?',
                      style: TextStyle(
                        color: Color(0xFF552619),
                        fontFamily: 'Pretendard-Regular',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            color: Color(0xFFC30020),
                            fontFamily: 'Pretendard-Medium',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
