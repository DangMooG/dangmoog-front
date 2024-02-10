import 'package:dangmoog/widgets/fadein_router.dart';
import 'package:dangmoog/widgets/fullscreen_image_viewer.dart';
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
    Size screenSize = MediaQuery.of(context).size;

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
                      ? _chatImageBox(context, message, me)!
                      : _chatTextBox(message, me, screenSize),
                ]
              : <Widget>[
                  _userProfileCircle(profileOmit),
                  isImage
                      ? _chatImageBox(context, message, me)!
                      : _chatTextBox(message, me, screenSize),
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

  Widget _chatTextBox(String text, bool me, Size screenSize) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: screenSize.width * 0.6,
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

  Widget? _chatImageBox(
      BuildContext context, List<dynamic> photoUrls, bool me) {
    final imageLengths = photoUrls.length;

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
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(fadeInRouting(
                  FullScreenImageViewer(
                    imageUrls: photoUrls,
                    initialPage: 0,
                  ),
                ));
              },
              child: Image.network(
                photoUrls[0],
                fit: BoxFit.cover,
                width: 208,
                height: 208,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/sample.png',
                    fit: BoxFit.cover,
                    width: 208,
                    height: 208,
                  );
                },
              ),
            ),
          ),
        );
      case 2:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 208,
            maxHeight: 103,
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
                  .asMap()
                  .entries
                  .map<Widget>((entry) {
                    int index = entry.key;
                    String url = entry.value;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeInRouting(
                          FullScreenImageViewer(
                            imageUrls: photoUrls,
                            initialPage: index,
                          ),
                        ));
                      },
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 103,
                        height: 103,
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/sample.png',
                            fit: BoxFit.cover,
                            width: 103,
                            height: 103,
                          );
                        },
                      ),
                    );
                  })
                  .expand((widget) => [widget, const SizedBox(width: 2)])
                  .toList()
                ..removeLast(),
            ),
          ),
        );
      case 3:
        return Container(
          constraints: const BoxConstraints(
            maxWidth: 244,
            maxHeight: 80,
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
                  .asMap()
                  .entries
                  .map<Widget>((entry) {
                    int index = entry.key;
                    String url = entry.value;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeInRouting(
                          FullScreenImageViewer(
                            imageUrls: photoUrls,
                            initialPage: index,
                          ),
                        ));
                      },
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/sample.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          );
                        },
                      ),
                    );
                  })
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(fadeInRouting(
                            FullScreenImageViewer(
                              imageUrls: photoUrls,
                              initialPage: 0,
                            ),
                          ));
                        },
                        child: Image.network(
                          photoUrls[0],
                          fit: BoxFit.cover,
                          width: 104,
                          height: 104,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/sample.png',
                              fit: BoxFit.cover,
                              width: 104,
                              height: 104,
                            );
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeInRouting(
                          FullScreenImageViewer(
                            imageUrls: photoUrls,
                            initialPage: 1,
                          ),
                        ));
                      },
                      child: Image.network(
                        photoUrls[1],
                        fit: BoxFit.cover,
                        width: 104,
                        height: 104,
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/sample.png',
                            fit: BoxFit.cover,
                            width: 104,
                            height: 104,
                          );
                        },
                      ),
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
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(fadeInRouting(
                            FullScreenImageViewer(
                              imageUrls: photoUrls,
                              initialPage: 2,
                            ),
                          ));
                        },
                        child: Image.network(
                          photoUrls[2],
                          fit: BoxFit.cover,
                          width: 104,
                          height: 104,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/sample.png',
                              fit: BoxFit.cover,
                              width: 104,
                              height: 104,
                            );
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(fadeInRouting(
                          FullScreenImageViewer(
                            imageUrls: photoUrls,
                            initialPage: 3,
                          ),
                        ));
                      },
                      child: Image.network(
                        photoUrls[3],
                        fit: BoxFit.cover,
                        width: 104,
                        height: 104,
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            'assets/images/sample.png',
                            fit: BoxFit.cover,
                            width: 104,
                            height: 104,
                          );
                        },
                      ),
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
