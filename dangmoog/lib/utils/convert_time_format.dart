String convertTimeFormat(DateTime time) {
  int hour = time.hour;
  String period = hour < 12 ? "오전" : "오후";
  if (hour > 12) hour -= 12;
  String minute = time.minute.toString().padLeft(2, "0");
  return '$period $hour:$minute';
}
