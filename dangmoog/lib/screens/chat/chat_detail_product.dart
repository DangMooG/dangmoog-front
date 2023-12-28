import 'package:dangmoog/models/chat_detail_model.dart';
import 'package:dangmoog/screens/chat/chat_deal_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailProduct extends StatefulWidget {
  final Future<ChatDetailModel> futureChatDetail;

  const ChatDetailProduct({super.key, required this.futureChatDetail});

  @override
  State<ChatDetailProduct> createState() => _ChatDetailProductState();
}

class _ChatDetailProductState extends State<ChatDetailProduct> {
  late Future<ChatDetailModel> futureChatDetail;

  @override
  void initState() {
    super.initState();
    futureChatDetail = widget.futureChatDetail;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFD3D2D2),
            style: BorderStyle.solid,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FutureBuilder<ChatDetailModel>(
        future: futureChatDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading chat list!'),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      image:
                          AssetImage(snapshot.data!.chatInfo.productPhotoUrl),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          snapshot.data!.chatInfo.postTitle,
                          style: const TextStyle(
                            color: Color(0xFF302E2E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat('###,###,###원', 'ko_KR')
                              .format(snapshot.data!.chatInfo.productPrice),
                          style: const TextStyle(
                            color: Color(0xFF302E2E),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const ChatDealStatus()
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
