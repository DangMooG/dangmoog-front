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

    // 앱의 위젯 트리가 빌드된 후 실행되는 콜백 함수를 등록하는 메서드이다.
    // 비동기로 flutter secure storage 정보를 불러오는 작업이 필요한다.
    // 하지만 initState에서는 async await를 사용할 수 없기 때문에 아래 형식으로 사용한다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoLoginProcess();
      }
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

  // 자동 로그인 처리
  _autoLoginProcess() async {
    // access_token과 userId를 secure storage로부터 불러온다
    // 만약 해당 값이 존재하지 않을 경우 null 값이 저장된다.
    final accessToken = await storage.read(key: 'accessToken');
    final userId = await storage.read(key: 'userId');

    // accessToken userId가 존재할 경우
    if (accessToken != null && userId != null) {
      try {
        Response response = await ApiService().autoLogin();

        // 유효한 토큰일 경우
        if (response.statusCode == 200) {
          final userEmail = response.data["email"];
          final userNickname = response.data['username'];
          final nicknameState = response.data['available'];
          final String profileUrl = response.data["profile_url"];

          // async 내에서 BuildContexts를 사용할 경우
          // 위젯이 마운트되지 않았으면 context에 아무런 값이 없기 때문에
          // 아래 조건문을 추가해줘야 한다.

          if (!mounted) return;

          // 이메일을 provider로 전역변수에 저장한다
          Provider.of<UserProvider>(context, listen: false).setEmail(userEmail);
          Provider.of<UserProvider>(context, listen: false).getMyPostListId();

          Provider.of<UserProvider>(context, listen: false)
              .setUserImage(profileUrl);

          Provider.of<UserProvider>(context, listen: false)
              .updateNicknameButton(nicknameState);

          // 별명을 설정하지 않았을 경우
          // 별명 설정 페이지로 이동한다
          if (userNickname == null) {
            _navigateToNickname(context);
          }
          // 별명을 설정했을 경우
          // 메인 페이지로 이동한다
          else {
            Provider.of<UserProvider>(context, listen: false)
                .setNickname(userNickname);
            _navigateToHome(context);
          }
        }
      } catch (e) {
        // 자동 로그인에 실패했을 경우
        // 로그인 페이지로 이동
        if (!mounted) return;
        _navigateToWelcome(context);
      }
    }
    // accessToken 또는 userID가 존재하지 않을 경우
    else {
      // 로그인 페이지로 이동
      if (!mounted) return;
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
