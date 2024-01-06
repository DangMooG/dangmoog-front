class ChatListCell {
  String roomId;
  String userName;
  String? userProfileUrl;
  int photoId;
  String lastMessage;
  DateTime updateTime;
  int unreadCount;
  bool imBuyer;
  int postId;

  ChatListCell({
    required this.roomId,
    required this.userName,
    required this.userProfileUrl,
    required this.photoId,
    required this.lastMessage,
    required this.updateTime,
    required this.unreadCount,
    required this.imBuyer,
    required this.postId,
  });
}
