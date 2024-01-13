import 'package:dangmoog/screens/mypage/nickname_change.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:provider/provider.dart';
import 'package:dangmoog/providers/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

// 권환 확인
import 'package:permission_handler/permission_handler.dart';

class ProfileChangePage extends StatefulWidget {
  const ProfileChangePage({Key? key}) : super(key: key);

  @override
  State<ProfileChangePage> createState() => _ProfileChangePageState();
}

class _ProfileChangePageState extends State<ProfileChangePage> {
  File? _image;
  String imagePath = 'assets/images/basic_profile.png';
  String nickname = '';
  String email = '';
  final ImagePicker picker = ImagePicker();
  //Color buttonColor = const Color(0xFFDADADA); // 초기 버튼 색상

  bool buttonAcitve = false;

  // 이미지 설정 시 유의사항 visibility
  bool isHelpVisible = false;

  static const storage = FlutterSecureStorage();

  // String imageString = fileToBase64String(imagePath);

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

            Provider.of<UserProvider>(context, listen: false)
                .setUserImage(_image!);

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
          //buttonColor = const Color(0xFFE20529); // 빨간색

          // 이미지를 Provider에 저장
          Provider.of<UserProvider>(context, listen: false)
              .setUserImage(_image!);

          profileSubmit();
          fetchProfileImageUrl();
        });
      }
    }
  }

  // Future<void> _getImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   builder:
  //   (context, snapshot) {
  //     if (pickedFile != null) {
  //       setState(() {
  //         _image = File(pickedFile.path);
  //         imagePath = pickedFile.path;
  //         Map<String, dynamic> data =
  //             snapshot.data!.data; // This should be a Map
  //         String imageUrl = data["url"];

  //         // 이미지를 선택한 경우 버튼의 색상을 빨간색으로 변경
  //         // buttonColor = Color(0xFFE20529); // 빨간색

  //         // 이미지를 Provider에 저장
  //         Provider.of<UserProvider>(context, listen: false)
  //             .setUserImage(_image!);
  //       });
  //     }
  //   };
  // }

  // API에서 사진가져오기
  Future<String?> fetchProfileImageUrl() async {
    try {
      final Response response = await ApiService().autoLogin(); // API 호출

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final String? profileUrl = data["profile_url"]; // "profile_url" 값을 가져옴

        if (profileUrl != null) {
          return profileUrl;
        } else {
          // "profile_url"이 null인 경우 처리
          return null;
        }
      } else {
        // API 응답에 문제가 있는 경우 오류 처리
        throw Exception('API 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 URL 가져오기 오류: $e');
      return null; // 에러 발생 시 null 반환
    }
  }

  void profileSubmit() async {
    // If imageFiles are provided, prepare them for FormData

    if (_image != null) {
      try {
        //  final binaryString = toBinaryString(imagePath);

        Response response = await ApiService().setUserProfile(imagePath);

        if (response.statusCode == 200) {
          // int userId = response.data['account_id'];
          if (!mounted) return;
          Provider.of<UserProvider>(context, listen: false)
              .setUserImage(_image!);
          // await storage.write(key: 'userId', value: userId.toString());

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const ProfileChangePage(),
              transitionDuration: const Duration(seconds: 0), // No animation
              reverseTransitionDuration:
                  const Duration(seconds: 0), // No animation when pop
            ),
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  late Future<String?> profileImageUrl; // 프로필 이미지 URL을 저장할 변수

  @override
  void initState() {
    super.initState();
    profileImageUrl = fetchProfileImageUrl(); // 프로필 이미지 URL 가져오기
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
          icon: const Icon(Icons.arrow_back),
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
              SizedBox(
                width: screenSize.width * 0.56,
                height: screenSize.width * 0.56,
                child: ClipOval(
                  child: FutureBuilder<String?>(
                    future:
                        profileImageUrl, // fetchImage 함수 호출하여 profileUrl을 가져옴
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final profileUrl = snapshot.data;
                        if (profileUrl != null) {
                          return Image.network(
                            profileUrl,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Image.asset(
                            'assets/images/basic_profile.png',
                            fit: BoxFit.cover,
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator(); // 데이터 로딩 중 표시
                      }
                    },
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    addPhotoButtonPopUp(screenSize,
                                        Icons.add_a_photo_outlined, '카메라', () {
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
              // Positioned(
              //   top: screenSize.height * 0.19,
              //   left: screenSize.height * 0.19,
              //   child: GestureDetector(
              //     onTap: profileSubmit,
              //     child: Container(
              //       width: 50,
              //       height: 50,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.white,
              //         border: Border.all(
              //           color: Color(0xFFD3D2D2),
              //           width: 1,
              //         ),
              //       ),
              //       child: Icon(
              //         Icons.camera_alt_outlined,
              //         color: Color(0xFFEC5870),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            userNickname,
            style: const TextStyle(
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
            userEmail,
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
