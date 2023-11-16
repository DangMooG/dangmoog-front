import 'package:dangmoog/models/locker_class.dart';
import 'package:dangmoog/screens/addpage/add_post_page.dart';
import 'package:dangmoog/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ChooseLockerPage extends StatefulWidget {

  const ChooseLockerPage({super.key});

  @override
  State<ChooseLockerPage> createState()=>_ChooseLockerPageState();
}

class _ChooseLockerPageState extends State<ChooseLockerPage>{
  final Map<int, bool> _isButtonPressedMap = {};
  final apiService = ApiService();
  bool isLoading =false;

  List<Locker> lockers =[];

  @override
  void initState(){
    super.initState();
    _loadLockerData();
  }

  List<Locker> _parseLockers(dynamic responseData) {
    // Assuming responseData is a List of JSON objects
    final lockerJsonList = responseData as List;
    List<Locker> lockersList = lockerJsonList.map((lockerJson) => Locker.fromJson(lockerJson)).toList();
    return lockersList;
  }

  void _loadLockerData() async {
    try {
      setState(() {
        // Assume you have a state variable that holds lockers
        isLoading = true;
      });
      Response response = await apiService.loadLocker();
      // Parse the response and convert to a list of Locker objects
      List<Locker> lockerList = _parseLockers(response.data);
      // Now, use `setState()` to update your UI with the lockers
      setState(() {
        // Assume you have a state variable that holds lockers
        lockers = lockerList;
        isLoading =false;
      });
    } catch (error) {
      print(error);
      isLoading =false;// Handle errors, such as by displaying an error message
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body:isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Image(image: AssetImage('assets/images/l_image.png'),
                              width: 16,
                              height: 16,),
                            SizedBox(width: 4,),
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
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      physics: const NeverScrollableScrollPhysics(), // as it is inside another scrollable widget
                      itemCount: 4, // Assuming there are 4 lockers in each series A and B
                      itemBuilder: (BuildContext context, int index) {
                        // Assuming locker labels are like "A1", "A2", "B1", "B2", etc.
                        int idxA = index;
                        int idxB = index + 4;
                        Locker lockerA= lockers[idxA];
                        Locker lockerB= lockers[idxB];

                        double heightA = lockerA.name.endsWith("4") ? 212 : 106;
                        double heightB = lockerB.name.endsWith("4") ? 212 : 106;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildButton(lockerA, heightA),
                              const SizedBox(width: 16),
                              buildButton(lockerB, heightB),
                              ],
                            ),
                          );
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Row(
                      children: [
                        _buildIconWithText('assets/images/using.png', '사용중'),
                        _buildIconWithText('assets/images/possible.png', '선택가능'),
                        _buildIconWithText('assets/images/selected.png', '선택됨'),
                        _buildIconWithText('assets/images/fixing.png', '점검중'),
                      ],
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
                    color: Colors.black),
              ),
            ),
            ]
      ),
    );
  }

  Widget _buildIconWithText(String imagePath, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(image: AssetImage(imagePath), width: 16, height: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }



  Expanded buildButton(Locker locker, double height) {
    String determineImage(String label) {
      if (locker.name == "A4" || locker.name == "B4") {
        return 'assets/images/l_image.png';
      }
      return 'assets/images/s_image.png';
    }
    _isButtonPressedMap.putIfAbsent(locker.lockerId, () => false);
    return Expanded(
        child:  ElevatedButton(
            onPressed: locker.status!=0 && locker.status!=2 ? () async {
              setState(() {
                _isButtonPressedMap[locker.lockerId]=true;
              });
              await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
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
                          Text("사물함 번호 : ${locker.name}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,),
                        ],
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        // Use minimum space required by children
                        children: [
                          if (locker.name == "A4" || locker.name == "B4") ...[
                            const Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/images/l_image.png'),
                                  width: 12,
                                  height: 12,
                                ),
                                SizedBox(width: 6,),
                                Flexible(child: Text(
                                    '너비 : 500mm / 높이 : 700mm / 깊이 : 600mm',
                                    style: TextStyle(fontSize: 12)),)
                              ],
                            ),

                          ] else
                            ...[
                              const Row(
                                children: [
                                  Image(
                                    image: AssetImage('assets/images/s_image.png'),
                                    height: 12,
                                    width: 12,
                                  ),
                                  SizedBox(width: 6,),
                                  Flexible(child:
                                  Text('너비 : 500mm / 높이 : 365mm / 깊이 : 600mm',
                                    style: TextStyle(fontSize: 12),),)
                                ],
                              ),

                            ],
                          const SizedBox(height: 10,),
                          // A spacing between the image-text and "Are you sure?"
                          const Text('물건의 크기를 다시 한 번 확인해주세요.\n 해당 사물함을 이용하시겠어요?',
                            textAlign: TextAlign.center,),
                          const SizedBox(height: 10,),
                          Column(
                            children: [
                              SizedBox(
                                width: 300,
                                child: TextButton(onPressed: () async {
                                  Map<String, dynamic> updates = {
                                    "status": 0,
                                    };
                                  try {
                                    Response response = await apiService
                                        .patchLocker(locker.lockerId, updates);
                                    if (response.statusCode == 200) {
                                      // Handle success here, e.g., show a confirmation message
                                      print('Locker status updated successfully');
                                    } else {
                                      // Handle the error, the server responded with a non-200 status code
                                      print(
                                          'Failed to update locker status: ${response
                                              .statusCode}');
                                    }
                                  } catch (e) {
                                    // Handle any exceptions here
                                    print('Error updating locker status: $e');
                                  }


                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPostPage(
                                          title: '사물함거래 등록',
                                          lockerId: locker.lockerId),
                                    ),
                                  ); // Returns true to the caller of showDialog
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty
                                      .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.pressed)) {
                                        return Colors
                                            .red[600]!; // Color when pressed
                                      }
                                      return const Color(
                                          0xFFE20529); // Regular color
                                    },
                                  ),

                                  foregroundColor: MaterialStateProperty.all<
                                      Color>(Colors.white),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                                child: TextButton(onPressed: () {
                                  setState(() {
                                    _isButtonPressedMap[locker.lockerId]=false;
                                  });
                                  Navigator.pop(context);
                                },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                        if (states.contains(
                                            MaterialState.pressed)) {
                                          return Colors
                                              .red[600]!; // Color when pressed
                                        }
                                        return Colors.transparent; // Regular color
                                      },
                                    ),
                                    foregroundColor: MaterialStateProperty.all<
                                        Color>(const Color(0xFFE20529)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          side: const BorderSide(
                                              color: Color(0xFFE20529))
                                      ),
                                    ),
                                  ),
                                  child: const Text('다시 고르기'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                  }
                );
              }:null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                  // Change color based on this locker's pressed state
                    if(locker.status==1){
                      return _isButtonPressedMap[locker.lockerId] ?? false
                          ? const Color(0xFFE20529)
                          : const Color(0xFFF28C9D);

                    }else if(locker.status==0){
                     return const Color(0xFFD3D2D2);
                    } else{
                      return const Color(0xFF726E6E);
                    }


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
                    child: Text(
                      locker.name, style: const TextStyle(color: Colors.white),),
                  ),
                  Positioned(
                    right: 5, // Position from the right
                    bottom: 5, // Position from the bottom
                    child: Image.asset(
                      determineImage(locker.name),
                      // call the function to get image path
                      width: 20, // Adjust as per your needs
                      height: 20, // Adjust as per your needs
                      ),
                    ),
                  ],
              ),
        )
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



