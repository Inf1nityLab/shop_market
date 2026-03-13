

// category_model.dart
class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

// product_model.dart
class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final num weightValue;
  final String weightUnit;
  final List<String> images;
  final Map<String, dynamic> nutritions;

  ProductModel({
    required this.id, required this.categoryId, required this.name,
    required this.description, required this.price, required this.weightValue,
    required this.weightUnit, required this.images, required this.nutritions,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      weightValue: json['weight_value'] as num,
      weightUnit: json['weight_unit'],
      images: List<String>.from(json['images'] ?? []),
      nutritions: json['nutritions'] as Map<String, dynamic>? ?? {},
    );
  }
}