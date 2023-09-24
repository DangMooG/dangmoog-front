import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:flutter/material.dart';

import '../post/main_page.dart';

class ChooseLockerPage extends StatefulWidget {

  const ChooseLockerPage({super.key});

  @override
  State<ChooseLockerPage> createState()=>_ChooseLockerPageState();
}

class _ChooseLockerPageState extends State<ChooseLockerPage>{
  final ValueNotifier<bool> _isButtonPressed = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
          children: [SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        insetPadding: const EdgeInsets.all(10), // Some padding around the dialog
                        content: AspectRatio(
                          aspectRatio: 1, // Set your desired aspect ratio if needed
                          child:
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child:Image.asset('assets/images/choose_locker.png', fit: BoxFit.fill),)
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('닫기', style: TextStyle(color:  Color(0xFFE20529)
                            )
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/choose_locker.png'),
                        fit: BoxFit.fill,
                      ),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Image(image: AssetImage('assets/images/s_image.png'),
                            height: 16,
                            width: 16,),
                          SizedBox(width: 6,),
                          Text('너비 : 500mm / 높이 : 365mm / 깊이 : 600mm'),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Image(image: AssetImage('assets/images/l_image.png'),
                            width: 16,
                            height: 16,),
                          SizedBox(width: 6,),
                          Text('너비 : 500mm / 높이 : 700mm / 깊이 : 600mm'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < 3) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildButton("A0${index + 1}", 106),
                              const SizedBox(width: 16),
                              buildButton("B0${index + 1}", 106),
                            ],
                          ),
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildButton("A04", 212),
                            const SizedBox(width: 8),
                            buildButton("B04", 212),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0, bottom: 10),
                      child: Text(
                        "사물함 거래 시 유의사항",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff302E2E),
                        ),
                      ),
                    ),
                    textCell("하나의 사물함에 위탁된 물품은 모두 한번에 거래되어야 합니다."),
                    textCell(
                        "기본적으로 인당 1개의 사물함을 이용할 수 있으나, 보증금을 지불하여 최대 3개까지 이용이 가능합니다."),
                    textCell(
                        "1개 사물함을 초과하는 건당 5,000원의 보증금이 부과되며, 해당 보증금은 5일 이내 거래가 이루어질 경우 전액 반환됩니다."),
                    textCell("인당 최대 1개의 사물함을 이용할 수 있습니다."),
                    textCell(
                        "등록 이후 14일이 지난 물품은 판매자 직접 회수를 원칙으로 하며, 회수 되지 않을 시 관리자가 회수를 진행합니다."),
                    textCell("관리자에 의해 회수된 물품은 최대 1개월간 보호 후 폐기 처리됩니다."),
                    textCell(
                        "신고 누적 혹은 이용 규정 미준수 물품에 대해서는 조기 회수 및 폐기 처리될 수 있습니다."),
                    textCell("사용자의 부주의로 인한 사물함 파손 시 수리비용이 청구될 수 있습니다."),
                    const SizedBox(height: 80),
                  ],
                ),
              ],
            ),
          ),
            Positioned(
              top: MediaQuery
                  .of(context)
                  .padding
                  .top + 10, // Adjust for status bar height
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back,
                    color: Colors.black), // Icon color adjusted for visibility
              ),
            ),
          ]
      ),


    );
  }

  Expanded buildButton(String label, double height) {
    String determineImage(String label) {
      if (label == "A04" || label == "B04") {
        return 'assets/images/l_image.png';
      }
      return 'assets/images/s_image.png';
    }

    return Expanded(
      child: ElevatedButton(
        onPressed: () async{
          await showDialog<bool>(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("선택하신 사물함은 아래와 같습니다!",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,),
                      ),
                      Text("사물함 번호 : $label",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Use minimum space required by children
                    children: [
                      if (label == "A04" || label == "B04") ...[
                        const Row(
                          children: [
                            Image(
                              image: AssetImage('assets/images/l_image.png'),
                              width: 12,
                              height: 12,
                            ),
                            SizedBox(width: 6,),
                            Flexible(child: Text('너비 : 500mm / 높이 : 700mm / 깊이 : 600mm',
                                style: TextStyle(fontSize: 12)),)
                          ],
                        ),

                      ] else ...[
                        const Row(
                          children: [
                            Image(
                              image: AssetImage('assets/images/s_image.png'),
                              height: 12,
                              width: 12,
                            ),
                            SizedBox(width: 6,),
                            Flexible(child:
                            Text('너비 : 500mm / 높이 : 365mm / 깊이 : 600mm', style: TextStyle(fontSize: 12),),)
                          ],
                        ),

                      ],
                      const SizedBox(height: 10,), // A spacing between the image-text and "Are you sure?"
                      const Text('물건의 크기를 다시 한 번 확인해주세요.\n 해당 사물함을 이용하시겠어요?', textAlign: TextAlign.center,),
                      const SizedBox(height: 10,),
                      Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextButton(onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddPostPage()
                                ),
                              ); // Returns true to the caller of showDialog
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return Colors.red[600]!; // Color when pressed
                                    }
                                    return const Color(0xFFE20529); // Regular color
                                  },
                                ),

                                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),

                              ),
                              child: const Text('선택하기'),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextButton(onPressed: (){
                              Navigator.pop(context);
                            },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return Colors.red[600]!; // Color when pressed
                                    }
                                    return Colors.transparent; // Regular color
                                  },
                                ),
                                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFE20529)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: Color(0xFFE20529))
                                  ),
                                ),
                              ),
                              child: const Text('다시 고르기'),
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: TextButton(onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MainPage()
                                  ),
                              );
                            },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return Colors.red[600]!; // Color when pressed
                                    }
                                    return Colors.transparent; // Regular color
                                  },
                                ),

                                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF726E6E)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: Color(0xFF726E6E)),
                                  ),
                                ),

                              ),
                              child: const Text('취소하기'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                );
              }
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (_isButtonPressed.value) {
                return const Color(0xFFE20529);
              }
              if(states.contains(MaterialState.pressed)){
                  return const Color(0xFFE20529);
                  }
              return const Color(0xFFF28C9D); // Default color

            },
          ),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: height,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: Text(label, style: const TextStyle(color: Colors.white),),
            ),
            Positioned(
              right: 5, // Position from the right
              bottom: 5, // Position from the bottom
              child: Image.asset(
                determineImage(label), // call the function to get image path
                width: 20, // Adjust as per your needs
                height: 20, // Adjust as per your needs
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget textCell(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 6.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff302E2E),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff302E2E),
              ),
            ),
          )
        ],
      ),
    );
  }

}



