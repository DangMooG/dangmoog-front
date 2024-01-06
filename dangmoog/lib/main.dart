import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/chat_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dangmoog/themes/main_theme.dart';
import 'package:dangmoog/screens/auth/splash_page.dart';

// Provider
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/providers/websocket_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        Provider<SocketClass>(
          create: (_) => SocketClass(),
          dispose: (_, socketClass) => socketClass.dispose(),
        ),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => ChatSettingProvider()),
        ChangeNotifierProvider(create: (context) => ChatListProvider()),
      ],
      child: MaterialApp(
        title: 'Dotorit',
        debugShowCheckedModeBanner: false,
        theme: mainThemeData(),
        home: const SplashScreen(),
      ),
    );
  }
}
