import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/mypage/profile_change.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/providers/user_provider.dart';

class NicknameChangePage extends StatefulWidget {
  const NicknameChangePage({Key? key}) : super(key: key);

  @override
  State<NicknameChangePage> createState() => _NicknameChangePageState();
}

class _NicknameChangePageState extends State<NicknameChangePage> {
  late String imagePath;

  Color buttonColor = const Color(0xFFDADADA); // 초기 버튼 색상

  String nickname = '';
  String errorMessage = '';

  bool isRedText = true;

  bool _isChecked = false;
  bool _isRightFormat = false;

  bool isHelpVisible = false;

  String? profileUrl;

  void setErrorMessage(String message, bool isRed) {
    setState(() {
      errorMessage = message;
      isRedText = isRed;
    });
  }

  void onNicknameChanged(String value) {
    RegExp wrongRegex = RegExp(r'[^a-zA-Z0-9가-힣]');
    double weightedLength = calculateWeightedLength(value);

    setState(() {
      nickname = value;
    });

    // 이미 중복확인하고 별명 수정하면 중복확인 다시 하도록 설정
    if (_isChecked == true) {
      _isChecked = false;
    }

    if (weightedLength < 2) {
      setErrorMessage('최소 2글자 이상 입력해주세요', true);
    } else if (wrongRegex.hasMatch(value)) {
      setErrorMessage('숫자, 한글, 또는 영문 조합으로 입력해주세요.', true);
    } else if (checkNicknameFormat(value)) {
      setErrorMessage("", false);
      _isRightFormat = true;
    }
    if (weightedLength > 7) {
      setErrorMessage('별명은 최대 7글자 입력 가능합니다', true);
      _isRightFormat = false;
    }
  }

  bool checkNicknameFormat(String value) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9가-힣]{2,15}$');
    return regex.hasMatch(value);
  }

  double calculateWeightedLength(String value) {
    double weightedLength = 0;
    for (int i = 0; i < value.length; i++) {
      String char = value[i];
      if (RegExp(r'^[a-zA-Z0-9]$').hasMatch(char)) {
        // 영어 알파벳 또는 숫자인 경우
        weightedLength += 0.5;
      } else if (RegExp(r'^[가-힣]$').hasMatch(char)) {
        // 한글인 경우
        weightedLength += 1;
      }
    }
    return weightedLength;
  }

  void isNicknameDuplicate() async {
    try {
      Response response = await ApiService().checkDuplicateNickname(nickname);
      if (response.statusCode == 200) {
        setErrorMessage('사용 가능한 별명입니다.', false);

        setState(() {
          _isChecked = true;
        });
      } else if (response.statusCode == 409) {
        setErrorMessage('이미 존재하는 별명입니다.', true);
        setState(() {
          _isChecked = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //API에서 사진 가져오기
  Future<String> fetchProfileImageUrl() async {
    try {
      final Response response = await ApiService().autoLogin(); // API 호출

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String profileUrl = data["profile_url"]; // "profile_url" 값을 가져옴
        return profileUrl;
      } else {
        // API 응답에 문제가 있는 경우 오류 처리
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 URL 가져오기 오류: $e');
      rethrow;
    }
  }

  void nickNameSubmit() async {
    try {
      Response response = await ApiService().setUserNickname(nickname);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).setNickname(nickname);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const ProfileChangePage(),
            transitionDuration: const Duration(seconds: 0), // No animation
            reverseTransitionDuration:
                const Duration(seconds: 2), // No animation when pop
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/sample.png';
    fetchProfileImageUrl().then((url) {
      setState(() {
        profileUrl = url;
      });
    });
  }

  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    final position = scrollController.position.maxScrollExtent;

    // if (scrollController.position.pixels == 0) {
    //   return;
    // }
    scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String changeUserNickname = Provider.of<UserProvider>(context).nickname;
    String? userImage = Provider.of<UserProvider>(context).userProfileImageUrl;
    final user = Provider.of<UserProvider>(context);
    int isButtonDisabled = user.isButtonDisabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            "닉네임 변경",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff302E2E),
            ),
          ),
          centerTitle: true,
          actions: [
            _changeNicknameButton(screenSize, context, nickname,
                changeUserNickname, isButtonDisabled, _isChecked),
          ],
          bottom: appBarBottomLine(),
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.19),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width * 0.56,
                    height: screenSize.width * 0.56,
                    child: ClipOval(
                      child: profileUrl != null
                          ? Image.network(
                              profileUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              Container(
                alignment: Alignment.center,
                width: screenSize.width * 0.91,
                height: screenSize.height * 0.05,
                child: TextField(
                  onChanged: onNicknameChanged,
                  textAlign: TextAlign.center,
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 700), () {
                      // 스크롤 컨트롤러를 사용하여 스크롤 가능한 위젯을 가장 아래로 스크롤합니다.
                      // if (scrollController.hasClients) {
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      // }
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFA19E9E), // 원하는 border 색상 설정
                        width: 2.0, // 원하는 border 너비 설정
                      ),
                    ),
                    hintText: '변경할 닉네임 이름을 입력해주세요.',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA19E9E),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Color(0xffE20529),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _changeNicknameButton(
    Size screenSize,
    BuildContext context,
    String nickname,
    String changeUserNickname,
    int isButtonDisabled,
    bool isChecked,
  ) {
    return TextButton(
      onPressed: () {
        if (nickname.length >= 2) {
          // 닉네임이 유효한 경우에만 업데이트합니다.

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                surfaceTintColor: Colors.transparent,
                titlePadding: const EdgeInsets.only(top: 24),
                title: Column(
                  children: [
                    const Text(
                      '바꿀 닉네임을 다시 한번 확인해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302E2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$nickname"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF302E2E),
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  '닉네임 변경은 단 1번만 가능하며,\n 그 이후에는 닉네임을 바꿀 수 없습니다.\n 그래도 변경하시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF302E2E),
                  ),
                ),
                actions: [
                  SizedBox(
                    width: 280,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<UserProvider>(context, listen: false)
                                .updateNicknameButton(0);
                            nickNameSubmit();

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE20529),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            minimumSize: Size(
                              screenSize.width * 0.67,
                              screenSize.height * 0.044,
                            ),
                          ),
                          child: const Text(
                            '닉네임 변경하기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 팝업 창을 닫을 때 수행할 작업을 여기에 추가하세요.
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                  color: Color(0xFF726E6E), width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            minimumSize: Size(
                              screenSize.width * 0.67,
                              screenSize.height * 0.044,
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
                  ),
                ],
              );
            },
          );
        } else {}
      },
      child: const Text(
        '변경하기',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}
