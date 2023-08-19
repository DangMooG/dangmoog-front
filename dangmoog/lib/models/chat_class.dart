class Chat {
  final String userNickName;
  final String lastMsg;
  final int productId;
  final int userId;
  final int chatId;
  final DateTime lastDate;

  Chat({
    required this.userNickName,
    required this.lastMsg,
    required this.productId,
    required this.userId,
    required this.chatId,
    required this.lastDate,
  });
}
