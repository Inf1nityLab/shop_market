
// Не забудь импортировать твой ProductModel
// import 'product_model.dart';

import 'package:shop/feature/auth/presentation/model/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  CartItemModel copyWith({ProductModel? product, int? quantity}) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemModel({required this.productId, required this.productName, required this.quantity, required this.price});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'],
      productName: json['products']['name'],
      quantity: json['quantity'],
      price: (json['price_at_time'] as num).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final double finalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({required this.id, required this.finalAmount, required this.status, required this.createdAt, required this.items});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      finalAmount: (json['final_amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['order_items'] as List).map((i) => OrderItemModel.fromJson(i)).toList(),
    );
  }
}