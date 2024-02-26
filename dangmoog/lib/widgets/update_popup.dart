import 'package:upgrader/upgrader.dart';

class MyUpgraderMessages extends UpgraderMessages {
  @override
  String get title => '최신 버전 업데이트';

  @override
  String get body => "새로운 버전이 출시되었어요!";

  @override
  String get buttonTitleUpdate => "업데이트하기";

  @override
  String get prompt => '더 나은 사용자 경험을 위해 지금 \n앱을 업데이트 해주세요.';
}
