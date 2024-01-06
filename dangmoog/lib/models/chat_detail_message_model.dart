class ChatDetailMessageModel {
  final int messageId;
  final bool fromBuyer;
  final String message;
  final bool read;
  final DateTime createTime;

  ChatDetailMessageModel({
    required this.messageId,
    required this.fromBuyer,
    required this.message,
    required this.read,
    required this.createTime,
  });

  factory ChatDetailMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatDetailMessageModel(
      messageId: json["message_id"],
      fromBuyer: bool.parse(json["is_from_buyer"]),
      message: json["content"],
      read: bool.parse(json["read"]),
      createTime: DateTime.parse(json["create_time"]),
    );
  }
}
