

import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:shop/feature/auth/presentation/model/product_model.dart';

import 'cart_model.dart';
// Импортируй твою модель
// import 'product_model.dart';
// import 'cart_item_model.dart';

part 'cart_item_entity.g.dart'; // Этот файл будет сгенерирован

@collection
class CartItemEntity {
  Id id = Isar.autoIncrement; // Внутренний ID для Isar

  @Index(unique: true, replace: true)
  late String productId; // UUID товара из Supabase

  late String name;
  late double price;
  late int quantity;
  late String weightUnit;
  late double weightValue;
  late List<String> images;

  // Isar не поддерживает Map, поэтому храним нутриенты как строку
  late String nutritionsJson;

  // Метод для конвертации из Entity обратно в твою рабочую модель CartItemModel
  CartItemModel toModel() {
    return CartItemModel(
      product: ProductModel(
        id: productId,
        categoryId: '', // Для корзины категория обычно не нужна
        name: name,
        description: '', // Описание тоже можно опустить для экономии памяти
        price: price,
        weightValue: weightValue,
        weightUnit: weightUnit,
        images: images,
        nutritions: jsonDecode(nutritionsJson),
      ),
      quantity: quantity,
    );
  }

  // Фабрика для создания Entity из твоей модели
  static CartItemEntity fromModel(CartItemModel item) {
    return CartItemEntity()
      ..productId = item.product.id
      ..name = item.product.name
      ..price = item.product.price
      ..quantity = item.quantity
      ..weightUnit = item.product.weightUnit
      ..weightValue = item.product.weightValue.toDouble()
      ..images = item.product.images
      ..nutritionsJson = jsonEncode(item.product.nutritions);
  }
}