import 'package:intl/intl.dart';

String convertMoneyFormat(int money) {
  return NumberFormat('###,###,###원', 'ko_KR').format(money);
}
