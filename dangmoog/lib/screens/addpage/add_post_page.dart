import 'dart:io';
import 'package:dangmoog/screens/post/main_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangmoog/constants/category_list.dart';
import 'package:intl/intl.dart';

// 권한 확인
import 'package:permission_handler/permission_handler.dart';

import 'package:dangmoog/services/api.dart';

class AddPostPage extends StatefulWidget {
  final String title;
  final int? lockerId;
  final bool fromChooseLocker;

  const AddPostPage(
      {Key? key,
      required this.title,
      this.lockerId,
      this.fromChooseLocker = false})
      : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  int useLocker = 1;
  final List<String> _imageList = <String>[];
  final ImagePicker picker = ImagePicker();
  final ApiService apiService = ApiService();

  bool get isImageUploaded => _imageList.isNotEmpty;
  bool get isProductNameFilled => productNameController.text.isNotEmpty;
  bool get isCategorySelected => _selectedItem.isNotEmpty;
  bool get isPriceFilled => priceController.text.isNotEmpty;
  bool get isDescriptionProvided => detailController.text.isNotEmpty;
  bool get isButtonEnabled =>
      isProductNameFilled &&
      isCategorySelected &&
      isPriceFilled &&
      isDescriptionProvided;
  String? productNameError;
  String? productCategoryError;
  String? productPriceError;
  String? productDescriptionError;

  void _createNewPost() async {
    String title = productNameController.text;
    int price;
    try {
      price = int.parse(priceController.text.replaceAll(',', ''));
    } catch (e) {
      print("Error parsing price: $e");
      return; // exit the function since price couldn't be parsed
    }

    String description = detailController.text;
    int categoryId = categeryItems.indexOf(_selectedItem);

    if (widget.title.contains('직접')) {
      useLocker = 0;
    } else {
      useLocker = 1;
    }

    print(useLocker);

    // Check if there are any images selected, otherwise set imageFiles to null
    List<File>? imageFiles;
    if (_imageList.isNotEmpty) {
      imageFiles = _imageList.map((path) => File(path)).toList();
    }

    Response response = await apiService.createPost(
      title: title,
      price: price,
      description: description,
      categoryId: categoryId,
      useLocker: useLocker,
      imageFiles: imageFiles,
    );

    if (response.statusCode == 200) {
      // Successful Response
      var responseData = response.data;

      var postId = responseData['post_id'];
      var createTime = responseData['create_time'];
      var updateTime = responseData['update_time'];

      // Implement your success logic here. For example, show a success message and navigate to another screen.
      print(
          "Post created successfully! Post ID: $postId, Created at: $createTime, Updated at: $updateTime");

      // Check if the locker is to be used
      if (useLocker == 1) {
        // Update the locker information with the new post_id
        Map<String, dynamic> lockerUpdates = {
          "post_id":
              postId, // assuming 'post_id' is the field you want to update in the locker
        };

        try {
          print("post ID는 $postId입니다.");
          Response lockerResponse =
              await apiService.patchLocker(widget.lockerId!, lockerUpdates);
          if (lockerResponse.statusCode == 200) {
            print('Locker updated successfully with Post ID: $postId');
          } else {
            print('Failed to update locker: ${lockerResponse.statusCode}');
          }
        } catch (e) {
          print('Error updating locker with Post ID: $e');
        }
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
            (Route<dynamic> route) => false,
      );
      // Your additional success logic
    } else if (response.statusCode == 422) {
      // Validation Error
      var errorData = response.data;
      var errorDetail = errorData['detail'];
      // Here you might want to iterate through 'detail' if it's a list to extract specific error messages
      for (var error in errorDetail) {
        var location = error['loc'];
        var errorMsg = error['msg'];
        var errorType = error['type'];

        // Handle the validation error. For example, display a relevant error message to the user.
        print("Error at $location: $errorMsg (Type: $errorType)");
      }

      // Maybe display a general error toast message or specific field error messages
    } else {
      // Other potential errors
      print('Hello');
      print(
          "Error creating post. Status Code: ${response.statusCode}, Error Message: ${response.statusMessage}");
    }
  }

  // 앨범에서 이미지를 가져오는 함수
  Future getImagesFromAlbum(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      try {
        final List<XFile> pickedImages = await picker.pickMultiImage();

        if (pickedImages.isNotEmpty) {
          List<String> imagesPath = pickedImages
              .where((image) => !_imageList.contains(image.path))
              .map((image) => image.path)
              .toList();

          // Check if adding new images will exceed the limit
          int overflowCount = _imageList.length + imagesPath.length - 10;
          if (overflowCount > 0) {
            // Trim the imagesPath list
            imagesPath =
                imagesPath.take(imagesPath.length - overflowCount).toList();

            // Inform the user about the trimmed images
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Image Limit Reached'),
                content: Text(
                    '$overflowCount images were not added due to the 10 image limit.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }

          setState(() {
            _imageList.addAll(imagesPath);
          });
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
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

    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedImage =
            await picker.pickImage(source: ImageSource.camera);

        if (pickedImage != null) {
          String imagePath = pickedImage.path;

          if (_imageList.length >= 10) {
            // Inform the user that they've reached the limit
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: const Text('You can only select up to 10 images.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              _imageList.add(imagePath);
            });
          }
        }
      } catch (e) {
        print("Error picking images: $e");
      }
    } else if (status.isPermanentlyDenied) {
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

  bool useCabinet = false;
  int userId = 3;

  bool _isSelectListVisible = false;
  String _selectedItem = '';

  bool isFree = false;
  bool _showPrice = false;

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    productNameController.addListener(() {
      if (isProductNameFilled) {
        setState(() {
          productNameError = null;
        });
      }
    });
    priceController.addListener(() {
      if (isPriceFilled) {
        setState(() {
          productPriceError = null;
        });
      }
    });
    detailController.addListener(() {
      if (isDescriptionProvided) {
        setState(() {
          productDescriptionError = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.fromChooseLocker) {
              // Check if it's from choose locker
              _showLockerDialog(context);
            } else if (isImageUploaded ||
                isProductNameFilled ||
                isCategorySelected ||
                isPriceFilled ||
                isDescriptionProvided) {
              _showExitConfirmationDialog(context);
            } else {
              Navigator.of(context).pop();
            }
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
      padding: const EdgeInsets.only(top: 16),
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
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              hintText: '물품 이름',
              hintStyle: const TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: productNameError == null
                      ? const Color(0xffD3D2D2)
                      : const Color(0xFFE20529),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: productNameError == null
                        ? const Color(0xff726E6E)
                        : const Color(
                            0xFFE20529) // Changes based on error condition
                    ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
            maxLength: 64,
          ),
          if (productNameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error,
                      color: Color(0xFFE20529), size: 12), // Error icon
                  const SizedBox(
                      width: 4), // Some spacing between icon and text
                  Text(
                    productNameError!,
                    style:
                        const TextStyle(color: Color(0xFFE20529), fontSize: 12),
                  ),
                ],
              ),
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

        if (_selectedItem.isNotEmpty) {
          productCategoryError = null;
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
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
                    (_selectedItem == '')
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
          if (productCategoryError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error,
                      color: Color(0xFFE20529), size: 12), // Error icon
                  const SizedBox(
                      width: 4), // Some spacing between icon and text
                  Text(
                    productCategoryError!,
                    style:
                        const TextStyle(color: Color(0xFFE20529), fontSize: 12),
                  ),
                ],
              ),
            ),
          if (_isSelectListVisible)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffD3D2D2)),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              constraints: const BoxConstraints(maxHeight: 3 * 41.0),
              child: Scrollbar(
                // <- Wrap ListView inside Scrollbar
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
      padding: const EdgeInsets.only(top: 16),
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
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: const Center(
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
                  const BoxConstraints.tightFor(width: 30, height: 30),
              hintText: '가격을 입력해주세요.',
              hintStyle: const TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: productPriceError == null
                      ? const Color(0xffD3D2D2)
                      : const Color(0xFFE20529),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: productPriceError == null
                        ? const Color(0xff726E6E)
                        : const Color(
                            0xFFE20529) // Changes based on error condition
                    ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
            maxLength: 20,
          ),
          if (productPriceError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error,
                      color: Color(0xFFE20529), size: 12), // Error icon
                  const SizedBox(
                      width: 4), // Some spacing between icon and text
                  Text(
                    productPriceError!,
                    style:
                        const TextStyle(color: Color(0xFFE20529), fontSize: 12),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // 가격 텍스트랑 ai 추천 가격 사이 칸
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              height: 48,
              // padding: const EdgeInsets.symmetric(horizontal:8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _showPrice
                  ? _recommendedPriceButtons()
                  : _initialAiRecommended(),
            ),
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
                        MaterialStateProperty.all(const Color(0xffBEBCBC)),
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
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return const Color(0xFFE20529); // Checked (red)
                        }
                        return const Color(
                            0xffBEBCBC); // Unchecked (transparent)
                      },
                    ),
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
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              hintText:
                  '물품에 대한 상세 설명을 작성해주세요. \n판매 금지 물품은 게시가 제한될 수 있습니다. \n\n좋은 거래를 위해 신뢰할 수 있는 내용을 작성해주세요. 욕설이나 비방 등의 내용이 들어갈 경우 다른 이용자에게 상처를 줄 수 있으며 신고 대상이 될 수 있습니다.',
              hintStyle: const TextStyle(
                color: Color(0xFFA19E9E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.clip,
              ),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: productDescriptionError == null
                      ? const Color(0xffD3D2D2)
                      : const Color(0xFFE20529),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: productDescriptionError == null
                      ? const Color(0xffD3D2D2)
                      : const Color(0xFFE20529),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          if (productDescriptionError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.error,
                      color: Color(0xFFE20529), size: 12), // Error icon
                  const SizedBox(
                      width: 4), // Some spacing between icon and text
                  Text(
                    productDescriptionError!,
                    style:
                        const TextStyle(color: Color(0xFFE20529), fontSize: 12),
                  ),
                ],
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
          _setFieldErrors();
          setState(() {});

          if (isButtonEnabled) {
            if (_imageList.isEmpty) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context){
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '사진을 올리지 않았습니다!\n그래도 판매글을 업로드하시겠어요?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8,),
                            const Text(
                              '사진이 없는 게시글은\n사진이 있는 게시물보다 전환율이 낮습니다.\n그래도 사진없이 업로드하시겠어요?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14 ),
                            ),
                            const SizedBox(height: 16,),
                            SizedBox(
                              width: 300,
                              child: TextButton(
                                onPressed: () {
                                  _createNewPost();
                                  if (useLocker==1){

                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                      if (states.contains(MaterialState.pressed)) {
                                        return Colors.red[600]!; // Color when pressed
                                      }
                                      return const Color(0xffE20529); // Regular color
                                    },
                                  ),

                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: const BorderSide(color: Color(0xFF726E6E)),
                                    ),
                                  ),
                                ),
                              ),
                              child: const Text('업로드'),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            width: 300,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // close the dialog
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors
                                          .red[600]!; // Color when pressed
                                    }
                                    return Colors.transparent; // Regular color
                                  },
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFF726E6E)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(
                                        color: Color(0xFF726E6E)),
                                  ),
                                ),
                              ),
                              child: const Text('취소하기'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              _createNewPost();
            }
          }

          if (priceController.text.isNotEmpty) {
          } else {}
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFFE20529)),
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

  Widget _initialAiRecommended() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: 212,
          height: 32,
          child: Text(
            '중고가를 어떻게 설정해야 할지 모르겠다면?\nAI가 대표사진을 분석하여 가격을 추천해줘요!',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              height: 1.45,
              color: Color(0xFF302E2E),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: () {
              setState(() {
                _showPrice = true;
              });
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(111, 24),
              backgroundColor: const Color(0xFFEC5870),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              'AI 가격 추천(BETA)',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _recommendedPriceButtons() {
    return Row(
      children: [
        ...<String>['₩ 1,011,000', '₩ 1,212,000', '₩ 1,413,000']
            .map((price) => Padding(
                  padding: const EdgeInsets.only(
                      right:
                          4.0), // This gives each button a right padding of 4.0
                  child: TextButton(
                    onPressed: () {
                      priceController.text = price.replaceFirst('₩ ', '');
                      if (isFree == true) {
                        setState(() {
                          isFree = !isFree;
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEC5870),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8), // Vertical padding of 8 for buttons
                      minimumSize: const Size(82, 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ))
            .toList(),
        const Spacer(),
        IconButton(
          icon: const Image(
            image: AssetImage('assets/images/Vector.png'),
            width: 12.5,
            height: 12.5,
          ),
          onPressed: () {
            setState(() {
              _showPrice =
                  false; // Switching back to the _initialAiRecommended widget
            });
          },
        ),
      ],
    );
  }

  void _setFieldErrors() {
    // Check for product name

    setState(() {
      if (!isProductNameFilled) {
        productNameError = '물품 이름을 입력해주세요!';
      } else {
        productNameError = null;
      }

      // Check for category
      if (!isCategorySelected) {
        productCategoryError = '카테고리 항목을 선택해주세요!';
      } else {
        productCategoryError = null;
      }

      // Check for product description
      if (!isDescriptionProvided) {
        productDescriptionError = '상세내용을 1자 이상 작성해주세요!';
      } else {
        productDescriptionError = null;
      }

      // Check for product price
      if (!isPriceFilled) {
        productPriceError = '가격을 입력해주세요!';
      } else {
        productPriceError = null;
      }
    });

    // Similarly, reset error messages for other fields if their conditions are satisfied
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '작성 중인 판매글을 삭제하시겠어요?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '삭제하기를 누르시면 저장되지 않습니다.',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // content: ,
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      // if (useLocker==1){
                      //   Map<String, dynamic> updates= {"status":1};
                      //   apiService.patchLocker(widget.lockerId!, updates);
                      // }

                      Navigator.of(context).pop(
                          true); // Close the dialog and confirm exit without saving
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
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    child: const Text('삭제하기'),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      foregroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF726E6E)),
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
        );
      },
    ).then((shouldExit) {
      if (shouldExit == true) {
        Navigator.of(context).pop(); // Exit the AddPostPage
      }
    });
  }

  void _showLockerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '사물함거래 등록 시 유의해주세요!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '30분 안에 게시글을 업로드 하지 않으면 사물함 선택이 초기화돼요.\n게시글 작성 이후 15분 안에 사물함 안에 물건을 넣은 사진과 비밀번호를 인증해주셔야 합니다(구매자 확인용).',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          // content: ,
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      // if (useLocker==1){
                      //   Map<String, dynamic> updates= {"status":1};
                      //   apiService.patchLocker(widget.lockerId!, updates);
                      // }

                      Navigator.of(context).pop(
                          true); // Close the dialog and confirm exit without saving
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
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    child: const Text('사물함거래 등록 시작하기'),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      foregroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF726E6E)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFF726E6E)),
                        ),
                      ),
                    ),
                    child: const Text('직접거래로 전환하기'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((shouldExit) {
      if (shouldExit == true) {
        Navigator.of(context).pop(); // Exit the AddPostPage
      }
    });
  }
}
