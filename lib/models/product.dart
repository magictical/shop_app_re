import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String description;
  final double price;
  final String imageUrl;
  final String title;
  bool isFavorite;

  Product({
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.id,
    @required this.imageUrl,
    this.isFavorite,
  });
}