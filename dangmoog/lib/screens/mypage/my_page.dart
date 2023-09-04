import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/widgets/mypage_text.dart';

class MyPage extends StatefulWidget {
  final String email;
  const MyPage({required this.email, required String nickname});

  @override
  State<MyPage> createState() => _MyPageState();
}

Future<double?> tillGetSource(Stream<double> source) async {
  await for (double value in source) {
    if (value > 0) {
      return value;
    }
  }
  return null; // No positive value found
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    String userEmail = Provider.of<UserProvider>(context).email;
    String userNickname = Provider.of<UserProvider>(context).nickname;
    return FutureBuilder<double?>(
      future: tillGetSource(Stream<double>.periodic(
          const Duration(milliseconds: 100),
          (_) => MediaQuery.of(context).size.width)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future가 완료되지 않았을 때 표시할 UI
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Future가 성공적으로 완료되었을 때 표시할 UI
          double value = snapshot.data!;
          Size screenSize = MediaQuery.of(context).size;
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.width * 0.042),
                Row(children: [
                  SizedBox(width: screenSize.width * 0.042),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/sample.png',
                      width: screenSize.width * 0.20,
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.042),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$userNickname',
                        style: TextStyle(
                          color: Color(0xFF552619),
                          fontFamily: 'Pretendard-SemiBold',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$userEmail',
                        style: TextStyle(
                          color: Color(0xFFA07272),
                          fontFamily: 'Pretendard-Regular',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ]),
                SizedBox(height: screenSize.width * 0.043),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.width * 0.043),
                  child: Container(
                    width: screenSize.width * 0.91,
                    height: 1,
                    color: Color(0XFFCCBEBA), // 갈색 배경색
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.043),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.width * 0.04),
                  child: Text(
                    '마이거래',
                    style: TextStyle(
                      color: Color(0xFF552619),
                      fontFamily: 'Pretendard-Semibold',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MypageText(
                    text: '관심목록',
                    icon: Icons.favorite_border,
                    onPressed: () {}),
                MypageText(
                    text: '판매내역',
                    icon: Icons.monetization_on_outlined,
                    onPressed: () {}),
                MypageText(
                    text: '구매내역',
                    icon: Icons.local_mall_outlined,
                    onPressed: () {}),
                SizedBox(height: screenSize.height * 0.1),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.width * 0.043),
                  child: Container(
                    width: screenSize.width * 0.91,
                    height: 1,
                    color: Color(0XFFCCBEBA), // 갈색 배경색
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.043),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.width * 0.04),
                  child: Text(
                    '설정',
                    style: TextStyle(
                      color: Color(0xFF552619),
                      fontFamily: 'Pretendard-Semibold',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MypageText(
                    text: '내 계정', icon: Icons.person_outline, onPressed: () {}),
                MypageText(
                    text: '거래정보',
                    icon: Icons.table_chart_outlined,
                    onPressed: () {}),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
