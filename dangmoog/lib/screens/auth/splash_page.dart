import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/welcome.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    // initState에서는 async await를 사용할 수 없기 때문에 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoLoginProcess();
    });
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  static const storage = FlutterSecureStorage();
  autoLoginProcess() async {
    // access_token과 refresh_token이 있는지 확인
    final accessToken = await storage.read(key: "access_token");
    final refreshToken = await storage.read(key: "refresh_token");

    if (refreshToken != null) {
      // 서버로 유효한 토큰이 맞는지 확인 요청

      // 유효할 경우 -> home으로 이동
      // 만료된 토큰일 경우 -> 새로 받은 토큰을 기기에 저장하고 home으로 이동
      // 잘못된 토큰일 경우 -> 로그인 페이지로 이동
    } else {
      // 로그인 페이지로 이동
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.24),
          Image.asset(
            'assets/images/loading_logo.png',
            width: screenSize.width * 0.57,
          ),
        ],
      ),
    ));
  }
}
