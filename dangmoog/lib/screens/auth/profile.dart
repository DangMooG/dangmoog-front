import 'package:flutter/material.dart';
import 'package:dangmoog/screens/auth/login.dart';
import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/widgets/auth_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  late String imagePath;
  final ImagePicker _picker = ImagePicker();
  Color buttonColor = Color(0xFFDADADA); // 초기 버튼 색상

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/basic_image.png';
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imagePath = pickedFile.path;

        // 이미지를 선택한 경우 버튼의 색상을 빨간색으로 변경
        buttonColor = Color(0xFFE20529); // 빨간색
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.19),
          const Text(
            '잠깐! 프로필을 설정해보세요!',
            style: TextStyle(
              color: Color(0xFF302E2E),
              fontFamily: 'Pretendard-Regular',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          SizedBox(height: screenSize.height * 0.018),
          const Text(
            '개성있는 사진으로 프로필 사진을 설정해보세요.\n'
            '프로필 사진은 마이페이지에서 언제든지 수정 가능합니다!\n'
            '생략할 경우 현재 보이는 사진이 기본 프로필이 됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF302E2E),
              fontFamily: 'Pretendard-Regular',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          SizedBox(height: screenSize.height * 0.078),
          Stack(
            children: [
              Container(
                width: screenSize.width * 0.56,
                height: screenSize.width * 0.56,
                child: ClipOval(
                  child: _image != null
                      ? Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: screenSize.width * 0.56,
                  height: screenSize.width * 0.56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: screenSize.height * 0.19,
                left: screenSize.height * 0.19,
                child: GestureDetector(
                  onTap: _getImage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFD3D2D2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.mode_outlined,
                      color: Color(0xFFEC5870),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.15),
          AuthButton(
            text: '프로필 설정 완료!',
            textcolor: Colors.white,
            color: buttonColor, // 버튼의 색상을 buttonColor로 설정
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHome(),
                ),
              ); // 프로필 설정 완료 버튼 누를 때의 동작
            },
          ),
          SizedBox(height: screenSize.height * 0.02),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHome(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                '건너뛰고 시작하기',
                style: TextStyle(
                  color: Color(0xFFE20529),
                  fontFamily: 'Pretendard-Medium',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
