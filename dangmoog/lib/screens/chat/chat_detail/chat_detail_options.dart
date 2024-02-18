// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:io';

import 'package:dangmoog/constants/locker_location_url.dart';
import 'package:dangmoog/models/chat_detail_message_model.dart';
import 'package:dangmoog/providers/chat_list_provider.dart';
import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/socket_provider.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/utils/compress_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dangmoog/constants/account_list.dart';
import 'package:dangmoog/widgets/bottom_popup.dart';

// plugins
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatDetailOptions extends StatefulWidget {
  final bool isOptionOn;
  final double keyboardHeight;
  final String? roomId;
  final Function(String) setRoomId;

  final int? useLocker; // 0은 사용 안함, 1은 사용함

  const ChatDetailOptions({
    required this.isOptionOn,
    required this.keyboardHeight,
    required this.useLocker,
    required this.roomId,
    required this.setRoomId,
    super.key,
  });

  @override
  State<ChatDetailOptions> createState() => _ChatDetailOptionsState();
}

class _ChatDetailOptionsState extends State<ChatDetailOptions> {
  String? roomId;
  bool? imBuyer;
  int? postId;

  static const storage = FlutterSecureStorage();

  bool saveBankAccount = true;

  late SocketProvider socketChannel;

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
              value: null,
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
    for (int i = 0; i < (bankNameList.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  Future<void> setDealDone() async {
    try {
      final response = await ApiService().setDoneDeal(widget.roomId!);
      if (response.statusCode == 200) {
        Provider.of<ChatProvider>(context, listen: false).setDealStatus(2);
      }
    } catch (e) {
      print(e);
    }
  }

  void setBankAccount(BuildContext context) async {
    Future<void> _saveAccount(String accountNumber, String bankName) async {
      try {
        await ApiService().uploadBank(bankName, accountNumber);
      } catch (e) {
        print(e);
      }

      await storage.write(key: 'bankName', value: bankName);
      await storage.write(key: 'accountNumber', value: accountNumber);
    }

    String typedAccountNumber = "";
    String? selectedBankName;

    bool isAccountNumberFormatOkay = false;
    bool isBankNameSelected = false;

    bool isSubmitButtonActive = false;

    bool errorMessageVisible = false;
    String accountNumberErrorMessage = "계좌번호의 길이가 올바르지 않습니다.";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateFormatState() {
              if (isAccountNumberFormatOkay == true &&
                  isBankNameSelected == true) {
                if (isSubmitButtonActive == false) {
                  setState(() {
                    isSubmitButtonActive = true;
                  });
                }
              } else {
                if (isSubmitButtonActive == true) {
                  setState(() {
                    isSubmitButtonActive = false;
                  });
                }
              }
            }

            void onAccountNumberChanged(String value) {
              setState(() {
                typedAccountNumber = value;
              });

              if (value.length >= 10 && value.length <= 14) {
                if (isAccountNumberFormatOkay == false) {
                  setState(() {
                    isAccountNumberFormatOkay = true;
                  });
                }

                if (errorMessageVisible == true) {
                  setState(() {
                    errorMessageVisible = false;
                  });
                }
              } else {
                if (isAccountNumberFormatOkay == true) {
                  setState(() {
                    isAccountNumberFormatOkay = false;
                  });
                }

                if (errorMessageVisible == false) {
                  setState(() {
                    errorMessageVisible = true;
                  });
                }
              }

              if (value.isEmpty) {
                setState(() {
                  errorMessageVisible = false;
                });
              }

              updateFormatState();
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '새로운 계좌 정보를 입력해주세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff302E2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '은행과 계좌번호를 정확히 입력해주세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff302E2E),
                        ),
                      ),
                      widget.useLocker != 2
                          ? const SizedBox(height: 8)
                          : const SizedBox.shrink(),
                      widget.useLocker != 2
                          ? const Text(
                              '직접거래는 계좌정보를 발송할 경우\n자동으로 거래완료 처리됩니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff302E2E),
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          SizedBox(
                            width: 280,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: '계좌번호 입력(10~14자리)',
                                hintStyle: TextStyle(
                                  color: Color(0xffA19E9E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
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
                                    vertical: 10, horizontal: 8),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                              style: const TextStyle(
                                color: Color(0xff302E2E),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: onAccountNumberChanged,
                            ),
                          ),
                          errorMessageVisible
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    accountNumberErrorMessage,
                                    style: const TextStyle(
                                      color: Color(0xFFE20529),
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 8),
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
                                items: _addDividersAfterItems(bankNameList),
                                value: selectedBankName,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedBankName = value;
                                  });

                                  if (isBankNameSelected == false) {
                                    setState(() {
                                      isBankNameSelected = true;
                                    });

                                    updateFormatState();
                                  }
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
                                  width: 280,
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
                                  width: 280,
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
                              isSubmitButtonActive
                                  ? const Color(0xFFE20529)
                                  : const Color(0xffD3D2D2),
                              Colors.transparent,
                              Colors.white, () async {
                            if (isSubmitButtonActive == true) {
                              if (selectedBankName != "" &&
                                  selectedBankName != null &&
                                  typedAccountNumber != "") {
                                // 국내 은행의 계좌번호는 10~14자리
                                if (saveBankAccount) {
                                  _saveAccount(
                                      typedAccountNumber, selectedBankName!);
                                }
                              }
                              await handleTextChatSubmitted(
                                  "$selectedBankName $typedAccountNumber");
                              if (widget.useLocker == 0) {
                                await setDealDone();
                              }

                              Navigator.pop(context);
                            }
                          }),
                          accountButtonWidget(
                            '취소하기',
                            Colors.transparent,
                            const Color(0xFF726E6E),
                            const Color(0xff726E6E),
                            () {
                              Navigator.pop(context);
                            },
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 계좌 정보 전송
  void sendBankAccount(BuildContext context) async {
    final bankAccountName = await storage.read(key: 'bankName');
    final bankAccountNumber = await storage.read(key: 'accountNumber');

    // 이미 등록된 계좌가 존재하는 경우
    if (bankAccountName != null && bankAccountNumber != null) {
      final contentMessage = widget.useLocker == 2
          ? '해당 정보를 구매자에게 바로 발송하시겠어요?'
          : '직접거래는 계좌정보를 발송할 경우\n자동으로 거래완료 처리됩니다.\n해당 정보를 구매자에게 발송하시겠습니까?';

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
            content: Text(
              contentMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
            titlePadding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
            contentPadding: const EdgeInsets.only(bottom: 12.0),
            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      '$bankAccountNumber $bankAccountName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff302E2E),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextButton(
                          onPressed: () async {
                            await handleTextChatSubmitted(
                                "$bankAccountName $bankAccountNumber");
                            if (widget.useLocker == 0) {
                              await setDealDone();
                            }
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
                            setBankAccount(context);
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
                  const SizedBox(
                    height: 8,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Color(0xFF726E6E),
                        size: 16,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '운영자는 회원이 저장, 게시 또는 전송한 자료와\n관련하여 일체의 책임을 지지 않습니다.',
                        style: TextStyle(
                            color: Color(0xFF726E6E),
                            fontSize: 11,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
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
                      Navigator.pop(context);
                      setBankAccount(context);
                    }),
                    accountButtonWidget(
                      '취소하기',
                      Colors.transparent,
                      const Color(0xFF726E6E),
                      const Color(0xff726E6E),
                      () {
                        Navigator.pop(context);
                      },
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

  void sendLockerInfo(BuildContext context) async {
    Response response = await ApiService().getLockerInfo(postId!);

    if (response.statusCode == 200) {
      if (!mounted) return;

      final lockerName = response.data["name"];

      final password = response.data["password"];
      final lockerValPhotoUrl = response.data["photo_url"];
      final lockerMessage = "사물함 위치 : $lockerName, 비밀번호 : $password";

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  '사물함 정보를 발송할까요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff302E2E),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                content: const Text(
                  '사물함 정보를 발송할 경우\n자동으로 거래완료 처리됩니다.\n사물함의 정보 발송은 되돌리기 어려운 만큼\n구매자와 상의 후 신중히 발송하시기 \n바랍니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff302E2E),
                  ),
                  overflow: TextOverflow.clip,
                ),
                actions: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lockerMessage,
                        style: const TextStyle(
                          color: Color(0xff302E2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          height: 1,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          lockerValPhotoUrl!,
                          width: 208,
                          height: 208,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color(0xffD9D9D9),
                              ),
                              width: 208,
                              height: 208,
                            );
                          },
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.network(
                              lockerValPhotoUrl!,
                              width: 208,
                              height: 208,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/images/sample.png',
                                  fit: BoxFit.cover,
                                  width: 208,
                                  height: 208,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Color(0xff726E6E),
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "해당 정보는 수정할 수 없는 내용입니다!",
                            style: TextStyle(
                              color: Color(0xff726E6E),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.clip,
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
                              Colors.white, () async {
                            await sendLockerImage(lockerValPhotoUrl);

                            await handleTextChatSubmitted(lockerMessage);

                            await setDealDone();

                            Navigator.pop(context);
                          }),
                          accountButtonWidget(
                            '취소하기',
                            Colors.transparent,
                            const Color(0xFF726E6E),
                            const Color(0xff726E6E),
                            () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Widget accountButtonWidget(String text, Color btnColor, Color borderColor,
      Color textColor, VoidCallback onTap) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.9,
      child: TextButton(
        onPressed: onTap,
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

  // 한 번도 채팅을 보낸 적이 없는 채팅방일 경우, 채팅방 id를 우선 생성
  Future getRoomIdWhenFirstChat() async {
    try {
      Response response = await ApiService().getChatRoomId(postId!);
      if (response.statusCode == 200) {
        String newRoomId = response.data["room_id"];

        if (!mounted) return;
        Provider.of<ChatProvider>(context, listen: false).setRoomId(newRoomId);

        setState(() {
          roomId = newRoomId;
        });

        // widget.setRoomId(newRoomId);

        if (newRoomId != "") {
          Provider.of<SocketProvider>(context, listen: false)
              .beginChat(newRoomId);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  // 카메라로 사진 1장 전송
  Future getImageUrlFromCamera() async {
    PermissionStatus status = await Permission.camera.request();
    final ImagePicker picker = ImagePicker();

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedImage =
            await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null) {
          String imagesPath = pickedImage.path;

          File imageFile = await compressImage(File(imagesPath));

          try {
            Response response =
                await ApiService().getPhotoUrls(roomId!, [imageFile]);

            if (response.statusCode == 200) {
              final data = response.data;

              List<dynamic> photoUrls = data["content"];

              return photoUrls;
            }
          } catch (e) {
            print(e);
            return false;
          }
        }
      } catch (e) {
        print("Error picking images: $e");
        return false;
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

  // 앨범에서 이미지를 가져오는 함수
  Future getImageUrlsFromAlbum() async {
    PermissionStatus status = await Permission.photos.request();
    final ImagePicker picker = ImagePicker();

    if (status.isGranted || status.isLimited) {
      try {
        final List<XFile> pickedImages =
            await picker.pickMultiImage(imageQuality: 50);

        if (pickedImages.isNotEmpty) {
          if (pickedImages.length > 4) {
            showPopup(context, "사진 전송은 최대 4장입니다.");
            return false;
          }
          List<String> imagesPath =
              pickedImages.map((image) => image.path).toList();

          List<Future<File>> compressedImageFutures =
              imagesPath.map((path) => compressImage(File(path))).toList();

          List<File> imageFiles = await Future.wait(compressedImageFutures);

          try {
            Response response =
                await ApiService().getPhotoUrls(roomId!, imageFiles);

            if (response.statusCode == 200) {
              final data = response.data;

              List<dynamic> photoUrls = data["content"];

              return photoUrls;
            }
          } catch (e) {
            print(e);
            return false;
          }
        }
      } catch (e) {
        print("Error picking images: $e");
        return false;
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

  Future<void> handleTextChatSubmitted(String message) async {
    if (message != "" && (roomId == null || roomId == "")) {
      try {
        await getRoomIdWhenFirstChat();
      } catch (e) {
        print(e);
        return;
      }
    }

    if (message != "" && roomId != null && roomId != "") {
      await socketChannel.onSendMessage(message, null, roomId!, false);

      final currentTime = DateTime.now();
      final chatMessage = message;

      var newMessage = ChatDetailMessageModel(
          isMine: true,
          message: chatMessage,
          read: true,
          createTime: currentTime,
          isImage: false);

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.addChatContent(newMessage);

      final chatListProvider =
          Provider.of<ChatListProvider>(context, listen: false);
      if (chatListProvider.buyChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        int index = chatListProvider.buyChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);

        chatListProvider.updateChatList(
          index,
          chatMessage,
          currentTime,
          true,
        );
        chatListProvider.resetUnreadCount(index, true);
      } else if (chatListProvider.sellChatList
          .any((chatListCell) => chatListCell.roomId == roomId)) {
        int index = chatListProvider.sellChatList
            .indexWhere((chatCell) => chatCell.roomId == roomId);
        chatListProvider.updateChatList(
          index,
          chatMessage,
          currentTime,
          false,
        );
        chatListProvider.resetUnreadCount(index, false);
      } else {
        chatProvider.addNewChatList();
      }
    }
  }

  void handleImageChatSubmitted(bool fromCamera) async {
    if (roomId == null || roomId == "") {
      try {
        getRoomIdWhenFirstChat();
      } catch (e) {
        print(e);
        return;
      }
    }

    if (roomId != null && roomId != "") {
      final photoUrls = fromCamera
          ? await getImageUrlFromCamera()
          : await getImageUrlsFromAlbum();

      if (photoUrls == false) {
        return;
      }

      if (photoUrls.runtimeType == List<dynamic>) {
        // 서버로 전송
        await socketChannel.onSendMessage(null, photoUrls, roomId!, true);
        final currentTime = DateTime.now();
        final chatMessage = photoUrls;

        var newMessage = ChatDetailMessageModel(
          isMine: true,
          message: chatMessage,
          read: true,
          createTime: currentTime,
          isImage: true,
        );

        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addChatContent(newMessage);

        final chatListProvider =
            Provider.of<ChatListProvider>(context, listen: false);
        if (chatListProvider.buyChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.buyChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);

          chatListProvider.updateChatList(
            index,
            "사진",
            currentTime,
            true,
          );
          chatListProvider.resetUnreadCount(index, true);
        } else if (chatListProvider.sellChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.sellChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);
          chatListProvider.updateChatList(
            index,
            "사진",
            currentTime,
            false,
          );
          chatListProvider.resetUnreadCount(index, false);
        } else {
          chatProvider.addNewChatList();
        }
      }
    }
  }

  Future<void> sendLockerImage(String lockerPhotoUrl) async {
    if (roomId != null && roomId != "") {
      List<dynamic> photoUrls = [lockerPhotoUrl, lockerLocationImageUrl];

      if (photoUrls.runtimeType == List<dynamic>) {
        // 서버로 전송
        try {
          await socketChannel.onSendMessage(null, photoUrls, roomId!, true);
        } catch (e) {
          print(e);
        }
        final currentTime = DateTime.now();
        final chatMessage = photoUrls;

        var newMessage = ChatDetailMessageModel(
          isMine: true,
          message: chatMessage,
          read: true,
          createTime: currentTime,
          isImage: true,
        );

        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addChatContent(newMessage);

        final chatListProvider =
            Provider.of<ChatListProvider>(context, listen: false);
        if (chatListProvider.buyChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.buyChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);

          chatListProvider.updateChatList(
            index,
            "사진",
            currentTime,
            true,
          );
          chatListProvider.resetUnreadCount(index, true);
        } else if (chatListProvider.sellChatList
            .any((chatListCell) => chatListCell.roomId == roomId)) {
          int index = chatListProvider.sellChatList
              .indexWhere((chatCell) => chatCell.roomId == roomId);
          chatListProvider.updateChatList(
            index,
            "사진",
            currentTime,
            false,
          );
          chatListProvider.resetUnreadCount(index, false);
        } else {
          chatProvider.addNewChatList();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    roomId = widget.roomId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        postId = Provider.of<ChatProvider>(context, listen: false).postId;
        imBuyer = Provider.of<ChatProvider>(context, listen: false).imBuyer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    socketChannel = Provider.of<SocketProvider>(context, listen: false);

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
              optionCircleWidget(context, Icons.camera_alt_outlined, '카메라', () {
                handleImageChatSubmitted(true);
              }, true, null),
              optionCircleWidget(context, Icons.image_outlined, '앨범', () {
                handleImageChatSubmitted(false);
              }, true, null),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              optionCircleWidget(
                  context, Icons.credit_card_outlined, '계좌정보\n발송', () {
                sendBankAccount(context);
              }, !imBuyer!, "구매자는 계좌정보를 전송할 수 없습니다"),
              optionCircleWidget(context, Icons.vpn_key_outlined, '사물함 정보\n발송',
                  () {
                sendLockerInfo(context);
              },
                  widget.useLocker == 2 &&
                      !imBuyer! &&
                      Provider.of<ChatProvider>(context, listen: true)
                              .dealStatus !=
                          2,
                  !imBuyer!
                      ? "거래완료 상태의 사물함 정보를 전송할 수 없습니다"
                      : "구매자는 사물함 정보를 전송할 수 없습니다"),
            ],
          ),
        ],
      )),
    );
  }
}

Widget optionCircleWidget(BuildContext context, IconData icon, String iconText,
    Function onTap, bool isActive, String? deActiveMessag) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (isActive) {
              onTap();
            } else {
              showPopup(context, deActiveMessag!);
            }
          },
          child: Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xffE83754)
                    : const Color(0xffA19E9E),
                borderRadius: const BorderRadius.all(Radius.circular(36)),
                border: Border.all(
                  width: 2,
                  color: isActive
                      ? const Color(0xffEC5870)
                      : const Color(0xffBEBCBC),
                )),
            child: Icon(
              icon,
              size: 33,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          iconText,
          style: const TextStyle(
            color: Color(0xff302E2E),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}
