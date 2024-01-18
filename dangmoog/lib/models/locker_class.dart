class Locker {
  final int lockerId;
  int status; // 0 : 선택불가능, 1 : 선택가능
  final int? postId;
  final int? accountId;
  final String name;
  final String createTime;
  final String updateTime;

  Locker({
    required this.lockerId,
    required this.status,
    this.postId,
    this.accountId,
    required this.name,
    required this.createTime,
    required this.updateTime,
  });

  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      lockerId: json['locker_id'],
      status: json['status'],
      postId: json['post_id'],
      accountId: json['account_id'],
      name: json['name'],
      createTime: json['create_time'],
      updateTime: json['update_time'],
    );
  }
}
