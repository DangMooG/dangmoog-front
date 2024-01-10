import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductTimer extends StatefulWidget {
  final DateTime updateTime;

  const ProductTimer({Key? key, required this.updateTime}) : super(key: key);

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
    final fifteenMinutes = Duration(minutes: 15);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final difference = fifteenMinutes - currentTime.difference(widget.updateTime);

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
          WidgetSpan(
            child: Icon(Icons.alarm, size: 16, color: Color(0xFFE20529)), // Alert icon
          ),
          TextSpan(
            text: " ${formatDuration(_timeLeft)} 남았습니다!", // Timer text
            style: TextStyle(
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
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}
