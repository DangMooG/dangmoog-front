// class ChatDetailModel {
//   final ChatDetailInfo chatInfo;
//   final List<ChatDetailContent> chatContents;

//   ChatDetailModel({required this.chatInfo, required this.chatContents});

//   factory ChatDetailModel.fromJson(Map<String, dynamic> json) {
//     return ChatDetailModel(
//       chatInfo: ChatDetailInfo.fromJson(json['chatInfo']),
//       chatContents: (json['chatContents'] as List)
//           .map((e) => ChatDetailContent.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }

// class ChatDetailInfo {
//   final String userNickName;
//   // final String userPhotoUrl;
//   final int chatId;
//   final int productId;
//   final int userId;
//   final String postTitle;
//   final int dealStatus;
//   final int productPrice;
//   final String productPhotoUrl;

//   ChatDetailInfo({
//     required this.userNickName,
//     // required this.userPhotoUrl,
//     required this.chatId,
//     required this.productId,
//     required this.userId,
//     required this.postTitle,
//     required this.dealStatus,
//     required this.productPrice,
//     required this.productPhotoUrl,
//   });

//   factory ChatDetailInfo.fromJson(Map<String, dynamic> json) {
//     return ChatDetailInfo(
//       userNickName: json['userNickName'],
//       // userPhotoUrl: json['userPhotoUrl'] ?? 0,
//       chatId: json['chatId'],
//       productId: json['productId'],
//       userId: json['userId'],
//       postTitle: json['postTitle'],
//       dealStatus: json['dealStatus'],
//       productPrice: json['productPrice'],
//       productPhotoUrl: json['productPhotoUrl'],
//     );
//   }
// }

// class ChatDetailContent {
//   final DateTime chatDateTime;
//   final String chatText;
//   final bool isMe;

//   ChatDetailContent({
//     required this.chatDateTime,
//     required this.chatText,
//     required this.isMe,
//   });

//   factory ChatDetailContent.fromJson(Map<String, dynamic> json) {
//     return ChatDetailContent(
//       chatDateTime: DateTime.parse(json['chatDateTime']),
//       chatText: json['chatText'],
//       isMe: json['isMe'],
//     );
//   }
// }
