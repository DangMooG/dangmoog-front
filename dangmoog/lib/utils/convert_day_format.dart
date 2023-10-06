import 'package:intl/intl.dart';

String convertDayFormat(DateTime dateTime) {
  return DateFormat('y년 M월 d일').format(dateTime);
}
