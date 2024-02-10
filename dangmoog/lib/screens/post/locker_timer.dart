import 'dart:async';
import 'package:dangmoog/screens/addpage/locker_val.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/models/product_class.dart';

// Define an enum for timer states
enum TimerState { loading, active, completed }

class ProductTimer extends StatefulWidget {

  final ProductModel product;
  final Widget Function(BuildContext, ProductModel) buildProductImage;
  final Widget Function(BuildContext, ProductModel) buildProductDetails;
  final VoidCallback onRemove;
  const ProductTimer({
    Key? key,
    required this.product,
    required this.buildProductImage,
    required this.buildProductDetails,
    required this.onRemove
  }) : super(key: key);

  @override
  _ProductTimerState createState() => _ProductTimerState();
}

class _ProductTimerState extends State<ProductTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration();
  TimerState _timerState = TimerState.loading;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft(); // Update time left immediately
    _startTimer();
  }

  void _updateTimeLeft() {
    final currentTime = DateTime.now();
    final targetTime = widget.product.createTime.add(const Duration(minutes: 15));
    final difference = targetTime.difference(currentTime);

    if (difference < Duration(seconds: -1)) {
      _timerState = TimerState.completed;
    } else {
      _timerState = TimerState.active;
      _timeLeft = difference;
    }
  }


  void _startTimer() {
    final targetTime = widget.product.createTime.add(const Duration(minutes: 15));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final difference = targetTime.difference(currentTime);

      if (difference < Duration(seconds: -1)) {
        _timer.cancel();
        // widget.onTimerEnd();
        if (mounted) {
          setState(() {
            _timerState = TimerState.completed;
          });
        }
      } else {
        if (_timerState == TimerState.loading && mounted) {
          setState(() {
            _timerState = TimerState.active;
          });
        }
        if (mounted) {
          setState(() {
            _timeLeft = difference;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 0.042;
    String text = _timerState == TimerState.completed
        ? '시간이 모두 경과되었습니다. 거래를 다시 진행하려면 게시글을 새로 등록해주세요!'
        : '앗! 아직 인증하지 않은 게시물이 있어요.\n인증을 진행하고 게시물을 업로드하시겠어요?';

    Color borderColor = _timerState == TimerState.completed ? const Color(
        0xFF726E6E) : const Color(0xFFE20529);
    Color backgroundColor = _timerState == TimerState.completed ? const Color(
        0xFFF1F1F1) : const Color(0xFFFCE6EA);
    Color buttonColor = _timerState == TimerState.completed ? const Color(
        0xFFA19E9E) : const Color(0xFFE20529);

    return Padding(
      padding: EdgeInsets.all(paddingValue),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                //background: #A19E9E; //validation border
                width: 2.0, // Thickness of the validation border
              ),
              borderRadius: BorderRadius.circular(8), // Border radius
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    color: backgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:const  EdgeInsets.all(8.0),
                            child: Text(
                              text,
                              style: const  TextStyle(
                                color: Color(0xFF726E6E),
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: _timerState == TimerState.completed ? () {
                              // Navigate to LockerValPage
                              // apiService.deletePost(product.postId);
                              widget.onRemove(); // Use the callback here
                              // Navigator.pop(context);
                            } : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LockerValPage(widget.product),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: buttonColor,
                              // Button background color // when time's up, the button background should be transparent, but the border of the button's color is background: #A19E9E;

                              primary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    6), // Border radius of the button
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            child: _timerState == TimerState.completed ? const Row(
                              children: [
                                Text('삭제'),
                              ],
                            ) :
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Text('인증하기'), //'삭제'
                                ),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.5, // Reduced opacity as per the original code
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.buildProductImage(context, widget.product),
                        widget.buildProductDetails(context, widget.product),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: paddingValue,
            right: paddingValue,
            child:
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.alarm, size: 16, color: borderColor),
                  ),
                  TextSpan(
                    text: _timerState == TimerState.completed ? " 앗, 15분이 모두 경과되었어요!" : " ${formatDuration(_timeLeft)} 남았습니다!",
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // ProductTimer(
            //     createTime: widget.createTime,
            //     onTimerEnd: () {
            //       product.isTimeEnded = true;
            //       product.notifyListeners();
            //     }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

//   return
// }



String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes분 $seconds초";
}

// ... rest of the GlobalTimerManager code ...

//
// class GlobalTimerManager {
//   static final GlobalTimerManager _instance = GlobalTimerManager._internal();
//
//   factory GlobalTimerManager() {
//     return _instance;
//   }
//
//   GlobalTimerManager._internal();
//
//   late Timer _timer;
//   Duration _timeLeft = Duration();
//   DateTime? _targetTime;
//
//   void startTimer(DateTime createTime) {
//     if (_targetTime == null) {
//       _targetTime = createTime.add(Duration(minutes: 15));
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         final currentTime = DateTime.now();
//         final difference = _targetTime!.difference(currentTime);
//
//         if (difference.isNegative) {
//           _timer.cancel();
//           // Handle the event when the time is up
//         } else {
//           _timeLeft = difference;
//         }
//       });
//     }
//   }
//
//   Duration get timeLeft => _timeLeft;
//
//   void dispose() {
//     _timer.cancel();
//   }
// }