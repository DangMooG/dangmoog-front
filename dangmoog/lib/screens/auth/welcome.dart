import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/signup.dart';

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
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.26),
                Container(
                  child: Image.asset(
                    'assets/images/dotorit_welcome.png',
                    width: screenSize.width * 0.31,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                const Text(
                  'HOUSE 안에서 편하게 거래하자!',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontFamily: 'Pretendard-Regular',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.009),
                const Text(
                  'GIST 기숙사 내에서의 간편한 중고거래!',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontFamily: 'Pretendard-Regular',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const Text(
                  '지금 가입하고 시작해보세요!',
                  style: TextStyle(
                    color: Color(0xFF552619),
                    fontFamily: 'Pretendard-SemiBold',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.208),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignupPage()), // LoginPage로 이동합니다.
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC30020),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Container(
                    width: screenSize.width * 0.81,
                    height: screenSize.height * 0.056,
                    alignment: Alignment.center,
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard-Medium',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Row를 수평 방향으로 중앙 정렬
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
                        print("시작하기 버튼이 눌렸습니다.");
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
