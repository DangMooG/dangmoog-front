import 'package:dangmoog/screens/auth/welcome.dart';
import 'package:flutter/material.dart';
import '../../../models/product_class.dart';
//import '../../widgets/post/detail_page.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  const ProductList({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) {
        return ChangeNotifierProvider<Product>.value(
          value: products[i],
          child: _buildProductCard(context),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context) {
    return Consumer<Product>(
      builder: (context, product, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage()
              ),
            );
          },
          child: Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImage(product),
                _buildProductDetails(product),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(Product product) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Image.asset(product.imageUrl, fit: BoxFit.cover),
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
            _buildTitleAndFavIcon(product),
            _buildCategoryAndTime(product),
            Text('${product.price.toStringAsFixed(2)}원'),
            // _buildComments(product),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndFavIcon(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(product.title),
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
    );
  }

  Widget _buildCategoryAndTime(Product product) {
    return Row(
      children: [
        Text("${product.category} "),
        Text("| ${timeAgo(product.uploadTime)}"),
      ],
    );
  }

  Widget _buildComments(Product product) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.comment),
            Text('${product.comments.length}'),
          ],
        ),
      ),
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
