import 'package:flutter/material.dart';
import 'package:dangmoog/screens/main_page.dart';
// import 'package:provider/provider.dart';
// import 'package:dangmoog/screens/post/post_list.dart';
// import 'package:dangmoog/models/product_class.dart';

void main() {
  runApp(

      const MyApp(),

  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DangMooG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("")),
    );
  }
}
