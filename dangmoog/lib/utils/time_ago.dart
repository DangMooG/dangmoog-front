String timeAgo(DateTime date) {
  Duration diff = DateTime.now().difference(date);

  int years = (diff.inDays / 365).floor();
  int months = (diff.inDays / 30).floor();
  int weeks = (diff.inDays / 7).floor();

  if (years > 0) {
    return '$years년 전';
  } else if (months > 0) {
    return '$months개월 전';
  } else if (weeks > 0) {
    return '$weeks주일 전';
  } else if (diff.inDays > 0) {
    return '${diff.inDays}일 전';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}시간 전';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}분 전';
  } else {
    return '방금 전';
  }
}

String timeAgoTilWeek(DateTime date) {
  Duration diff = DateTime.now().difference(date);

  // 'yyyy.MM.dd' 형식으로 날짜 포매팅
  String formattedDate =
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  int weeks = (diff.inDays / 7).floor();

  if (weeks > 1) {
    // 7일을 초과하는 경우 날짜를 'yyyy.MM.dd' 형식으로 반환
    return formattedDate;
  } else if (diff.inDays > 0) {
    return '${diff.inDays}일 전';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}시간 전';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}분 전';
  } else {
    return '방금 전';
  }
}
