// /screens/post/post_list.dart

import 'package:flutter/material.dart';
import '../../../models/product_class.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: Container(
          width: 60,
          height: 60,
          child: Image.asset(products[i].imageUrl, fit: BoxFit.cover),
        ),
        title: Text(products[i].title),
        subtitle: Text(products[i].description),
        trailing: Text('\$${products[i].price}'),
      ),
      
    );
  }
}

