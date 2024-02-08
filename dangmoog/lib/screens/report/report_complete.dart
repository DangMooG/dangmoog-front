import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/screens/main_page.dart';
import 'package:flutter/material.dart';

class ReportCompletePage extends StatefulWidget {
  final ReportSourceType sourceType;

  const ReportCompletePage({Key? key, required this.sourceType})
      : super(key: key);

  @override
  _ReportCompletePageState createState() => _ReportCompletePageState();
}

enum ReportSourceType {
  userReport,
  postReport,
}

class _ReportCompletePageState extends State<ReportCompletePage> {
  @override
  Widget build(BuildContext context) {
    String appBarTitle =
        widget.sourceType == ReportSourceType.userReport ? '사용자 신고' : '게시글 신고';

    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = 16.0;
    double buttonWidth = screenWidth - (horizontalPadding * 2);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          appBarTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFBEBCBC), // Divider color
            height: 1.0, // Divider thickness
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add the content of your page here
            Image.asset(
              'assets/images/check_circle.png',
              height: 125,
            ),
            const SizedBox(height: 16),
            const Text(
              '신고 접수가\n완료되었습니다!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '신고 접수를 확인하는 대로 도토릿 팀에서\n빠른 시일 내에 가입하신 이메일로 연락드리겠습니다.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 160),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFFE20529)),
                minimumSize:
                    MaterialStateProperty.all<Size>(Size(buttonWidth, 46)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              onPressed: () {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                '메인 페이지로 이동하기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            // ... Other Widgets ...
          ],
        ),
      ),
    );
  }
}
