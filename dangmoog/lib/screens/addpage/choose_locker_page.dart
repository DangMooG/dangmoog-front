import 'package:flutter/material.dart';

class ChooseLockerPage extends StatelessWidget {
  const ChooseLockerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      body: Stack(
        children: [SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/choose_locker.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      '사물함을 선택해주세요!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('S 너비 : 500mm / 높이 : 365mm / 깊이 : 600mm'),
                    SizedBox(height: 5),
                    Text('L 너비 : 500mm / 높이 : 700mm / 깊이 : 600mm'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < 3) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildButton("A0${index + 1}", 106),
                            SizedBox(width: 16),
                            buildButton("B0${index + 1}", 106),
                          ],
                        ),
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButton("A04", 212),
                          SizedBox(width: 8),
                          buildButton("B04", 212),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar height
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.black), // Icon color adjusted for visibility
            ),
          ),
        ]
      ),
    );
  }

  Expanded buildButton(String label, double height) {
    return Expanded(
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Container(
          height: height,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(8),
          child: Text(label),
        ),
      ),
    );
  }
}
