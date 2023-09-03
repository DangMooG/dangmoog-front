import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/screens/auth/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'DangMooG',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
