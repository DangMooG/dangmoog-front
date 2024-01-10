import 'package:dangmoog/providers/chat_provider.dart';
import 'package:dangmoog/providers/chat_setting_provider.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dangmoog/utils/time_ago.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dangmoog/screens/chat/chat_detail/chat_detail_page.dart';
import 'package:provider/provider.dart';

class ChatCell extends StatefulWidget {
  final String roomId;
  final String userName;
  final String? userProfileUrl;
  final int photoId;
  final String lastMessage;
  final DateTime updateTime;
  final int unreadCount;
  final bool imBuyer;
  final int postId;

  const ChatCell({
    super.key,
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

  @override
  State<ChatCell> createState() => _ChatCellState();
}

class _ChatCellState extends State<ChatCell> {
  late String roomId;
  late String userName;
  late String? userProfileUrl;
  late int photoId;
  late String lastMessage;
  late DateTime updateTime;
  late int unreadCount;
  late bool imBuyer;
  late int postId;

  String? photoUrl;

  @override
  void initState() {
    setState(() {
      roomId = widget.roomId;
      userName = widget.userName;
      userProfileUrl = widget.userProfileUrl;
      photoId = widget.photoId;
      lastMessage = widget.lastMessage;
      updateTime = widget.updateTime;
      unreadCount = widget.unreadCount;
      imBuyer = widget.imBuyer;
      postId = widget.postId;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (photoId != 0) {
        getPhotoUrl();
      }
    });

    super.initState();
  }

  void getPhotoUrl() async {
    Response response = await ApiService().getOnePhoto(photoId);
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          photoUrl = response.data["url"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<ChatProvider>(context, listen: false).setRoomId(roomId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => ChatSettingProvider(),
              child: ChatDetail(
                imBuyer: imBuyer,
                postId: postId,
                roomId: roomId,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 2,
        ),
        child: SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipOval(
                child: userProfileUrl == null
                    ? const Image(
                        image: AssetImage('assets/images/basic_profile.png'),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        userProfileUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 11, right: 11),
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(userName),
                            const Text(' ∙ '),
                            Text(timeAgoTilWeek(updateTime)),
                          ],
                        ),
                        Text(
                          lastMessage,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: unreadCount != 0
                    ? ClipOval(
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xffE83754),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // const Image(
              //   image: AssetImage('assets/images/temp_product_img.png'),
              //   height: 48,
              // ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.5,
                    color: const Color(0xffD3D2D2),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: photoId == 0 || photoUrl == null
                    ? const Image(
                        image: AssetImage('assets/images/basic_profile.png'),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        photoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
