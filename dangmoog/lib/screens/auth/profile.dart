import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/user_provider.dart';

import 'package:dangmoog/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:dangmoog/widgets/submit_button.dart';

// 권환 확인
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  String nickname = '';
  String email = '';
  String imagePath = 'assets/images/basic_profile.png';
  final ImagePicker picker = ImagePicker();
  Color buttonColor = const Color(0xFFDADADA); // 초기 버튼 색상

  bool buttonAcitve = false;

  // 이미지 설정 시 유의사항 visibility
  bool isHelpVisible = false;

  Future<void> getImagesFromCamera() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      try {
        final pickedImage = await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null) {
          setState(() {
            _image = File(pickedImage.path);
            imagePath = pickedImage.path;

            buttonAcitve = true;
            profileSubmit();
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("카메라 권한 필요"),
            content:
                const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
            actions: <Widget>[
              TextButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("설정으로 이동"),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getImagesFromAlbum() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      try {
        final pickedImage = await picker.pickImage(source: ImageSource.gallery);

        if (pickedImage != null) {
          setState(() {
            _image = File(pickedImage.path);
            imagePath = pickedImage.path;

            buttonAcitve = true;
            profileSubmit();
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("카메라 권한 필요"),
            content:
                const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
            actions: <Widget>[
              TextButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("설정으로 이동"),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          imagePath = pickedFile.path;
          buttonAcitve = true;
          // 이미지를 선택한 경우 버튼의 색상을 빨간색으로 변경
          buttonColor = const Color(0xFFE20529); // 빨간색

          // 이미지를 Provider에 저장
          Provider.of<UserProvider>(context, listen: false)
              .setUserImage(imagePath);

          profileSubmit();
        });
      }
    }
  }

  Future<String?> profileSubmit() async {
    // If imageFiles are provided, prepare them for FormData

    if (_image != null) {
      try {
        //  final binaryString = toBinaryString(imagePath);

        Response response = await ApiService().setUserProfile(imagePath);

        if (response.statusCode == 200) {
          // int userId = response.data['account_id'];
          // await storage.write(key: 'userId', value: userId.toString());

          final Map<String, dynamic> data = response.data;
          final String? profileUrl =
              data["profile_url"]; // "profile_url" 값을 가져옴

          if (profileUrl != null) {
            imagePath = profileUrl;
            Provider.of<UserProvider>(context, listen: false)
                .setUserImage(imagePath);
          } else {
            // "profile_url"이 null인 경우 처리
            return null;
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  late Future<String?> profileImageUrl; // 프로필 이미지 URL을 저장할 변수

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Text(
                  '잠깐! 프로필을 설정해보세요!',
                  style: TextStyle(
                    color: Color(0xFF302E2E),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '개성있는 사진으로 프로필 사진을 설정해보세요.\n'
                  '프로필 사진은 마이페이지에서 언제든지 수정 가능합니다!\n'
                  '생략할 경우 현재 보이는 사진이 기본 프로필이 됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF302E2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    SizedBox(
                      width: 210,
                      height: 210,
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
                      top: 150,
                      left: 150,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                content: SizedBox(
                                  width: screenSize.width * 0.55,
                                  height: screenSize.height * 0.21,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '사진 업로드 방식을\n선택해주세요!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          addPhotoButtonPopUp(
                                              screenSize,
                                              Icons.add_a_photo_outlined,
                                              '카메라', () {
                                            getImagesFromCamera();
                                          }, context),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          addPhotoButtonPopUp(
                                              screenSize,
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              '앨범', () {
                                            getImagesFromAlbum();
                                          }, context),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: 228,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xff726E6E),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '취소하기',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff726E6E),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFD3D2D2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFFEC5870),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      isHelpVisible = !isHelpVisible;
                    });
                  },
                  child: const Text(
                    '이미지 설정 시 유의사항',
                    style: TextStyle(
                      color: Color(0xFF726E6E),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                isHelpVisible ? profileHelpMsg() : const SizedBox.shrink()
              ],
            ),
            Column(
              children: [
                SizedBox(
                  height: 144,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AuthSubmitButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHome()),
                            (route) => false,
                          );
                        },
                        buttonText: '프로필 설정 완료!',
                        isActive: buttonAcitve,
                      ),
                      const SizedBox(height: 21),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHome()),
                            (route) => false,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            '건너뛰고 시작하기',
                            style: TextStyle(
                              color: Color(0xFFE20529),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget addPhotoButtonPopUp(Size screenSize, IconData icon, String text,
    Function onTap, BuildContext context) {
  return GestureDetector(
    onTap: () {
      onTap();
      Navigator.of(context).pop();
    },
    child: Container(
      width: screenSize.width * 0.192,
      height: screenSize.width * 0.192,
      decoration: const BoxDecoration(
        color: Color(0xffE20529),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
  );
}

Widget profileHelpMsg() {
  Widget textCell(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xff302E2E),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
          )
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Row(
      children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: const Color(0xffD3D2D2),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '다음 사항을 꼭 확인해주세요!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff302E2E),
                  ),
                ),
              ),
              textCell("부적절한 이미지는 제한되며, 등록되었더라도 관리자에 의해 예고없이 사용이 중지될 수 있습니다."),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '부적절한 이미지 기준 안내',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff302E2E),
                  ),
                ),
              ),
              textCell("다른 사용자에게 불쾌감을 줄 수 있는 이미지"),
              textCell("도토릿 운영자, 관리자로 착오할 수 있는 이미지"),
              textCell("본인 혹인 타인의 개인정보가 노출된 이미지 "),
            ],
          ),
        )),
      ],
    ),
  );
}
