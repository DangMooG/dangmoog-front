import 'package:flutter/material.dart';

class SingleChatMessage extends StatelessWidget {
  final dynamic message;
  final bool me;
  final bool profileOmit;
  final String time;
  final bool timeOmit;
  final bool isImage;

  const SingleChatMessage({
    super.key,
    required this.message,
    required this.me,
    required this.profileOmit,
    required this.time,
    required this.timeOmit,
    required this.isImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: profileOmit ? 4 : 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              me ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: me
              ? <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      timeOmit ? const SizedBox.shrink() : _chatTime(time, me),
                    ],
                  ),
                  isImage
                      ? _chatImageBox(message, me)!
                      : _chatTextBox(message, me),
                ]
              : <Widget>[
                  _userProfileCircle(profileOmit),
                  isImage
                      ? _chatImageBox(message, me)!
                      : _chatTextBox(message, me),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      timeOmit ? const SizedBox.shrink() : _chatTime(time, me),
                    ],
                  ),
                ],
        ),
      ),
    );
  }

// user profile
  Widget _userProfileCircle(bool profileOmit) {
    return Container(
      width: 35,
      height: 35,
      margin: const EdgeInsets.only(right: 8.0),
      child: profileOmit
          ? const SizedBox(
              width: 35,
            )
          : const CircleAvatar(
              backgroundImage: AssetImage('assets/images/basic_profile.png'),
            ),
    );
  }

  Widget _chatTextBox(String text, bool me) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 270,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: me ? const Color(0xFFEC5870) : const Color(0xFFF1F1F1),
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: me ? Colors.white : const Color(0xff302E2E),
        ),
        maxLines: null,
      ),
    );
  }

  Widget? _chatImageBox(List<dynamic> photoUrls, bool me) {
    final imageLengths = photoUrls.length;
    // final numRow = imageLengths == 4 ? 2 : imageLengths;
    // final double imageSize = imageLengths == 1
    //     ? 208
    //     : imageLengths == 3
    //         ? 80
    //         : 104;

    switch (imageLengths) {
      case 1:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 208,
            maxHeight: 208,
          ),
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          // child: Container(),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Image.network(
              photoUrls[0],
              fit: BoxFit.cover,
              width: 208,
              height: 208,
            ),
          ),
        );

      case 2:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 210,
            maxHeight: 104,
          ),
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Row(
              children: photoUrls
                  .map<Widget>((url) => Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 104,
                        height: 104,
                      ))
                  .expand((widget) => [widget, const SizedBox(width: 2)])
                  .toList()
                ..removeLast(),
            ),
          ),
        );
      case 3:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 274,
            maxHeight: 90,
          ),
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Row(
              children: photoUrls
                  .map<Widget>((url) => Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ))
                  .expand((widget) => [widget, const SizedBox(width: 2)])
                  .toList()
                ..removeLast(),
            ),
          ),
        );
      case 4:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 210,
            maxHeight: 210,
          ),
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Image.network(
                        photoUrls[0],
                        fit: BoxFit.cover,
                        width: 104,
                        height: 104,
                      ),
                    ),
                    Image.network(
                      photoUrls[1],
                      fit: BoxFit.cover,
                      width: 104,
                      height: 104,
                    )
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Image.network(
                        photoUrls[2],
                        fit: BoxFit.cover,
                        width: 104,
                        height: 104,
                      ),
                    ),
                    Image.network(
                      photoUrls[3],
                      fit: BoxFit.cover,
                      width: 104,
                      height: 104,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      default:
        return Container();
    }
    // return null;

    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    //   decoration: const BoxDecoration(
    //     color: Color(0xFFF1F1F1),
    //     borderRadius: BorderRadius.all(
    //       Radius.circular(15),
    //     ),
    //   ),
    //   child: GridView.builder(
    //     physics: const NeverScrollableScrollPhysics(),
    //     shrinkWrap: true,
    //     itemCount: imageLengths,
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: numRow,
    //       childAspectRatio: 1.0,
    //       mainAxisExtent: 2,
    //       crossAxisSpacing: 2,
    //     ),
    //     itemBuilder: (BuildContext context, index) {
    //       return Image.network(
    //         photoUrls[index],
    //         fit: BoxFit.cover,
    //         // width: imageSize,
    //         // height: imageSize,
    //         loadingBuilder: (context, child, loadingProgress) => Container(
    //           // width: imageSize,
    //           // height: imageSize,
    //           decoration: const BoxDecoration(
    //             color: Colors.white,
    //           ),
    //         ),
    //         errorBuilder:
    //             (BuildContext context, Object error, StackTrace? stackTrace) {
    //           return Image.asset(
    //             '/assets/images/sample.png',
    //             fit: BoxFit.cover,
    //             // width: imageSize,
    //             // height: imageSize,
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
  }

  Widget _chatTime(String time, bool me) {
    return Padding(
      padding: me
          ? const EdgeInsets.only(right: 4, bottom: 2)
          : const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        time,
        style: const TextStyle(
          color: Color(0xff726E6E),
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
