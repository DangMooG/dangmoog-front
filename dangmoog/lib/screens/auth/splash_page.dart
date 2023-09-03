import 'package:flutter/material.dart';

// import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/screens/auth/welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
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
