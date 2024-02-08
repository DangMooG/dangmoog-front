import 'package:dangmoog/fcmSetting.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/chat_setting_provider.dart';
import 'package:dangmoog/providers/post_list_scroll_provider.dart';
import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/screens/main_page.dart';
import 'package:dangmoog/screens/mypage/my_page.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dangmoog/themes/main_theme.dart';
// import 'package:dangmoog/screens/auth/splash_page.dart';

// Provider
import 'package:dangmoog/providers/user_provider.dart';
import 'package:dangmoog/providers/socket_provider.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:dangmoog/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  String? fcmToken = await fcmSetting();
  runApp(MyApp(
    fcmToken: fcmToken,
  ));
}

class MyApp extends StatelessWidget {
  late String? fcmToken;
  MyApp({
    Key? key,
    this.fcmToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider<SocketProvider>(
          create: (_) => SocketProvider(),
          dispose: (_, socketClass) => socketClass.dispose(),
        ),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => ChatSettingProvider()),
        ChangeNotifierProvider(create: (context) => ChatListProvider()),
        ChangeNotifierProvider(create: (context) => PostListScrollProvider()),
      ],
      child: MaterialApp(
        title: '도토릿',
        debugShowCheckedModeBanner: false,
        theme: mainThemeData(),
        home: MyHome(
          fcmToken: fcmToken,
        ),
        routes: {
          "/myhome": (context) => MyHome(
                fcmToken: fcmToken,
              ),
          "/mainpage": (context) => const MainPage(),
          "/mypage": (context) => const MyPage(),
        },
      ),
    );
  }
}
