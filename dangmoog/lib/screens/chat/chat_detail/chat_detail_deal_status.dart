// ignore_for_file: use_build_context_synchronously

import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/services/api.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatDealStatus extends StatefulWidget {
  // final int currentStatus;
  final bool imBuyer;
  final int postId;
  String? roomId;

  ChatDealStatus({
    super.key,
    // required this.currentStatus,
    required this.imBuyer,
    required this.postId,
    this.roomId,
  });

  @override
  State<ChatDealStatus> createState() => _ChatDealStatusState();
}

class _ChatDealStatusState extends State<ChatDealStatus> {
  // int? currentStatuts;

  List<String> dealStatusList = ["거래중", "예약중", "거래완료"];

  List<Color> buttonColorList = [
    const Color(0xffE20529),
    const Color(0xffF28C9D),
    const Color(0xff726E6E),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // setState(() {
      //   currentStatuts =
      //       Provider.of<ChatProvider>(context, listen: false).dealStatus;
      // });
    });
    super.initState();
  }

  void changePostDealStatus(int nextStatus) async {
    Size screenSize = MediaQuery.of(context).size;
    if (nextStatus == 2) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            surfaceTintColor: Colors.transparent,
            titlePadding: const EdgeInsets.only(top: 24),
            title: const Text(
              '거래가 완료되셨나요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF302E2E),
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 8),
            content: const Text(
              '거래완료를 누르게 되면 다시 판매중이나\n예약중 상태로 되돌릴 수 없습니다.\n거래가 완료되셨다면 클릭해주세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF302E2E),
              ),
            ),
            actionsPadding:
                const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
            actions: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final roomId =
                            Provider.of<ChatProvider>(context, listen: false)
                                .roomId;
                        final response =
                            await ApiService().setDoneDeal(roomId!);
                        if (response.statusCode == 200) {
                          Provider.of<ChatProvider>(context, listen: false)
                              .setDealStatus(2);
                        }
                      } catch (e) {
                        print(e);
                      }
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
                        40,
                      ),
                    ),
                    child: const Text(
                      "거래완료",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
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
                        40,
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
            ],
          );
        },
      );
    } else {
      try {
        final response =
            await ApiService().changeDealStatus(nextStatus, widget.postId);
        if (response.statusCode == 200) {
          // setState(() {
          //   currentStatuts = nextStatus;
          // });
          Provider.of<ChatProvider>(context, listen: false)
              .setDealStatus(nextStatus);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: true);
    return GestureDetector(
      onTap: () {
        if (!widget.imBuyer && chatProvider.dealStatus == 2) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
                surfaceTintColor: Colors.transparent,
                titlePadding: const EdgeInsets.only(top: 24),
                title: const Text(
                  '거래가 완료된 게시글입니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF302E2E),
                  ),
                ),
                contentPadding: const EdgeInsets.only(top: 8),
                content: const Text(
                  '거래완료 상태는 다시 판매중이나 예약중\n상태로 되돌릴 수 없습니다. 다시 거래를\n원하신다면 게시글을 새로 업로드해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF302E2E),
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                actions: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
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
                            40,
                          ),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF726E6E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        } else if (!widget.imBuyer && chatProvider.dealStatus != 2) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  padding: const EdgeInsets.all(0),
                  width: double
                      .infinity, // Set to double.infinity to take full width within constraints
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Use minimum space that content needs
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "거래상태를 변경합니다",
                        style: TextStyle(
                          color: Color(0xff302E2E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '변경하실 경매 구매자에게도\n변경된 판매상태로 보여집니다.',
                        style: TextStyle(
                          color: Color(0xff302E2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('거래중', () {
                            changePostDealStatus(0);
                            Navigator.of(context).pop();
                          }, false),
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('예약중', () {
                            changePostDealStatus(1);
                            Navigator.of(context).pop();
                          }, false),
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('거래완료', () {
                            Navigator.of(context).pop();
                            changePostDealStatus(2);
                          }, false),
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('취소', () {
                            Navigator.of(context).pop();
                          }, true),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(
              color: buttonColorList[chatProvider.dealStatus!], width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              dealStatusList[chatProvider.dealStatus!],
              style: TextStyle(
                color: buttonColorList[chatProvider.dealStatus!],
              ),
            ),
            !widget.imBuyer
                ? Container(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: buttonColorList[chatProvider.dealStatus!],
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

Widget _buildAlertDialogActionButton(
    String buttonText, VoidCallback onPressed, bool isCancel) {
  return SizedBox(
    height: 48,
    child: ButtonTheme(
      minWidth: double.infinity,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isCancel ? const Color(0xff726E6E) : const Color(0xffE20529),
          ),
        ),
      ),
    ),
  );
}
