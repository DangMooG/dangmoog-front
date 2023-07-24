import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dangmoog/models/product_class.dart';
// import 'package:dangmoog/screens/post/post_list.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Product>.value(
      value: product,
      child: Consumer<Product>(
        builder: (context, product, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('돌아가기'),
            ),
            body: Column(
              children: <Widget>[
                _buildProductImage(context),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 8.0, right: 8.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTopInfoRow(context, product),
                      const SizedBox(
                          height: 8.0), // Add a gap of 8.0 logical pixels
                      _buildProductTitle(product),
                      const SizedBox(
                          height: 8.0), // Add a gap of 8.0 logical pixels
                      _buildProductPrice(product),
                      const SizedBox(
                          height: 8.0), // Add a gap of 8.0 logical pixels
                      _buildSellerName(product),
                      const SizedBox(
                          height: 8.0), // Add a gap of 8.0 logical pixels
                      _buildProductDetails(product),
                      const SizedBox(
                          height: 8.0), // Add a gap of 8.0 logical pixels
                      _buildProductDescription(product),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildChatButton(),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(product.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTopInfoRow(BuildContext context, Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
              product.isFavorited ? Icons.favorite : Icons.favorite_border),
          color: Colors.red,
          onPressed: () {
            product.isFavorited = !product.isFavorited;
            product.notifyListeners();
          },
        ),
        Text(
          '${timeAgo(product.uploadTime)} | ${product.viewCount} views | ${product.likes} likes',
        ),
      ],
    );
  }

  Widget _buildProductTitle(Product product) {
    return Text(
      product.title,
      style: const TextStyle(fontSize: 24),
    );
  }

  Widget _buildProductPrice(Product product) {
    return Text(
      '${product.price.toStringAsFixed(2)}원',
      style: const TextStyle(fontSize: 18, color: Colors.black),
    );
  }

  Widget _buildSellerName(Product product) {
    return Text(
      product.user,
      style: const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Text(
      '${product.category} | ${product.saleMethod} | ${timeAgo(product.uploadTime)}',
      style: const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _buildProductDescription(Product product) {
    return Text(
      product.description,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildChatButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // handle chat logic
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          minimumSize:
              MaterialStateProperty.all<Size>(const Size(double.infinity, 50)),
        ),
        child: const Text('바로 채팅하기'),
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
