import 'package:dangmoog/screens/app_bar.dart';
import 'package:dangmoog/screens/mypage/nickname_change.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';

// 권환 확인
import 'package:permission_handler/permission_handler.dart';

class ProfileChangePage extends StatefulWidget {
  const ProfileChangePage({Key? key}) : super(key: key);

  @override
  State<ProfileChangePage> createState() => _ProfileChangePageState();
}

class _ProfileChangePageState extends State<ProfileChangePage> {
  // 사용자 이름, 이메일, 프로필 사진 url
  String? profileImageUrl;
  String? userNickname;
  String? userEmail;

  // 프로필 변경 시 사용
  final ImagePicker picker = ImagePicker();
  String? imagePath;

  bool buttonAcitve = false;

  Future<void> getImagesFromCamera() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      try {
        final pickedImage = await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null && pickedImage.path != "") {
          setState(() {
            imagePath = pickedImage.path;

            buttonAcitve = true;
            profileSubmit();
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied || status.isDenied) {
      if (!mounted) return;
      await showDialog(
        context: context,
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

        if (pickedImage != null && pickedImage.path != "") {
          setState(() {
            imagePath = pickedImage.path;

            buttonAcitve = true;

            profileSubmit();
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied || status.isDenied) {
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
          imagePath = pickedFile.path;
          buttonAcitve = true;

          profileSubmit();
        });
      }
    }
  }

  Future<String?> profileSubmit() async {
    // If imageFiles are provided, prepare them for FormData

    if (imagePath != null && imagePath != "") {
      try {
        Response response = await ApiService().setUserProfile(imagePath!);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final String? profileUrl = data["profile_url"];

          if (profileUrl != null && profileUrl != "") {
            profileImageUrl = profileUrl;
            Provider.of<UserProvider>(context, listen: false)
                .setUserImage(profileImageUrl);
          } else {
            // "profile_url"이 null인 경우 처리
            return null;
          }

          if (!mounted) return Future(() => null);
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        profileImageUrl = Provider.of<UserProvider>(context, listen: false)
            .userProfileImageUrl;
        userEmail = Provider.of<UserProvider>(context, listen: false).userEmail;
        userNickname =
            Provider.of<UserProvider>(context, listen: false).nickname;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    int isButtonDisabled = Provider.of<UserProvider>(context).isButtonDisabled;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "프로필 변경",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xff302E2E),
          ),
        ),
        centerTitle: true,
        bottom: appBarBottomLine(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height * 0.19),
          Stack(
            alignment: Alignment.center,
            children: [
              Consumer<UserProvider>(builder: (context, userProvider, _) {
                return SizedBox(
                  width: screenSize.width * 0.56,
                  height: screenSize.width * 0.56,
                  child: ClipOval(
                    child: userProvider.userProfileImageUrl != null &&
                            userProvider.userProfileImageUrl != ""
                        ? Image.network(
                            userProvider.userProfileImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/basic_profile.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              }),
              Positioned(
                bottom: 5,
                right: 15,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '사진 업로드 방식을\n선택해주세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  addPhotoButtonPopUp(screenSize,
                                      Icons.add_a_photo_outlined, '카메라', () {
                                    getImagesFromCamera();
                                  }, context),
                                  addPhotoButtonPopUp(
                                      screenSize,
                                      Icons.add_photo_alternate_outlined,
                                      '앨범', () {
                                    getImagesFromAlbum();
                                  }, context),
                                ],
                              ),
                              const SizedBox(height: 20),
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
                                    borderRadius: BorderRadius.circular(6),
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
                        );
                      },
                    );
                  },
                  child: Container(
                    width: screenSize.height * 0.06,
                    height: screenSize.height * 0.06,
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
          SizedBox(height: screenSize.height * 0.02),
          Text(
            userNickname ?? "Nickname not found",
            style: const TextStyle(
              color: Color(0xFF302E2E),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          ElevatedButton(
            onPressed: isButtonDisabled == 1
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
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Text(
            userEmail ?? "Email not found",
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
