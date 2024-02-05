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

  final storage = const FlutterSecureStorage();

  void getMyDeviceToken() async {
    try {
      await storage.write(key: "fcmToken", value: widget.fcmToken);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getMyDeviceToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   RemoteNotification? notification = message.notification;

    //   if (notification != null) {
    //     FlutterLocalNotificationsPlugin().show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       const NotificationDetails(
    //         android: AndroidNotificationDetails(
    //           'high_importance_channel',
    //           'high_importance_notification',
    //           importance: Importance.max,
    //         ),
    //       ),
    //     );

    //     setState(() {
    //       messageString = message.notification!.body!;

    //       print("Foreground 메시지 수신: $messageString");
    //     });
    //   }
    // });
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
