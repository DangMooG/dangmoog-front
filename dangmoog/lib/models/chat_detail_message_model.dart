class ChatDetailMessageModel {
  final bool isMine;
  final String message;
  final bool read;
  final DateTime createTime;

  ChatDetailMessageModel({
    required this.isMine,
    required this.message,
    required this.read,
    required this.createTime,
  });

  factory ChatDetailMessageModel.fromJson(
      Map<String, dynamic> json, bool imBuyer) {
    int isFromBuyer = json["is_from_buyer"];
    bool isMine = false;
    if (isFromBuyer == 1 && imBuyer) {
      isMine = true;
    } else if (isFromBuyer == 0 && !imBuyer) {
      isMine = true;
    } else {
      isMine = false;
    }

    return ChatDetailMessageModel(
      isMine: isMine,
      message: json["content"],
      read: json["read"] == 1,
      createTime: DateTime.parse(json["create_time"]),
    );
  }
}
