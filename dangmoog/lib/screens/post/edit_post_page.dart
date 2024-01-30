// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dangmoog/screens/home.dart';
import 'package:dangmoog/screens/post/post_list.dart';
import 'package:dangmoog/widgets/bottom_popup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dangmoog/constants/category_list.dart';
import 'package:intl/intl.dart';

import 'package:dangmoog/services/api.dart';

import '../../models/product_class.dart';

class EditPostPage extends StatefulWidget {
  final ProductModel product;
  const EditPostPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late int useLocker;
  final List<String> _imageList = <String>[];
  final ImagePicker picker = ImagePicker();
  final List<XFile> vac = <XFile>[];
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

  @override
  void initState() {
    super.initState();
    fetchImages();
    fetchProductDetails();

    productNameController.text = widget.product.title; // Example field
    priceController.text = widget.product.price.toString();
    _selectedItem = categeryItems[widget.product.categoryId];
    detailController.text = widget.product.description;

    // Initialize other controllers similarly

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

  Future<void> fetchImages() async {
    try {
      Response response = await apiService.searchPhoto(widget.product.postId);
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        List<String> imagePaths =
        responseData.map((e) => e['url'].toString()).toList();
        setState(() {
          _imageList.addAll(imagePaths);
        });
      } else {
        print('Error fetching images: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchImages: $e');
    }
  }

  void fetchProductDetails() async {
    try {
      final response = await apiService.loadProduct(widget.product.postId);
      if (response.statusCode == 200) {
        ProductModel product = ProductModel.fromJson(response.data);

        // Now, set the state with the fetched product data
        setState(() {
          productNameController.text = product.title;
          priceController.text = product.price.toString();
          _selectedItem = categeryItems[product.categoryId];
          detailController.text = product.description;
        });
      } else {
        // Handle non-successful response
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  void _editNewPost() async {
    String title = productNameController.text;
    int price;
    try {
      price = int.parse(priceController.text.replaceAll(',', ''));
    } catch (e) {
      print("Error parsing price: $e");
      return;
    }

    String description = detailController.text;
    int categoryId = categeryItems.indexOf(_selectedItem);

    try {
      Response response = await apiService.patchPost(
        postId: widget.product.postId,
        categoryId: categoryId,
        description: description,
        price: price,
        title: title,
      );

      print(response);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHome()),
          (Route<dynamic> route) => false,
        );
      } else if (response.statusCode == 422) {
        var errorData = response.data;
        var errorDetail = errorData['detail'];
        for (var error in errorDetail) {
          var location = error['loc'];
          var errorMsg = error['msg'];
          var errorType = error['type'];

          print("Error at $location: $errorMsg (Type: $errorType)");
        }
        showPopup(context, "게시글 수정에 실패했습니다.");
      } else {
        print(
            "Error creating post. Status Code: ${response.statusCode}, Error Message: ${response.statusMessage}");
        showPopup(context, "게시글 수정에 실패했습니다.");
      }
    } catch (e) {
      print(e);
    }
  }

  bool _isSelectListVisible = false;
  String _selectedItem = '';

  bool isFree = false;
  bool _showPrice = false;
  List<dynamic> recommendedPriceList = [0, 0, 0];
  bool recommendedAlready = false;
  bool isAiLoading = false;


  void getRecommendedPrice() async {
    if (isAiLoading) return;
    if (_imageList.isEmpty) {
      showPopup(context, "물품 사진을 1개 이상 입력해주세요");
      return;
    }
    if (productNameController.text.isEmpty) {
      showPopup(context, "물품 이름을 입력해주세요");
      return;
    }
    showPopup(context, "가격 추천 중입니다...");

    setState(() {
      isAiLoading = true;
    });

    try {
      File imageFile = File(_imageList[0]);
      print(imageFile);

      Response response = await ApiService()
          .getPriceRecommended(productNameController.text, imageFile);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        setState(() {
          // recommendedAlready = true;
          recommendedPriceList = data;
          _showPrice = true;
        });
      }
    } catch (e) {
      print(e);
      if (!mounted) return;
      showPopup(context, "가격 추천에 실패했습니다.");
    }

    setState(() {
      isAiLoading = false;
    });
  }

  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('수정하기'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (isImageUploaded ||
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFBEBCBC), // Divider color
            height: 1.0, // Divider thickness
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
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

  Widget _imagePickerSection(BuildContext context) {
    // Directly use _imageList to build the image picker section
    if (_imageList.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _imageList.length,
                        (index) => _imagePreview(_imageList[index]),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    else {
      // Display a message or a loading indicator if _imageList is empty
      return const Text('이미지가 없어요!');
    }
  }

  Widget _imagePreview(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath.startsWith('http')
              ? Image.network(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(imagePath),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
        ),
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
                  children: categeryItems
                      .where((category) => category.isNotEmpty)
                      .map((category) {
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
                    onChanged: (bool? value) {
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
                  const Icon(Icons.error, color: Color(0xFFE20529), size: 12),
                  const SizedBox(width: 4),
                  Text(productDescriptionError!,
                      style: const TextStyle(
                          color: Color(0xFFE20529), fontSize: 12)),
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

  // 수정 버튼
  Widget _submitButton(BuildContext context, Size screenSize) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 35),
      child: ElevatedButton(
        onPressed: () {
          _setFieldErrors();

          if (isButtonEnabled) {
            _editNewPost();
          }
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
            '수정하기',
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
              getRecommendedPrice();
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
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Column(
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  '수정된 정보가 사라집니다!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '뒤로 가기를 누를 경우, 현재 수정 중인\n내용은 사라지고 기존 내용이 보여집니다.\n뒤로 가시겠어요?',
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
                      Navigator.of(context).pop(true);
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
                    child: const Text('뒤로 가기'),
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
                    child: const Text('계속 수정하기'),
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
