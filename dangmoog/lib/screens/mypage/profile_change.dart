import 'package:dangmoog/screens/mypage/nickname_change.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileChangePage extends StatefulWidget {
  const ProfileChangePage({Key? key}) : super(key: key);

  @override
  _ProfileChangePageState createState() => _ProfileChangePageState();
}

class _ProfileChangePageState extends State<ProfileChangePage> {
  File? _image;
  late String imagePath;
  final ImagePicker _picker = ImagePicker();
  Color buttonColor = Color(0xFFDADADA); // 초기 버튼 색상

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/sample.png';
  }

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imagePath = pickedFile.path;

        // 이미지를 선택한 경우 버튼의 색상을 빨간색으로 변경
        buttonColor = Color(0xFFE20529); // 빨간색

        // 이미지를 Provider에 저장
        Provider.of<UserProvider>(context, listen: false).setUserImage(_image!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    String userEmail = Provider.of<UserProvider>(context).inputEmail;
    String userNickname = Provider.of<UserProvider>(context).nickname;
    File? userImage = Provider.of<UserProvider>(context).userImage;
    final userProvider = Provider.of<UserProvider>(context);
    late bool isButtonDisabled = userProvider.isButtonDisabled;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.19),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: screenSize.width * 0.56,
                height: screenSize.width * 0.56,
                child: ClipOval(
                  child: userImage != null
                      ? Image.file(
                          userImage,
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
                      Icons.camera_alt_outlined,
                      color: Color(0xFFEC5870),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            '$userNickname',
            style: TextStyle(
              color: Color(0xFF302E2E),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton(
            onPressed: isButtonDisabled
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NicknameChangePage(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE20529),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size(
                screenSize.width * 0.2,
                screenSize.height * 0.029,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              width: screenSize.width * 0.16,
              height: screenSize.height * 0.023,
              child: const Text(
                '닉네임 변경',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'Pretendard-Medium',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Text(
            '$userEmail',
            style: const TextStyle(
              color: Color(0xFF302E2E),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Container(
            alignment: Alignment.center,
          )
        ],
      ),
    );
  }
}
