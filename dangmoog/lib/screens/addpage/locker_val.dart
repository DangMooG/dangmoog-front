import 'dart:io';
import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/main_page.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/widgets/bottom_popup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class LockerValPage extends StatefulWidget {
  final ProductModel product;
  final ApiService apiService = ApiService();

  LockerValPage(this.product, {Key? key}) : super(key: key);

  @override
  State<LockerValPage> createState() => _LockerValState();
}

class _LockerValState extends State<LockerValPage> {
  File? _image; // Variable to hold the image file
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool isChecked = false;

  bool get isButtonEnabled {
    return _image != null && _passwordController.text.length == 4;
  }

  @override
  void initState() {
    super.initState();
    // Add listener to password controller to update the UI as the user types.
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree.
    _passwordController.removeListener(_updateButtonState);
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Call setState to rebuild the widget with the updated button state.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFBEBCBC),), // Divider below the AppBar
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFBEBCBC)), // Divider above the BottomAppBar
          _buildBottomBar(context, isChecked),
        ],
      ),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("사물함거래 인증"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Stack(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildUploadText(),
              _buildUploadSection(),
              const SizedBox(height: 20),
              _buildPreviousPasswordSection(),
              const SizedBox(height: 20),
              _buildPasswordSection(),
              _buildNotificationSection(),
            ],
          ),
        ),
      ),
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox.shrink()
    ]);
  }

  Widget _buildUploadText() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '사물함 인증사진 업로드',
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // const Text('사물함 인증사진 업로드', textAlign: TextAlign.left),
        const SizedBox(height: 20),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 253,
            height: 253,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.camera_alt, size: 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousPasswordSection(){
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Text('발급 받은 비밀번호', textAlign: TextAlign.left),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text('2024',
            style:
            TextStyle(
                color: Color(0xFFE20529),
                fontSize: 32,
                fontWeight: FontWeight.w600,

                //styleName: Headline L;

                // font-family: Pretendard;
            // fontsize: 32px;
            // font-weight: 600;
            // line-height: 40px;
            // letter-spacing: 0em;
            // text-align: left;

            ),),
          ],
        )
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('설정한 비밀번호 입력(4자리)', textAlign: TextAlign.left),
        TextField(
          controller: _passwordController,
          maxLength: 4,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '비밀번호 4자리 입력',
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    Widget addPhotoButtonPopUp(
        Size screenSize, IconData icon, String text, Function onTap) {
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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        Size screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                    addPhotoButtonPopUp(
                        screenSize, Icons.add_a_photo_outlined, '카메라', () {
                      _pickImageFromCamera(context);
                    }),
                    const SizedBox(
                      width: 30,
                    ),
                    addPhotoButtonPopUp(
                        screenSize, Icons.add_photo_alternate_outlined, '앨범',
                        () {
                      _pickImageFromAlbum(context);
                    }),
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
  }

  Future<void> _pickImageFromAlbum(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
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
            title: const Text("앨범 권한 필요"),
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

  Future<void> _pickImageFromCamera(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
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
    }
  }

  Widget _buildNotificationSection(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "사물함 인증 유의사항",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff302E2E),
            ),
          ),
        ),
        textCell("발급받은 비밀번호를 잠금장치 키패드에 입력하면 잠금장치가 해제됩니다."),
        textCell(
            "물품을 넣고 문을 닫으면 자동으로 잠깁니다."),
        textCell(
            "사물함의 실제 비밀번호와 앱에 입력한 비밀번호가 일치하는지 꼭 확인해주세요."),
        textCell("본인이 설정하신 비밀번호는 설정 이후 바꾸실 수 없으니 신중하게 설정해주세요!"),
        // const SizedBox(height: 80),
      ],
    );
  }

  Widget textCell(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 6.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff302E2E),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isChecked) {
    // bool isChecked= false;
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                _showConfirmationDialog(context, (bool value) {
                  setState(() {
                    isChecked = value;
                  });
                });
              } : null, // Disable the button if conditions aren't met
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isButtonEnabled ? const Color(0xFFE20529) : Colors.grey,
                ),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size(340, 48)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              child: const Text(
                '인증하기',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
      ),

    );
  }

  void _showConfirmationDialog(BuildContext context, Function(bool) onChecked) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool localChecked = isChecked; // Local variable to handle checkbox state

        return StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '마지막 업로드 전 확인해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '비밀번호를 제대로 설정하셨나요?\n설정한 비밀번호를 모두 확인했다면\n아래 체크표시를 눌러 업로드를 진행해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            '제가 설정한 비밀번호를 정확히 확인했습니다!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Checkbox(
                          value: localChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              localChecked = value!;
                            });
                            onChecked(value!); // Update the state in the parent widget
                          },
                          activeColor: const Color(0xFFE20529),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 300,
                      child: TextButton(
                        onPressed: localChecked?() async{
                          print("hello");
                          try {
                            // Get the necessary data
                            int postId = widget.product
                                .postId; // Assuming postId is a property of ProductModel
                            // int lockerId = lockerId; // Assuming lockerId is a property of ProductModel
                            String password = _passwordController.text;

                            Map<String, dynamic> filters = {"post_id": postId};
                            Response searchResponse =
                            await widget.apiService.searchLocker(filters);
                            if (searchResponse.data is List &&
                                searchResponse.data.isNotEmpty) {
                              var locker = searchResponse
                                  .data[0]; // Use the first locker in the list
                              int lockerId =
                              locker['locker_id']; // Extract locker_id

                              // Call valLockerPost from ApiService
                              var lockerAuthResponse = await widget.apiService
                                  .valLockerPost(
                                  postId, lockerId, password, _image!);
                              if (lockerAuthResponse.statusCode == 200) {
                                print("Success: ${lockerAuthResponse.data}");
                                setState(() {
                                  isLoading = false;
                                });

                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyHome()),
                                      (Route<dynamic> route) => false,
                                );
                              } else {
                                print("Failed: ${lockerAuthResponse.statusCode}");
                                showPopup(context, "게시글 업로드에 실패했습니다.");
                              }

                              // Handle success (e.g., show a success message or navigate to another screen)
                            } else {
                              // Handle the case where no lockers are found or the response is not as expected
                              print("No lockers found for the provided post_id.");
                              showPopup(context, "게시글 업로드에 실패했습니다.");
                            }

                            // Handle success (e.g., show a success message or navigate to another screen)
                          } catch (e) {
                            print("Error occurred: $e");
                            // Handle error (e.g., show an error message)
                            showPopup(context, "게시글 업로드에 실패했습니다.");
                          }
                        }:null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              localChecked? const Color(0xFFE20529) : const Color(0xFF726E6E)
                          ),
                          // Color:
                          //   isChecked ? const Color(0xFFE20529) : Colors.grey,
                          // minimumSize:
                          // MaterialStateProperty.all<Size>(const Size(340, 48)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        child: const Text(
                          '업로드하기',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF), // Set the text color as well if needed
                          ),),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    SizedBox(
                      width: 300,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states
                                  .contains(MaterialState.pressed)) {
                                return Colors
                                    .red[600]!; // Color when pressed
                              }
                              return Colors.transparent; // Regular color
                            },
                          ),
                          foregroundColor:
                          MaterialStateProperty.all<Color>(
                              const Color(0xFF726E6E)),
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                  color: Color(0xFF726E6E)),
                            ),
                          ),
                        ),
                        child: const Text('취소하기'),
                      ),
                    ),


                    // ... Add your upload and cancel buttons here ...
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


}
