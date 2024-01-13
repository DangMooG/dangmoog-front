import 'dart:io';
import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/services/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class LockerValPage extends StatefulWidget {
  final ProductModel product;
  final ApiService apiService= ApiService();

  LockerValPage(this.product, {Key? key}) : super(key: key);

  @override
  State<LockerValPage> createState() => _LockerValState();
}

class _LockerValState extends State<LockerValPage> {
  File? _image; // Variable to hold the image file
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool get isButtonEnabled {
    return _image != null && _passwordController.text.length == 4;
  }

  @override
  void initState() {
    super.initState();
    // Add listener to password controller to update the UI as the user types.
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree.
    _passwordController.removeListener(_updateButtonState);
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Call setState to rebuild the widget with the updated button state.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("사물함거래 인증"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildUploadText(),
          _buildUploadSection(),
          const SizedBox(height: 20),
          _buildPasswordSection(),
        ],
      ),
    );
  }

  Widget _buildUploadText(){
    return const Align(
      alignment: Alignment.centerLeft,
      child:
        Text('사물함 인증사진 업로드', textAlign: TextAlign.left,),

    );
  }

  Widget _buildUploadSection() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // const Text('사물함 인증사진 업로드', textAlign: TextAlign.left),
        const SizedBox(height: 20),
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: 253,
            height: 253,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            )
                : const Icon(Icons.camera_alt, size: 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('설정한 비밀번호 입력(4자리)', textAlign: TextAlign.left),
        TextField(
          controller: _passwordController,
          maxLength: 4,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '비밀번호 4자리 입력',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: isButtonEnabled ? () async{
                try {
                  // Get the necessary data
                  int postId = widget.product.postId; // Assuming postId is a property of ProductModel
                  // int lockerId = lockerId; // Assuming lockerId is a property of ProductModel
                  String password = _passwordController.text;

                  Map<String, dynamic> filters = {"post_id": postId};
                  var searchResponse = await widget.apiService.searchLocker(filters);
                  if (searchResponse.data is List && searchResponse.data.isNotEmpty) {
                    var locker = searchResponse.data[0]; // Use the first locker in the list
                    int lockerId = locker['locker_id']; // Extract locker_id

                    // Call valLockerPost from ApiService
                    var lockerAuthResponse = await widget.apiService.valLockerPost(postId, lockerId, password, _image!);
                    if(lockerAuthResponse.statusCode==200){
                      print("Success: ${lockerAuthResponse.data}");
                      Navigator.pop(context);
                    } else{
                      print("Failed: ${lockerAuthResponse.statusCode}");
                    }

                    // Handle success (e.g., show a success message or navigate to another screen)
                  } else {
                    // Handle the case where no lockers are found or the response is not as expected
                    print("No lockers found for the provided post_id.");
                  }

                  // Handle success (e.g., show a success message or navigate to another screen)
                } catch (e) {
                  print("Error occurred: $e");
                  // Handle error (e.g., show an error message)
                }
              } : null, // Disable the button if conditions aren't met
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isButtonEnabled ? const Color(0xFFE20529) : Colors.grey,
                ),
                minimumSize: MaterialStateProperty.all<Size>(const Size(269, 46)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: const Text(
                '인증하기',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}