import 'package:flutter/material.dart';
import 'package:dangmoog/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:dangmoog/screens/auth/submit_button.dart';

// 권환 확인
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  late String imagePath;
  final ImagePicker picker = ImagePicker();
  Color buttonColor = const Color(0xFFDADADA); // 초기 버튼 색상

  bool buttonAcitve = false;

  @override
  void initState() {
    super.initState();
    imagePath = 'assets/images/basic_profile.png';
  }

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
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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

    // final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // if (pickedFile != null) {
    //   setState(() {
    //     _image = File(pickedFile.path);
    //     imagePath = pickedFile.path;

    //     buttonAcitve = true;
    //   });
    // }
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
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: screenSize.height * 0.19),
              const Text(
                '잠깐! 프로필을 설정해보세요!',
                style: TextStyle(
                  color: Color(0xFF302E2E),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                '개성있는 사진으로 프로필 사진을 설정해보세요.\n'
                '프로필 사진은 마이페이지에서 언제든지 수정 가능합니다!\n'
                '생략할 경우 현재 보이는 사진이 기본 프로필이 됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF302E2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              SizedBox(height: screenSize.height * 0.078),
              Stack(
                children: [
                  SizedBox(
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
                    top: screenSize.height * 0.19,
                    left: screenSize.height * 0.19,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    14), // 여기서 원하는 값으로 둥글게 조절할 수 있습니다.
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
                                            Icons.add_photo_alternate_outlined,
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
            ],
          ),
          Column(
            children: [
              SizedBox(
                height: screenSize.height * 0.2,
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
                    const SizedBox(height: 30),
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
                          '건너띄고 시작하기',
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
