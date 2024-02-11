import 'package:dangmoog/services/api.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/screens/mypage/account_delete.dart';

import 'package:dangmoog/screens/auth/welcome.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/user_provider.dart';
import 'package:dangmoog/widgets/mypage_text.dart';
import 'package:dangmoog/screens/mypage/profile_change.dart';
import 'package:dangmoog/screens/mypage/my_bank_account.dart';
import 'package:dangmoog/screens/mypage/sell/my_sell_mainpage.dart';
import 'package:dangmoog/screens/mypage/purchase/purchase_mainpage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPage extends StatefulWidget {
  const MyPage({
    super.key,
  });

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userEmail =
        Provider.of<UserProvider>(context, listen: false).userEmail;
    String userNickname =
        Provider.of<UserProvider>(context, listen: true).nickname;
    String? userImage =
        Provider.of<UserProvider>(context, listen: true).userProfileImageUrl;
    Size screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                    child: userImage != "" && userImage != null
                        ? Image.network(
                            userImage,
                            width: screenSize.width * 0.14,
                            height: screenSize.width * 0.14,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xffD9D9D9),
                                ),
                                width: screenSize.width * 0.14,
                                height: screenSize.height * 0.14,
                              );
                            },
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                "assets/images/basic_profile.png",
                                width: screenSize.width * 0.14,
                                height: screenSize.width * 0.14,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/basic_profile.png',
                            width: screenSize.width * 0.14,
                            height: screenSize.width * 0.14,
                            fit: BoxFit.cover,
                          )),
                const SizedBox(width: 8),
                Expanded(
                  // width: screenSize.width * 0.44,
                  //height: screenSize.height * 0.06,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userNickname,
                        style: const TextStyle(
                          color: Color(0xFF302E2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Color(0xFF726E6E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(75, 24),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '프로필 변경',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              text: '판매내역',
              icon: Icons.monetization_on_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MySellMainPage(),
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
                    builder: (context) => const PurchaseMainPage(),
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
                    builder: (context) => const MyBankAccountPage(),
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
              text: '알림 및 권한 설정',
              icon: Icons.notifications_outlined,
              onPressed: () {
                openAppSettings();
              }),
          // MypageText(
          //     text: '차단 관리',
          //     icon: Icons.voice_over_off_outlined,
          //     onPressed: () {
          //       showPopup(context, "서비스 예정입니다");
          //     }),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // MypageText(
          //     text: '공지사항',
          //     icon: Icons.campaign_outlined,
          //     onPressed: () {
          //       showPopup(context, "서비스 예정입니다");
          //     }),
          MypageText(
              text: '자주 묻는 질문',
              icon: Icons.support_agent_outlined,
              onPressed: () {
                launchUrl(
                  Uri.parse(
                      'https://dangmoog.notion.site/e2c98dd1ce0049dba05a37d550a83f18?pvs=4'),
                );
              }),
          mypageButtonSecond(
              text: '도토릿 소개',
              imageUrl: 'assets/images/dotorit_intro_icon.png',
              onPressed: () {
                launchUrl(
                  Uri.parse(
                      'https://dangmoog.notion.site/dangmoog/20ca8562e68f4e1b8b28c40461f0edda'),
                );
              }),
          MypageText(
              text: '버전 1.0.0',
              icon: Icons.device_hub_outlined,
              onPressed: () {
                // showPopup(context, "서비스 예정입니다");
              }),
          MypageText(
              text: '로그아웃',
              icon: Icons.logout_outlined,
              onPressed: () {
                LogoutPopup(screenSize, context);
              }),
          MypageText(
              text: '탈퇴하기',
              icon: Icons.delete_outline_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountDeletePage(),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Future LogoutPopup(Size screenSize, BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          surfaceTintColor: Colors.transparent,
          title: const Column(
            children: [
              Text(
                '로그아웃',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF302E2E),
                ),
              ),
            ],
          ),
          content: const Text(
            '정말 로그아웃 하시겠어요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF302E2E),
            ),
          ),
          actions: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await storage.delete(key: 'accessToken');
                      await storage.delete(key: 'userId');
                      await storage.delete(key: 'bankName');
                      await storage.delete(key: 'accountNumber');

                      ApiService().fcmDelete();

                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()),
                        (route) => false,
                      );
                    } catch (e) {
                      print("로그아웃에 실패했습니다.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE20529),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size(
                      screenSize.width * 0.67,
                      40,
                    ),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side:
                          const BorderSide(color: Color(0xFF726E6E), width: 1),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size(
                      screenSize.width * 0.67,
                      40,
                    ),
                  ),
                  child: const Text(
                    '취소하기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF726E6E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class mypageButton extends StatelessWidget {
  final String text;
  final String imageUrl;
  final VoidCallback onPressed;

  const mypageButton(
      {super.key,
      required this.text,
      required this.imageUrl,
      required this.onPressed});

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
            const SizedBox(width: 12),
            Image.asset(
              imageUrl,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
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

class mypageButtonSecond extends StatelessWidget {
  final String text;
  final String imageUrl;
  final VoidCallback onPressed;

  const mypageButtonSecond({
    super.key,
    required this.text,
    required this.imageUrl,
    required this.onPressed,
  });

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
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                imageUrl,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
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
