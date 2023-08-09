import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangmoog/models/product_class.dart';

class UploadProductPage extends StatefulWidget {
  @override
  _UploadProductPageState createState() => _UploadProductPageState();
}

class _UploadProductPageState extends State<UploadProductPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? images = [];
  String dropdownValue = 'Category 1';
  bool useCabinet = false;
  String userId = '프론트마스터김철희'; // 백엔드에서 개인 유저 id 받아오기 구현 예정

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [buildSubmitButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildImagePickerSection(),
            buildTextFieldsAndDropdown(),
          ],
        ),
      ),
    );
  }

  Widget buildImagePickerSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Image button and images display
        buildAddImage(),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.start,
          children: List.generate(
            images!.length + 1,
                (index) => index < 10
                ? index == images!.length
                ? const SizedBox.shrink()
                : buildImage(images![index])
                : const SizedBox.shrink(),
          ),
        ),
        // Text fields and dropdown

      ],
    );
  }

  Widget buildTextFieldsAndDropdown() {
    return Column(
      children: [
        TextFormField(
          controller: productNameController,
          decoration: const InputDecoration(hintText: '물건 이름'),
        ),
        DropdownButtonFormField<String>(
          value: dropdownValue,
          items: <String>['Category 1', 'Category 2', 'Category 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          decoration: const InputDecoration(hintText: '카테고리(항목) 선택'),
        ),
        buildUsingCabinetCheckbox(),
        TextFormField(
          controller: priceController,
          decoration: const InputDecoration(
              hintText: '₩ 가격(가격 미입력 / 0 입력시 나눔)'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: detailController,
          decoration: const InputDecoration(
            hintText: '본문 내용 입력하기',
            border: InputBorder.none,),

        ),

      ],
    );
  }

  Widget buildUsingCabinetCheckbox() {
    return DropdownButtonFormField<String>(
      value: useCabinet ? "Cabinet" : "Direct",
      items: <String>['Direct', 'Cabinet']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value == 'Cabinet' ? '위탁판매' : '직접판매'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          useCabinet = newValue == "Cabinet";
        });
      },
      decoration: const InputDecoration(hintText: '판매 방식 선택'),
    );
  }


  Widget buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        Product product = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: productNameController.text,
          description: detailController.text,
          price: double.tryParse(priceController.text) ?? 0.0,
          images: images!.map((e) => e.path).toList(),
          category: dropdownValue,
          uploadTime: DateTime.now(),
          saleMethod: useCabinet ? "위탁판매" : "직접판매",
          user: userId,
        );
        // Handle Submit
      },
      child: const Text('업로드'),
    );
  }

  Widget buildAddImage() {
    return GestureDetector(
      onTap: () async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            images!.add(pickedFile);
          });
        }
      },
      child: Container(
        color: Colors.grey[200],
        width: 80,
        height: 80,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildImage(XFile image) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Image.file(
          File(image.path),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              images!.remove(image);
            });
          },
          child: const Icon(
            Icons.remove_circle,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
