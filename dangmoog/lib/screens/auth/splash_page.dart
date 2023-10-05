import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/auth/nickname.dart';
import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/welcome.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const storage = FlutterSecureStorage();

  bool _isLoading = true;

  void loadingDone() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    // 비동기로 flutter secure storage 정보를 불러오는 작업
    // initState에서는 async await를 사용할 수 없기 때문에 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoLoginProcess();
    });
  }

  _navigateToHome(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHome()),
    );
  }

  _navigateToWelcome(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  _navigateToNickname(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NicknamePage()),
    );
  }

  autoLoginProcess() async {
    // access_token과 refresh_token이 있는지 확인
    final accessToken = await storage.read(key: 'accessToken');
    final userId = await storage.read(key: 'userId');

    if (accessToken != null && userId != null) {
      try {
        Response response = await ApiService().autoLogin();

        // 유효한 토큰
        if (response.statusCode == 200) {
          final userEmail = response.data["email"] + "@gist.ac.kr";
          final userNickname = response.data['username'];

          Provider.of<UserProvider>(context, listen: false).setEmail(userEmail);

          if (userNickname == null) {
            _navigateToNickname(context);
          } else {
            Provider.of<UserProvider>(context, listen: false)
                .setNickname(userNickname);

            _navigateToHome(context);
          }
        }
      } catch (e) {
        print(e);
        _navigateToWelcome(context);
      }
    } else {
      // 로그인 페이지로 이동
      _navigateToWelcome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.24),
              Image.asset(
                'assets/images/loading_logo.png',
                width: screenSize.width * 0.57,
              ),
            ],
          ),
          _isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink()
        ],
      ),
    ));
  }
}
