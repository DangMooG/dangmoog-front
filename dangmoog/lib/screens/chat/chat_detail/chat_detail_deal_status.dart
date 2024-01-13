import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChatDealStatus extends StatefulWidget {
  final int currentStatus;
  final bool imBuyer;
  final int postId;
  const ChatDealStatus({
    super.key,
    required this.currentStatus,
    required this.imBuyer,
    required this.postId,
  });

  @override
  State<ChatDealStatus> createState() => _ChatDealStatusState();
}

class _ChatDealStatusState extends State<ChatDealStatus> {
  late int currentStatuts;

  List<String> dealStatusList = ["거래중", "예약중", "거래완료"];

  List<Color> buttonColorList = [
    const Color(0xffE20529),
    const Color(0xffE20529),
    const Color(0xff726E6E)
  ];

  @override
  void initState() {
    setState(() {
      currentStatuts = widget.currentStatus;
    });
    super.initState();
  }

  void changePostDealStatus(int nextStatus) async {
    try {
      await ApiService().changeDealStatus(nextStatus, widget.postId);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.imBuyer) {
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
                            setState(() {
                              currentStatuts = 0;
                            });
                            Navigator.of(context).pop();
                          }, false),
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('예약중', () {
                            changePostDealStatus(1);
                            setState(() {
                              currentStatuts = 1;
                            });
                            Navigator.of(context).pop();
                          }, false),
                          const Divider(
                            height: 0,
                            color: Color(0xffA19E9E),
                          ),
                          _buildAlertDialogActionButton('판매완료', () {
                            changePostDealStatus(2);
                            setState(() {
                              currentStatuts = 2;
                            });
                            Navigator.of(context).pop();
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
          border: Border.all(color: buttonColorList[currentStatuts], width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              dealStatusList[currentStatuts],
              style: TextStyle(
                color: buttonColorList[currentStatuts],
              ),
            ),
            !widget.imBuyer
                ? Container(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: buttonColorList[currentStatuts],
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
