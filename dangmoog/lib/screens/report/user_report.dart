import 'package:dangmoog/models/product_class.dart';
import 'package:flutter/material.dart';

// Assuming ProductModel is defined somewhere in your project

class UserReportPage extends StatefulWidget {
  final ProductModel product;

  UserReportPage({Key? key, required this.product}) : super(key: key);

  @override
  _PostReportPageState createState() => _PostReportPageState();
}

class _PostReportPageState extends State<UserReportPage> {
  // Add any state variables and methods here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 신고'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Report for: ${widget.product.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add more widgets here for the report functionality
          ],
        ),
      ),
    );
  }
}
