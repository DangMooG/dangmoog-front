import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dangmoog/models/new_post_model.dart';

import 'package:dangmoog/constants/category_list.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final List<XFile> _imageList = <XFile>[];
  final ImagePicker picker = ImagePicker();

  // //이미지를 가져오는 함수
  Future getImagesFromAlbum() async {
    try {
      final List<XFile> pickedImages = await picker.pickMultiImage();

      if (pickedImages.isNotEmpty) {
        setState(() {
          // _imageList = pickedImages;
          _imageList.addAll(pickedImages);
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  String dropdownValue = 'Category 1';
  bool useCabinet = false;
  int userId = 3;

  bool _isSelectListVisible = false;
  String _selectedItem = '';

  bool isFree = false;

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.91;

    return Scaffold(
      appBar: AppBar(
        title: const Text('물품 판매'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        // actions: [_submitButton()],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _imagePickerSection(),
              _textFieldsAndDropdown(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _submitButton(context, buttonWidth),
    );
  }

  // 사진 추가 위젯
  Widget _imagePickerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _addImages(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _imageList.isNotEmpty
                  ? Row(
                      children: List.generate(
                        _imageList.length,
                        (index) => _imagePreview(_imageList[index]),
                      ),
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }

  // 사진 추가 버튼
  Widget _addImages() {
    return GestureDetector(
      onTap: getImagesFromAlbum,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFA19E9E),
            width: 1,
          ),
        ),
        width: 80,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              color: Color(0xFFA19E9E),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_imageList.length}",
                  style: TextStyle(
                    color: _imageList.isEmpty
                        ? const Color(0xFFA19E9E)
                        : const Color(0xFFE20529),
                    fontSize: 12,
                  ),
                ),
                const Text(
                  "/10",
                  style: TextStyle(
                    color: Color(0xFFA19E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 사진 미리보기 위젯
  Widget _imagePreview(XFile image) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        alignment: Alignment.topRight,
        // clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(image.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            // right: -10,
            // top: -10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _imageList.remove(image);
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.cancel,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 사진 제외 나머지
  Widget _textFieldsAndDropdown() {
    return Column(
      children: [
        _postTitle(),
        _categorySelect(),
        _productPrice(),
        _productDescription(),
      ],
    );
  }

  // 게시물 제목 입력 위젯
  Widget _postTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("물품 이름"),
          TextFormField(
            controller: productNameController,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xff302E2E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(8),
              hintText: '물품 이름',
              hintStyle: TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD3D2D2)),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff726E6E)),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            maxLength: 64,
          ),
        ],
      ),
    );
  }

  // 카테고리 선택 위젯
  Widget _categorySelect() {
    void _toggleListVisibility() {
      setState(() {
        _isSelectListVisible = !_isSelectListVisible;
      });
    }

    void _selectItem(String item) {
      setState(() {
        _selectedItem = item;
        _isSelectListVisible = false;
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("카테고리(항목) 선택"),
          GestureDetector(
            onTap: _toggleListVisibility,
            child: Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffD3D2D2)),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (_selectedItem == "")
                        ? const Text(
                            '항목 선택',
                            style: TextStyle(
                              color: Color(0xffA19E9E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Text(
                            _selectedItem,
                            style: const TextStyle(
                              color: Color(0xff302E2E),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                    Transform.rotate(
                      angle: _isSelectListVisible ? (pi / 2) : 0,
                      child: Icon(
                        Icons.chevron_right,
                        color: _isSelectListVisible
                            ? const Color(0xff726E6E)
                            : const Color(0xffA19E9E),
                      ),
                    )
                  ],
                )),
          ),
          if (_isSelectListVisible)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffD3D2D2)),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Column(
                children: catogoryItems.map((category) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    hoverColor: const Color(0xffF1F1F1),
                    title: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xff302E2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () => _selectItem(category),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // 판매 가격 입력 위젯
  Widget _productPrice() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("판매 가격"),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xff302E2E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(8),
              hintText: '₩ 가격을 입력해주세요.',
              hintStyle: TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD3D2D2)),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff726E6E)),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            maxLength: 64,
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    value: isFree,
                    splashRadius: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: const BorderSide(
                        color: Color(0xffBEBCBC),
                        width: 1,
                      ),
                    ),
                    activeColor: const Color(0xffBEBCBC),
                    fillColor:
                        const MaterialStatePropertyAll(Color(0xffBEBCBC)),
                    checkColor: Colors.white,
                    onChanged: (value) {
                      if (isFree) {
                        priceController.text = "";
                      } else {
                        priceController.text = "0";
                      }
                      setState(() {
                        isFree = !isFree;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    '나눔하기',
                    style: TextStyle(
                      color: Color(0xff302E2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 게시물 상세 내용
  Widget _productDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("상세한 내용"),
          Container(
            child: TextFormField(
              controller: detailController,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xff302E2E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                hintText:
                    '물품에 대한 상세 설명을 작성해주세요. 판매 금지 물품은 게시가 제한될 수 있습니다. \n\n ',
                hintStyle: TextStyle(
                  color: Color(0xFFA19E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                counterText: "",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD3D2D2)),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff726E6E)),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 각 입력 field 제목
  Widget _titleEachSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF302E2E),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 게시 버튼
  Widget _submitButton(BuildContext context, double buttonWidth) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(
              0xffBEBCBC,
            ),
            width: 0.5,
          ),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          NewPostModel newPost = NewPostModel(
            userId: userId,
            title: productNameController.text,
            description: detailController.text,
            price: priceController.text != ""
                ? int.parse(priceController.text)
                : 0,
            images: _imageList,
            category: dropdownValue,
            saleMethod: useCabinet ? "위탁판매" : "직접판매",
          );
          Navigator.pop(context);
        },
        style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(Size(buttonWidth, 85)),
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFFBEBCBC)),
            minimumSize: MaterialStateProperty.all<Size>(const Size(269, 46)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)))),
        child: Container(
          width: buttonWidth,
          // height: screenSize.height * 0.056,
          alignment: Alignment.center,
          child: const Text(
            '업로드하기',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard-Medium',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
