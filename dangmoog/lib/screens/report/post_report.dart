import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/report/report_complete.dart';
import 'package:dangmoog/services/api.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/constants/product_report_list.dart';
// Assuming ProductModel is defined somewhere in your project

class PostReportPage extends StatefulWidget {
  final ProductModel product;

  const PostReportPage({Key? key, required this.product}) : super(key: key);

  @override
  _PostReportPageState createState() => _PostReportPageState();
}

class _PostReportPageState extends State<PostReportPage> {
  int _selectedReportIndex = -1;
  final ApiService apiService = ApiService();
  bool _isSubmitting = false;

  List<bool> isChecked = List.generate(
      productReport.length,
      (index) =>
          false); // Assuming productReport is a List of Strings for report reasons

  @override
  Widget build(BuildContext context) {
    bool isSubmitButtonEnabled = _selectedReportIndex != -1&& !_isSubmitting;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '게시글 신고',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
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
          return ListView(
            // Changed to ListView to accommodate dynamic content
            children: <Widget>[
              Text(
                "'${widget.product.title}'\n해당 게시글 신고 사유를 알려주세요.",
                style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                '신고 접수 이후 도토릿 팀에서 빠르게 조치를 도와드리겠습니다.',
                style: TextStyle(
                    color: Color(0xFF302E2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 16,
              ),
              ...List<Widget>.generate(isChecked.length, (index) {
                bool isSelected = _selectedReportIndex == index;
                return InkWell(
                  onTap: _isSubmitting? null:() {
                    setState(() {
                      _selectedReportIndex = isSelected ? -1 : index;
                      if (_selectedReportIndex == productReport.length - 1) {
                        _customReportController.clear();
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEC5870)
                            : const Color(0xFFD3D2D2),
                      ), // Use borderColor for the border
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      title: Text(
                        productReport[index],
                        style: const TextStyle(
                          color: Color(0xFF514E4E),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: _isSubmitting ? null : (bool? value) { // Disable checkbox if submitting
                          setState(() {
                            _selectedReportIndex = value! ? index : -1;
                            if (_selectedReportIndex == productReport.length - 1) {
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
              if (_selectedReportIndex ==
                  productReport.length -
                      1) // If the last checkbox is checked, show the TextField
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _customReportController,
                    decoration: InputDecoration(
                      // border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10.0),
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
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFFFFFFF)),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(buttonWidth, 46)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFF726E6E)),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '취소하기',
                      style: TextStyle(
                        color: Color(0xFF726E6E),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    onPressed: isSubmitButtonEnabled
                        ? () async {
                            // Determine the content of the report
                            setState(() {
                              _isSubmitting = true;
                            });

                            String content;
                            if (_selectedReportIndex ==
                                productReport.length - 1) {
                              // When custom report is selected
                              content = _customReportController.text;
                            } else {
                              // When a predefined report reason is selected
                              content = productReport[_selectedReportIndex];
                            }
                            // Call the API service to report the post with the determined content
                            try {
                              print(content);
                              final response = await apiService.reportPost(
                                  0, widget.product.postId, content);
                              if (response.statusCode == 200) {
                                // Navigate to the report completion page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReportCompletePage(
                                            sourceType:
                                                ReportSourceType.postReport),
                                  ),
                                );
                              } else {
                                // Handle non-200 responses or show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Report submission failed. Please try again later.')));
                              }
                            } catch (e) {
                              // Handle any errors that occur during the API call
                              print(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'An error occurred. Please try again later.')));
                            } finally{
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                          }
                        : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          isSubmitButtonEnabled
                              ? const Color(0xFFE20529)
                              : const Color(0xFF726E6E)),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(buttonWidth, 46)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child:
                    _isSubmitting
                        ? const CircularProgressIndicator( // Show a loading indicator when submitting
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ):
                    const Text(
                      '신고 접수',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }),
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
