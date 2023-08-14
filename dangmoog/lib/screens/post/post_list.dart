import 'package:dangmoog/screens/auth/welcome.dart';
import 'package:flutter/material.dart';
import '../../../models/product_class.dart';

//import '../../widgets/post/detail_page.dart';
import 'detail_page.dart';
import 'package:provider/provider.dart';
import 'package:dangmoog/screens/addpage/add_page.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  const ProductList({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: products.length,
        itemBuilder: (context, i) {
          Widget productCard = ChangeNotifierProvider<Product>.value(
            value: products[i],
            child: _buildProductCard(context),
          );
          // Apply extra padding to the first item only
          if (i == 0) {
            productCard = Padding(
              padding: const EdgeInsets.only(top: 8.0), // Set your desired padding
              child: productCard,
            );
          }

          return productCard;
        },
        separatorBuilder: (context, i) {
          return const Divider();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to UploadProductPage when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadProductPage()),
          );
        },
        child: Image.asset('assets/images/add_icon.png'),
        tooltip: 'Upload Product',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }



  Widget _buildProductCard(BuildContext context) {
    return Consumer<Product>(
      builder: (context, product, child) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage()
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildProductImage(context, product),
              _buildProductDetails(product),
            ],
          ),
        );
      },
    );
  }


  Widget _buildProductImage(BuildContext context, Product product) {
    double width = MediaQuery.of(context).size.width * 0.32; // 32% of screen width
    double paddingValue = MediaQuery.of(context).size.width * 0.042; // 4.2% of screen width

    return Padding(
      padding: EdgeInsets.only(right: paddingValue/2, bottom: paddingValue/2, left: paddingValue, top: paddingValue/2),
      child: SizedBox(
        width: width,
        height: width, // height will also be 32% of the screen width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15), // You can adjust this value for desired rounding
          child: Image.asset(product.images[0], fit: BoxFit.cover),
        ),
      ),
    );
  }



  Widget _buildProductDetails(Product product) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProductTexts(product),
                IconButton(
                  icon: Icon(
                    product.isFavorited ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: Colors.red,
                  onPressed: () {
                    product.isFavorited = !product.isFavorited;
                  },
                ),
              ],
            ),
            Text('${product.price}원',
              style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF552619)
              ),
            ),
            // _buildComments(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTexts(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title,
            style: const TextStyle(fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF552619))),
        _buildCategoryAndTime(product),
      ],
    );
  }

  Widget _buildCategoryAndTime(Product product) {
    return Row(
      children: [
        Text("${product.category} ",
              style: const TextStyle(fontFamily: 'Pretendard',
                                     fontWeight: FontWeight.w200,
                                     fontSize: 13,
                                     color: Color(0xFFA07272)),),
        Text("| ${timeAgo(product.uploadTime)}",
                style: const TextStyle(fontFamily: 'Pretendard',
                                       fontWeight: FontWeight.w200,
                                       fontSize: 13,
                                       color: Color(0xFFA07272)),
        ),
      ],
    );
  }

  String timeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} 일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} 시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} 분 전';
    } else {
      return '방금 전';
    }
  }
}
