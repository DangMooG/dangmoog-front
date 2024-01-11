import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductTimer extends StatefulWidget {
  final DateTime createTime;

  const ProductTimer({Key? key, required this.createTime}) : super(key: key);

  @override
  _ProductTimerState createState() => _ProductTimerState();
}

class _ProductTimerState extends State<ProductTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration();


  @override
  void initState() {
    super.initState();
    _startTimer();
  }


  void _startTimer() {
    print(widget.createTime);
    final targetTime = widget.createTime.add(const Duration(minutes: 15));
    // print(targetTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final difference = targetTime.difference(currentTime);

      if (difference.isNegative) {
        _timer.cancel();
        // Handle the event when the time is up
      } else {
        setState(() {
          _timeLeft = difference;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const WidgetSpan(
            child: Icon(Icons.alarm, size: 16, color: Color(0xFFE20529)), // Alert icon
          ),
          TextSpan(
            text: " ${formatDuration(_timeLeft)} 남았습니다!", // Timer text
            style: const TextStyle(
              color: Color(0xFFE20529),
              fontWeight: FontWeight.w500,
            ),
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

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  // final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes분 $seconds초";
}

class GlobalTimerManager {
  static final GlobalTimerManager _instance = GlobalTimerManager._internal();

  factory GlobalTimerManager() {
    return _instance;
  }

  GlobalTimerManager._internal();

  late Timer _timer;
  Duration _timeLeft = Duration();
  DateTime? _targetTime;

  void startTimer(DateTime createTime) {
    if (_targetTime == null) {
      _targetTime = createTime.add(Duration(minutes: 15));
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        final currentTime = DateTime.now();
        final difference = _targetTime!.difference(currentTime);

        if (difference.isNegative) {
          _timer.cancel();
          // Handle the event when the time is up
        } else {
          _timeLeft = difference;
        }
      });
    }
  }

  Duration get timeLeft => _timeLeft;

  void dispose() {
    _timer.cancel();
  }
}
