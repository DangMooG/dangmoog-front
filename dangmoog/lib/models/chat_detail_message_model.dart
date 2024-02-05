import 'dart:convert';

typedef StringOrListOfString = dynamic;

class ChatDetailMessageModel {
  final bool isMine;
  final StringOrListOfString message;
  final bool read;
  final DateTime createTime;
  final bool isImage;

  ChatDetailMessageModel({
    required this.isMine,
    required this.message,
    required this.read,
    required this.createTime,
    required this.isImage,
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

    final isImage = json['content'] is List<dynamic>;

    return ChatDetailMessageModel(
      isMine: isMine,
      message: json["content"],
      read: json["read"] == 1,
      createTime: DateTime.parse(json["create_time"]),
      isImage: isImage,
    );
  }
}
