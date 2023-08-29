class ChatDetailModel {
  final ChatInfo chatInfo;
  final List<ChatContent> chatContents;

  ChatDetailModel({required this.chatInfo, required this.chatContents});

  factory ChatDetailModel.fromJson(Map<String, dynamic> json) {
    return ChatDetailModel(
      chatInfo: ChatInfo.fromJson(json['chatInfo']),
      chatContents: (json['chatContents'] as List)
          .map((e) => ChatContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatInfo {
  final String userNickName;
  final String userPhotoUrl;
  final int chatId;
  final int productId;
  final int userId;
  final String postTitle;
  final int dealStatus;
  final int productPrice;
  final String productPhotoUrl;

  ChatInfo({
    required this.userNickName,
    required this.userPhotoUrl,
    required this.chatId,
    required this.productId,
    required this.userId,
    required this.postTitle,
    required this.dealStatus,
    required this.productPrice,
    required this.productPhotoUrl,
  });

  factory ChatInfo.fromJson(Map<String, dynamic> json) {
    return ChatInfo(
      userNickName: json['userNickName'],
      userPhotoUrl: json['userPhotoUrl'],
      chatId: json['chatId'],
      productId: json['productId'],
      userId: json['userId'],
      postTitle: json['postTitle'],
      dealStatus: json['dealStatus'],
      productPrice: json['productPrice'],
      productPhotoUrl: json['productPhotoUrl'],
    );
  }
}

class ChatContent {
  final DateTime chatDateTime;
  final String chatText;
  final bool isMe;

  ChatContent({
    required this.chatDateTime,
    required this.chatText,
    required this.isMe,
  });

  factory ChatContent.fromJson(Map<String, dynamic> json) {
    return ChatContent(
      chatDateTime: DateTime.parse(json['chatDateTime']),
      chatText: json['chatText'],
      isMe: json['isMe'],
    );
  }
}
