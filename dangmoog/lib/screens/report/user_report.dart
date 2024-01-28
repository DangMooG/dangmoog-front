import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/report/report_complete.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/constants/user_report_list.dart';

// Assuming ProductModel is defined somewhere in your project

class UserReportPage extends StatefulWidget {
  final ProductModel product;

  UserReportPage({Key? key, required this.product}) : super(key: key);

  @override
  _UserReportPageState createState() => _UserReportPageState();
}

class _UserReportPageState extends State<UserReportPage> {
  // Add any state variables and methods here

  int _selectedReportIndex = -1;

  List<bool> isChecked = List.generate(userReport.length, (index) => false); // Assuming productReport is a List of Strings for report reasons

  @override
  Widget build(BuildContext context) {
    bool isSubmitButtonEnabled = _selectedReportIndex != -1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 신고',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600),),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFBEBCBC), // Divider color
            height: 1.0, // Divider thickness
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double availableWidth = constraints.maxWidth;
              double buttonWidth = (availableWidth - 16) / 2;

              return ListView( // Changed to ListView to accommodate dynamic content
                children: <Widget>[
                  Text(
                    "\'${widget.product.title}\'\n해당 게시글 신고 사유를 알려주세요.",
                    style: const TextStyle(color: Color(0xFF000000),fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8,),
                  const Text(
                    '신고 접수 이후 도토릿 팀에서 빠르게 조치를 도와드리겠습니다.',
                    style: TextStyle(color: Color(0xFF302E2E), fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 16,),
                  ...List<Widget>.generate(isChecked.length, (index) {
                    bool isSelected = _selectedReportIndex==index;
                    return InkWell(
                      onTap: (){
                        setState(() {
                          _selectedReportIndex = isSelected?-1:index;
                          if (_selectedReportIndex==userReport.length-1){
                            _customReportController.clear();
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? const Color(0xFFEC5870) : const Color(0xFFD3D2D2),
                          ), // Use borderColor for the border
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListTile(
                          title: Text(
                            userReport[index],
                            style: const TextStyle(
                              color: Color(0xFF514E4E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedReportIndex = value! ? index : -1;
                                if (_selectedReportIndex == userReport.length - 1) {
                                  // Last item's special condition
                                  _customReportController.clear();
                                }
                              });
                            },
                            activeColor: const Color(0xFFEC5870),
                          ),
                        ),
                      ),
                    );

                  }),
                  if (_selectedReportIndex == userReport.length - 1) // If the last checkbox is checked, show the TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: TextField(
                        controller: _customReportController,
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                          hintText: '자세한 신고 사유를 작성해주세요',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFFEC5870)),
                            borderRadius: BorderRadius.circular(5),
                          ),

                        ),
                        maxLines: null,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFFFFFF)),
                          minimumSize: MaterialStateProperty.all<Size>(Size(buttonWidth, 46)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFF726E6E)), // Border color
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);// Handle button press
                        },
                        child: const Text(
                          '취소하기',
                          style: TextStyle(
                            color: Color(0xFF726E6E), // Set the text color as well if needed
                          ),
                        ),
                      ),

                      const SizedBox(width: 16,),
                      TextButton(
                        onPressed: isSubmitButtonEnabled? (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportCompletePage(sourceType: ReportSourceType.userReport),
                            ),
                          );


                        }:null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              isSubmitButtonEnabled ? const Color(0xFFE20529) : const Color(0xFF726E6E)
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(Size(buttonWidth, 46)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        child: const Text(
                          '신고 접수',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF), // Set the text color as well if needed
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              );
            }
        ),
      ),

    );
  }

  // Create a text editing controller for the custom report field
  final TextEditingController _customReportController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controller when the state is disposed
    _customReportController.dispose();
    super.dispose();
  }
}
