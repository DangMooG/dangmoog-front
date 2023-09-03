import 'package:image_picker/image_picker.dart';

class NewPostModel {
  final int userId;
  final String title;
  final String description;
  final int price;
  final List<XFile>? images;
  final String category;
  final String saleMethod;

  NewPostModel({
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.saleMethod,
  });
}
