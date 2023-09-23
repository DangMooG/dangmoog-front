import 'dart:io';

// import 'package:dangmoog/models/new_post_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dangmoog/constants/category_list.dart';
import 'package:intl/intl.dart';

// 권환 확인
import 'package:permission_handler/permission_handler.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final List<String> _imageList = <String>[];
  final ImagePicker picker = ImagePicker();
  final List<XFile> vac = <XFile>[];

  // 앨범에서 이미지를 가져오는 함수
  Future getImagesFromAlbum(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();

    // 사진 선택 -> limited
    // 모두 허용 -> grated
    // 허용 안함 -> permanantlydenied
    // // 팝업 띄워서 설정으로 이동하도록 유도 -> openAppSettings()로 연결
    // // 설정에서 사진 선택 or 모두 허용으로 변경 시 그 다음부터는 권한 문제 없음

    if (status.isGranted || status.isLimited) {
      try {
        final List<XFile> pickedImages = await picker.pickMultiImage();

        if (pickedImages.isNotEmpty) {
          List<String> imagesPath = pickedImages
              .where((image) => !_imageList.contains(image.path))
              .map((image) => image.path)
              .toList();
          setState(() {
            _imageList.addAll(imagesPath);
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      // 나중에 ios는 cupertino로 바꿔줄 필요 있음
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("앨범 권한 필요"),
            content:
                const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
            actions: <Widget>[
              TextButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("설정으로 이동"),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future getImagesFromCamera(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    // 사진 선택 -> limited
    // 모두 허용 -> grated
    // 허용 안함 -> permanantlydenied
    // // 팝업 띄워서 설정으로 이동하도록 유도 -> openAppSettings()로 연결
    // // 설정에서 사진 선택 or 모두 허용으로 변경 시 그 다음부터는 권한 문제 없음

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedImage =
            await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null) {
          String imagePath = pickedImage.path;

          setState(() {
            _imageList.add(imagePath);
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
      // 나중에 ios는 cupertino로 바꿔줄 필요 있음
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("카메라 권한 필요"),
            content:
                const Text("이 기능을 사용하기 위해서는 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요."),
            actions: <Widget>[
              TextButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("설정으로 이동"),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _imagePickerSection(context),
                      _textFieldsAndDropdown(),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Divider(
                  color: Color(
                    0xffBEBCBC,
                  ),
                  thickness: 0.5,
                  height: 0.5,
                ),
                _submitButton(context, screenSize)
              ],
            )
          ],
        ),
      ),
    );
  }

  // 사진 추가 위젯
  Widget _imagePickerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _addImages(context),
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
                  : null,
            ),
          )
        ],
      ),
    );
  }

  // 사진 추가 버튼
  Widget _addImages(BuildContext context) {
    // 카메라, 앨범 버튼
    Widget addPhotoButtonPopUp(
        Size screenSize, IconData icon, String text, Function onTap) {
      return GestureDetector(
        onTap: () {
          onTap();
          Navigator.of(context).pop();
        },
        child: Container(
          width: screenSize.width * 0.192,
          height: screenSize.width * 0.192,
          decoration: const BoxDecoration(
            color: Color(0xffE20529),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            Size screenSize = MediaQuery.of(context).size;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14), // 여기서 원하는 값으로 둥글게 조절할 수 있습니다.
              ),
              content: SizedBox(
                width: screenSize.width * 0.55,
                height: screenSize.height * 0.21,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '사진 업로드 방식을\n선택해주세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        addPhotoButtonPopUp(
                            screenSize, Icons.add_a_photo_outlined, '카메라', () {
                          getImagesFromCamera(context);
                        }),
                        const SizedBox(
                          width: 30,
                        ),
                        addPhotoButtonPopUp(screenSize,
                            Icons.add_photo_alternate_outlined, '앨범', () {
                          getImagesFromAlbum(context);
                        }),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 228,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xff726E6E),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '취소하기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff726E6E),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
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
  Widget _imagePreview(String imagePath) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        alignment: Alignment.topRight,
        // clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
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
                  _imageList.remove(imagePath);
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
  // Widget _imagePreview(XFile image) {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 8),
  //     child: Stack(
  //       alignment: Alignment.topRight,
  //       // clipBehavior: Clip.none,
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(8),
  //           child: Image.file(
  //             File(image.path),
  //             width: 80,
  //             height: 80,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         Positioned(
  //           // right: -10,
  //           // top: -10,
  //           child: GestureDetector(
  //             onTap: () {
  //               setState(() {
  //                 _imageList.remove(image);
  //               });
  //             },
  //             child: Stack(
  //               clipBehavior: Clip.none,
  //               alignment: Alignment.center,
  //               children: [
  //                 Container(
  //                   width: 16,
  //                   height: 16,
  //                   decoration: const BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 const Icon(
  //                   Icons.cancel,
  //                   color: Colors.black,
  //                   size: 20,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
      FocusScope.of(context).unfocus();
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
                            textAlign: TextAlign.left,
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
                    Icon(
                      _isSelectListVisible
                          ? Icons.keyboard_arrow_down_sharp
                          : Icons.keyboard_arrow_right_sharp,
                      color: _isSelectListVisible
                          ? const Color(0xff726E6E)
                          : const Color(0xffA19E9E),
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
              constraints: const BoxConstraints(maxHeight: 3 * 41.0),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: categeryItems.map((category) {
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
    String addCommas(String input) {
      int? number = int.tryParse(input.replaceAll(',', ''));

      if (number == null) return input;

      final format = NumberFormat('###,###,###,###,###');
      return format.format(number);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleEachSection("판매 가격"),
          TextFormField(
            controller: priceController,
            onChanged: (value) {
              if (value.length <= 20) {
                String formattedValue = addCommas(value);

                int cursorPosition = priceController.selection.start;

                priceController.text = formattedValue;
                priceController.selection = TextSelection.collapsed(
                    offset: cursorPosition +
                        (formattedValue.length - value.length));
              }
            },
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              color: Color(0xff302E2E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(8),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: Center(
                child: Text(
                  '₩ ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffA19E9E),
                  ),
                ),
              ),
              prefixIconConstraints:
                  BoxConstraints.tightFor(width: 30, height: 30),
              hintText: '가격을 입력해주세요.',
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
            maxLength: 20,
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
          TextFormField(
            controller: detailController,
            minLines: 7,
            maxLines: null,
            maxLength: 2000,
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
                  '물품에 대한 상세 설명을 작성해주세요. \n판매 금지 물품은 게시가 제한될 수 있습니다. \n\n좋은 거래를 위해 신뢰할 수 있는 내용을 작성해주세요. 욕설이나 비방 등의 내용이 들어갈 경우 다른 이용자에게 상처를 줄 수 있으며 신고 대상이 될 수 있습니다.',
              hintStyle: TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.clip,
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
  Widget _submitButton(BuildContext context, Size screenSize) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          // 쉼표 제거
          int price;
          if (priceController.text != "") {
            price = int.parse(priceController.text.replaceAll(',', ''));
          } else {
            price = 0;
          }
          // NewPostModel newPost = NewPostModel(
          //   userId: userId,
          //   title: productNameController.text,
          //   description: detailController.text,
          //   price: price,
          //   images: _imageList,
          //   category: dropdownValue,
          //   saleMethod: useCabinet ? "위탁판매" : "직접판매",
          // );
          Navigator.pop(context);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return const Color(0xffBEBCBC);
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Container(
          width: screenSize.width * 0.81,
          height: screenSize.height * 0.056,
          alignment: Alignment.center,
          child: const Text(
            '업로드하기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
