import 'package:dangmoog/screens/mypage/like/like_mainpage.dart';
import 'package:dangmoog/screens/auth/welcome.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:dangmoog/widgets/mypage_text.dart';
import 'package:dangmoog/screens/mypage/profile_change.dart';
import 'package:dangmoog/screens/mypage/my_account.dart';
import 'package:dangmoog/screens/mypage/sell/my_sell_mainpage.dart';
import 'package:dangmoog/screens/mypage/purchase/purchase_mainpage.dart';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPage extends StatefulWidget {
  final String email;
  const MyPage({super.key, required this.email, required String nickname});

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
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    String userEmail = Provider.of<UserProvider>(context).inputEmail;
    String userNickname = Provider.of<UserProvider>(context).nickname;
    File? userImage = Provider.of<UserProvider>(context).userImage;
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.width * 0.042),
                Row(children: [
                  SizedBox(width: screenSize.width * 0.042),
                  ClipOval(
                    //borderRadius: BorderRadius.circular(50),
                    child: userImage != null // UserProvider에서 이미지를 가져옴
                        ? Image.file(
                            userImage,
                            width: screenSize.width * 0.14,
                            height: screenSize.width * 0.14,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/sample.png', // 기본 이미지
                            width: screenSize.width * 0.14,
                            height: screenSize.width * 0.14,
                          ),
                  ),
                  SizedBox(width: screenSize.width * 0.042),
                  Expanded(
                    // width: screenSize.width * 0.44,
                    //height: screenSize.height * 0.06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userNickname,
                          style: const TextStyle(
                            color: Color(0xFF552619),
                            fontFamily: 'Pretendard-SemiBold',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Color(0xFFA07272),
                            fontFamily: 'Pretendard-Regular',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileChangePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE20529),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size(
                        screenSize.width * 0.2,
                        screenSize.height * 0.029,
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        '프로필 변경',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'Pretendard-Medium',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.045),
                ]),
                SizedBox(height: screenSize.height * 0.019),
                Container(
                  width: screenSize.width,
                  height: 1,
                  color: const Color(0XFFD3D2D2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenSize.width * 0.04,
                      screenSize.height * 0.019, 0, screenSize.height * 0.009),
                  child: const Text(
                    '마이거래',
                    style: TextStyle(
                      color: Color(0xFF302E2E),
                      fontFamily: 'Pretendard-Semibold',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MypageText(
                    text: '관심목록',
                    icon: Icons.favorite_border,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LikeMainPage(),
                        ),
                      );
                    }),
                MypageText(
                    text: '판매내역',
                    icon: Icons.monetization_on_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MySellMainPage(),
                        ),
                      );
                    }),
                MypageText(
                    text: '구매내역',
                    icon: Icons.local_mall_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseMainPage(),
                        ),
                      );
                    }),
                MypageText(
                    text: '내 계좌정보',
                    icon: Icons.credit_card_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyaccountPage(),
                        ),
                      );
                    }),
                SizedBox(height: screenSize.height * 0.009),
                Container(
                  width: screenSize.width,
                  height: 1,
                  color: const Color(0XFFD3D2D2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenSize.width * 0.04,
                      screenSize.height * 0.019, 0, screenSize.height * 0.009),
                  child: const Text(
                    '설정',
                    style: TextStyle(
                      color: Color(0xFF302E2E),
                      fontFamily: 'Pretendard-Semibold',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MypageText(
                    text: '알람 및 소리',
                    icon: Icons.notifications_outlined,
                    onPressed: () {}),
                MypageText(
                    text: '차단 관리',
                    icon: Icons.voice_over_off_outlined,
                    onPressed: () {}),
                SizedBox(height: screenSize.height * 0.009),
                Container(
                  width: screenSize.width,
                  height: 1,
                  color: const Color(0XFFD3D2D2),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(screenSize.width * 0.04,
                      screenSize.height * 0.019, 0, screenSize.height * 0.009),
                  child: const Text(
                    '기타',
                    style: TextStyle(
                      color: Color(0xFF302E2E),
                      fontFamily: 'Pretendard-Semibold',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MypageText(
                    text: '공지사항',
                    icon: Icons.campaign_outlined,
                    onPressed: () {}),
                MypageText(
                    text: '자주 묻는 질문',
                    icon: Icons.support_agent_outlined,
                    onPressed: () {}),
                mypageButton(
                    text: '도토릿 소개',
                    imageUrl: 'assets/images/dotorit_intro_icon.png',
                    onPressed: () {}),
                MypageText(
                    text: '버전 정보',
                    icon: Icons.device_hub_outlined,
                    onPressed: () {}),
                MypageText(
                    text: '로그아웃',
                    icon: Icons.logout_outlined,
                    onPressed: () async {
                      try {
                        await storage.delete(key: 'accessToken');
                        await storage.delete(key: 'userId');

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomePage()),
                          (route) => false,
                        );
                      } catch (e) {
                        print("로그아웃에 실패했습니다.");
                      }
                    }),
                MypageText(
                    text: '탈퇴하기',
                    icon: Icons.delete_outline_outlined,
                    onPressed: () async {
                    Response response = await ApiService().deleteAccount();
                    print(response);
                    if (response.statusCode == 200) {
                      await storage.delete(key: 'accessToken');
                      await storage.delete(key: 'userId');
                      await storage.delete(key: 'userEmail');

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class mypageButton extends StatelessWidget {
  final String text;
  final String imageUrl;
  final VoidCallback onPressed;

  mypageButton(
      {required this.text, required this.imageUrl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height * 0.049,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Row(
          children: [
            SizedBox(width: 12),
            Image.asset(
              imageUrl,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Color(0xFF302E2E),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
