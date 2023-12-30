import 'package:flutter/material.dart';

class ChatDealStatus extends StatefulWidget {
  final int currentStatus;
  const ChatDealStatus({
    super.key,
    required this.currentStatus,
  });

  @override
  State<ChatDealStatus> createState() => _ChatDealStatusState();
}

class _ChatDealStatusState extends State<ChatDealStatus> {
  late int currentStatuts;

  List<String> dealStatusList = ["거래중", "예약중", "거래완료"];

  Color buttonColor = const Color(0xffE20529);

  @override
  void initState() {
    setState(() {
      currentStatuts = widget.currentStatus;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                  mainAxisSize:
                      MainAxisSize.min, // Use minimum space that content needs
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
                        _buildAlertDialogActionButton('판매중', () {
                          Navigator.of(context).pop();
                        }, false),
                        const Divider(
                          height: 0,
                          color: Color(0xffA19E9E),
                        ),
                        _buildAlertDialogActionButton('예약중', () {
                          Navigator.of(context).pop();
                        }, false),
                        const Divider(
                          height: 0,
                          color: Color(0xffA19E9E),
                        ),
                        _buildAlertDialogActionButton('판매완료', () {
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
      },
      child: Container(
        padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: buttonColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dealStatusList[currentStatuts],
              style: TextStyle(
                color: buttonColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_sharp,
              color: buttonColor,
            ),
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
