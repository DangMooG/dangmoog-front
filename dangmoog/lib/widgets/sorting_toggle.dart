import 'package:dangmoog/models/product_class.dart';
import 'package:dangmoog/screens/mypage/my_post_list.dart';
import 'package:flutter/material.dart';

class ProductListSorting extends StatefulWidget {
  final List<ProductModel> productList;
  final SortingOrder sortingOrder;
  final Function(SortingOrder) onSortingChanged;
  final Function(bool, bool, bool) onSorting1Changed;

  const ProductListSorting(
      {Key? key,
      required this.productList,
      required this.sortingOrder,
      required this.onSortingChanged,
      required this.onSorting1Changed})
      : super(key: key);

  @override
  State<ProductListSorting> createState() => _ProductListSortingState();
}

class _ProductListSortingState extends State<ProductListSorting> {
  SortingOrder sorting = SortingOrder.descending;
  bool sortByDealStatus = false;
  bool sortByDealStatus2 = false;
  bool sortByDealStatus3 = false;

  int index = 0;

  void _toggleSortingOrder() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = false;
      sortByDealStatus3 = false;

      sorting = SortingOrder.descending;
      widget.onSortingChanged(sorting);
      widget.onSorting1Changed(
          sortByDealStatus, sortByDealStatus2, sortByDealStatus3);
    });
  }

  void _toggleSortByDealStatus2() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = true;
      sortByDealStatus3 = false;
      widget.onSorting1Changed(
          sortByDealStatus, sortByDealStatus2, sortByDealStatus3);
    });
  }

  void _toggleSortByDealStatus3() {
    setState(() {
      sortByDealStatus = false;
      sortByDealStatus2 = false;
      sortByDealStatus3 = true;
      widget.onSorting1Changed(
          sortByDealStatus, sortByDealStatus2, sortByDealStatus3);
    });
  }

  void _toggleSortByDealStatus() {
    setState(() {
      sortByDealStatus = true;
      sortByDealStatus2 = false;
      sortByDealStatus3 = false;
      widget.onSorting1Changed(
          sortByDealStatus, sortByDealStatus2, sortByDealStatus3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttonList = ['전체', '거래중', '예약중', '거래완료'];

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(5),
          minimumSize: const Size(40, 24),
          side: const BorderSide(
            color: Color(0xFFE20529), // 원하는 border 색상 설정
            width: 1.0, // border의 두께 설정
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0), // 버튼의 모서리를 둥글게 설정
          ),
          surfaceTintColor: Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              buttonList[index],
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFE20529)),
            ),
            const Icon(
              Icons.keyboard_arrow_down_sharp,
              color: Color(0xFFE20529),
              size: 16,
            ),
          ],
        ),
        onPressed: () {
          _accountPopup(context, index);
        },
      ),
    );
  }

  Future<void> _accountPopup(BuildContext context, int currentindex) async {
    Size screenSize = MediaQuery.of(context).size;
    int newindex = currentindex;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: SizedBox(
            width: 270,
            height: screenSize.height * 0.226,
            child: Column(
              children: [
                CustomTextButtonWithBorder(
                  text: '전체보기',
                  onPressed: () {
                    _toggleSortingOrder();
                    Navigator.of(context).pop();
                    newindex = 0;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '거래중',
                  onPressed: () {
                    _toggleSortByDealStatus2();
                    Navigator.of(context).pop();
                    newindex = 1;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '예약중',
                  onPressed: () {
                    _toggleSortByDealStatus3();
                    Navigator.of(context).pop();
                    newindex = 2;
                  },
                  height: screenSize.height * 0.044,
                ),
                CustomTextButtonWithBorder(
                  text: '거래완료',
                  onPressed: () {
                    _toggleSortByDealStatus();
                    Navigator.of(context).pop();
                    newindex = 3;
                  },
                  height: screenSize.height * 0.044,
                ),
                SizedBox(
                  height: screenSize.height * 0.044,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        const Size(375, 36), // 크기를 원하는대로 설정
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA19E9E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() {
      index = newindex; // 인덱스 업데이트를 상태 변경과 함께 수행
    });
  }
}

class CustomTextButtonWithBorder extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const CustomTextButtonWithBorder({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // 원하는 색상 설정
            width: 0.5, // 라인 두께 설정
          ),
        ),
      ),
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(
            Size(375, height), // 크기를 원하는대로 설정
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE20529),
          ),
        ),
      ),
    );
  }
}
