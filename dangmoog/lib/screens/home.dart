import 'package:dangmoog/fcmSetting.dart';
import 'package:dangmoog/screens/auth/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHome extends StatefulWidget {
  String? fcmToken;
  MyHome({
    super.key,
    required this.fcmToken,
  });

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SplashScreen()));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SizedBox(
      height: 30,
      width: 30,
      child: SizedBox.shrink(),
    ));
  }
}
