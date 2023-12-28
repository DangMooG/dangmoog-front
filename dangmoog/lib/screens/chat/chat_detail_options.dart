import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dangmoog/constants/account_list.dart';

// plugins
import 'package:dropdown_button2/dropdown_button2.dart';

class ChatDetailOptions extends StatefulWidget {
  final bool isOptionOn;
  final double keyboardHeight;

  const ChatDetailOptions({
    required this.isOptionOn,
    required this.keyboardHeight,
    super.key,
  });

  @override
  State<ChatDetailOptions> createState() => _ChatDetailOptionsState();
}

class _ChatDetailOptionsState extends State<ChatDetailOptions> {
  static const storage = FlutterSecureStorage();

  bool saveBankAccount = true;

  String accountNumber = '';
  String? selectedBank;

  // 은행별로 divider 넣어주기 위함 //
  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff302E2E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                color: Color(0xffD3D2D2),
              ),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (accountItems.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }
  //

  void setBankAccount(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  '새로운 계좌 정보를 입력해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff302E2E),
                  ),
                ),
                content: const Text(
                  '은행과 계좌번호를 정확히 입력해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff302E2E),
                  ),
                ),
                actions: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              hintText: '계좌번호 입력',
                              hintStyle: TextStyle(
                                  color: Color(0xffA19E9E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              labelText: null,
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffD3D2D2)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff726E6E)),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 8.0),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                            ),
                            style: const TextStyle(
                              color: Color(0xff302E2E),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              accountNumber = value;
                            },
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '은행 선택',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xffA19E9E),
                                    ),
                                  ),
                                ),
                                items: _addDividersAfterItems(accountItems),
                                value: selectedBank,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedBank = value;
                                  });
                                },
                                iconStyleData: IconStyleData(
                                    icon: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xffA19E9E),
                                    ),
                                    openMenuIcon: Transform.rotate(
                                        angle: pi / 2,
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xff302E2E),
                                        ))),
                                buttonStyleData: const ButtonStyleData(
                                  height: 40,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 1,
                                            color: Color(0xffD3D2D2))),
                                    color: Colors.transparent,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 160,
                                  width: 300,
                                  padding: EdgeInsets.zero,
                                  scrollPadding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: const Color(0xffA19E9E)),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -10),
                                  scrollbarTheme: ScrollbarThemeData(
                                    // radius: const Radius.circular(40),
                                    // thickness:
                                    //     MaterialStateProperty.all<double>(4),
                                    thumbVisibility:
                                        MaterialStateProperty.all(false),
                                    trackVisibility:
                                        MaterialStateProperty.all(false),
                                  ),
                                  elevation: 0,
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  customHeights: _getCustomItemsHeights(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Column(
                        children: [
                          accountButtonWidget(
                              '바로 발송하기',
                              const Color(0xFFE20529),
                              Colors.transparent,
                              Colors.white,
                              () {}),
                          accountButtonWidget(
                            '취소하기',
                            Colors.transparent,
                            const Color(0xFF726E6E),
                            const Color(0xff726E6E),
                            () {},
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '현재 작성한 정보를 기본 계좌정보로 저장합니다.',
                            style: TextStyle(
                              color: Color(0xff726E6E),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Checkbox(
                            overlayColor: MaterialStateProperty.all(
                                const Color(0xffBEBCBC)),
                            value: saveBankAccount,
                            splashRadius: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                              side: const BorderSide(
                                color: Color(0xffBEBCBC),
                                width: 1,
                              ),
                            ),
                            activeColor: const Color(0xffBEBCBC),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return const Color(0xFFE20529);
                                }
                                return Colors.white;
                              },
                            ),
                            checkColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                saveBankAccount = !saveBankAccount;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 계좌 정보 전송
  void sendBankAccount(BuildContext context) async {
    final bankAccountName = await storage.read(key: 'bankAccountName');
    final bankAccountNumber = await storage.read(key: 'bankAccountNumber');

    // 이미 등록된 계좌가 존재하는 경우
    if (bankAccountName != null && bankAccountNumber != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              '이미 계좌 정보가 존재합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff302E2E),
              ),
            ),
            content: const Text(
              '해당 정보를 구매자에게 발송하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // Use minimum space required by children
                children: [
                  Text(
                    '$bankAccountNumber $bankAccountName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff302E2E),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.red[600]!; // Color when pressed
                                }
                                return const Color(0xFFE20529); // Regular color
                              },
                            ),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          child: const Text('발송하기'),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.red[600]!; // Color when pressed
                                }
                                return Colors.transparent; // Regular color
                              },
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFFE20529)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: const BorderSide(
                                      color: Color(0xFFE20529))),
                            ),
                          ),
                          child: const Text('새로작성'),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                // if (states.contains(MaterialState.pressed)) {
                                //   return Colors.red[600]!; // Color when pressed
                                // }
                                return Colors.transparent; // Regular color
                              },
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF726E6E)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: const BorderSide(
                                      color: Color(0xFF726E6E))),
                            ),
                          ),
                          child: const Text('취소하기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
      );
    }
    // 등록된 계좌가 없는 경우
    else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('작성된 계좌 정보가 없습니다!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff302E2E))),
          content: const Text(
            '계좌 정보를 입력하시겠어요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff302E2E),
            ),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    accountButtonWidget('작성하기', const Color(0xFFE20529),
                        Colors.transparent, Colors.white, () {
                      setBankAccount(context);
                    }),
                    accountButtonWidget(
                      '취소하기',
                      Colors.transparent,
                      const Color(0xFF726E6E),
                      const Color(0xff726E6E),
                      () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future getImageFromCamera(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    final ImagePicker picker = ImagePicker();
    final List<String> imageList = <String>[];

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedImage =
            await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null) {
          String imagePath = pickedImage.path;

          setState(() {
            imageList.add(imagePath);
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      // 나중에 ios는 cupertino로 바꿔줄 필요 있음
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text("사진 권한 필요"),
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

  Widget accountButtonWidget(String text, Color btnColor, Color borderColor,
      Color textColor, VoidCallback onTap) {
    return SizedBox(
      width: 300,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
          onTap();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return btnColor;
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: borderColor)),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isOptionOn ? widget.keyboardHeight : 0,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              optionCircleWidget(Icons.camera_alt_outlined, '카메라', () {
                getImageFromCamera(context);
              }),
              optionCircleWidget(Icons.image_outlined, '앨범', () {}),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              optionCircleWidget(Icons.credit_card_outlined, '거래정보 발송', () {
                sendBankAccount(context);
              }),
              optionCircleWidget(Icons.vpn_key_outlined, '사물함 정보 발송', () {}),
            ],
          ),
          // option box가 정중앙에 있으면 살짝 아래에 있는 느낌이 들어서 추가한 위젯
          const SizedBox(
            height: 15,
          )
        ],
      )),
    );
  }
}

Widget optionCircleWidget(IconData icon, String iconText, Function onTap) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
    child: Column(
      children: [
        GestureDetector(
          onTap: () {
            onTap();
          },
          child: Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xffE83754),
              borderRadius: BorderRadius.all(
                Radius.circular(36),
              ),
            ),
            child: Icon(
              icon,
              size: 33,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          iconText,
          style: const TextStyle(
            color: Color(0xff302E2E),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    ),
  );
}
