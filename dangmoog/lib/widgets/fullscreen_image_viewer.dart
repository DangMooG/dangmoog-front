import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<dynamic> imageUrls;
  final int initialPage;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrls,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.clear_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                String imagePath = widget.imageUrls[index];
                return InteractiveViewer(
                  panEnabled: false,
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.5,
                  maxScale: 4,
                  child: (imagePath.startsWith('http') ||
                          imagePath.startsWith('https'))
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/sample.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          'assets/images/sample.png',
                          fit: BoxFit.contain,
                        ),
                );
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class FullScreenAssetImageViewer extends StatelessWidget {
  final String imageUrls;

  const FullScreenAssetImageViewer({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.clear_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Center(
          child: InteractiveViewer(
            panEnabled: false,
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.5,
            maxScale: 4,
            child: Image.asset(
              imageUrls,
              fit: BoxFit.contain,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Image.asset(
                  'assets/images/sample.png',
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        ));
  }
}
