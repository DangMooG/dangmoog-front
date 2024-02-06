import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/chat/chat_detail/chat_detail_deal_status.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailProduct extends StatefulWidget {
  // final Future<ChatDetailModel> futureChatDetail;
  final ProductModel product;
  final bool imBuyer;

  const ChatDetailProduct({
    super.key,
    required this.product,
    required this.imBuyer,
  });

  @override
  State<ChatDetailProduct> createState() => _ChatDetailProductState();
}

class _ChatDetailProductState extends State<ChatDetailProduct> {
  // late Future<ChatDetailModel> futureChatDetail;
  late ProductModel product;
  String? representativePhotoUrl;

  @override
  void initState() {
    super.initState();

    product = widget.product;

    getRepresentativePhotoUrl();
  }

  void getRepresentativePhotoUrl() async {
    if (widget.product.representativePhotoId == 0) {
      return;
    }
    try {
      Response response =
          await ApiService().getOnePhoto(widget.product.representativePhotoId);

      if (response.statusCode == 200) {
        setState(() {
          representativePhotoUrl = response.data['url'];
        });
      }
    } catch (e) {
      print(e);
    }
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child:
                  representativePhotoUrl == "" || representativePhotoUrl == null
                      ? const Image(
                          image: AssetImage("assets/images/basic_profile.png"),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          representativePhotoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/sample.png',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 48),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        color: Color(0xFF302E2E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      NumberFormat('###,###,###원', 'ko_KR')
                          .format(product.price.toInt()),
                      style: const TextStyle(
                        color: Color(0xFF302E2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ChatDealStatus(
            currentStatus: product.status,
            imBuyer: widget.imBuyer,
            postId: widget.product.postId,
          )
        ],
      ),
    );
  }
}
