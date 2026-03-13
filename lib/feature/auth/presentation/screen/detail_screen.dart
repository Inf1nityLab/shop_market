
import 'package:flutter/material.dart';

import '../model/product_model.dart';
// Импорт модели

class DetailScreen extends StatelessWidget {
  final ProductModel product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Картинка товара
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: product.images.isNotEmpty
                  ? Image.network(product.images.first, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood, size: 100),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${product.weightValue} ${product.weightUnit}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('${product.price} сом', style: const TextStyle(fontSize: 22, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Описание:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.description),
            const SizedBox(height: 16),
            const Text('Пищевая ценность:', style: TextStyle(fontWeight: FontWeight.bold)),
            // Вывод JSONB данных
            if (product.nutritions.isNotEmpty) ...[
              Text('Калории: ${product.nutritions['calories'] ?? 0} ккал'),
              Text('Белки: ${product.nutritions['protein'] ?? 0} г'),
              Text('Жиры: ${product.nutritions['fat'] ?? 0} г'),
              Text('Углеводы: ${product.nutritions['carbs'] ?? 0} г'),
            ],
          ],
        ),
      ),
    );
  }
}