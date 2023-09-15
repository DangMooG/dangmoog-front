// import 'package:dangmoog/models/product_list_model.dart';
import 'package:flutter/material.dart';

class LikeChatCount extends StatelessWidget {
  final dynamic product;
  const LikeChatCount({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: Color(0xffA19E9E),
              size: 15,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              product.likeCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Color(0xffA19E9E),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.forum_outlined,
              color: Color(0xffA19E9E),
              size: 15,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              product.chatCount.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Color(0xffA19E9E),
              ),
            ),
          ],
        )
      ],
    );
  }
}
