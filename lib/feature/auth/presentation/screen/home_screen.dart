import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_cubit.dart';
import '../bloc/home_cubit.dart';
import '../model/product_model.dart';
import 'detail_screen.dart';
// Импорты ваших файлов

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Импорты ваших файлов
// import '../bloc/home_cubit.dart';
// import '../bloc/cart_cubit.dart';
// import '../bloc/cart_state.dart';
// import 'detail_screen.dart';
// import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Инициализируем загрузку
    context.read<HomeCubit>().loadInitialData();

    // Слушатель для пагинации
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        context.read<HomeCubit>().fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == HomeStatus.failure) {
          return Center(child: Text('Ошибка: ${state.errorMessage}'));
        }

        return Column(
          children: [
            // Категории (Горизонтальный скролл)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = category.id == state.selectedCategoryId;
                  return GestureDetector(
                    onTap: () =>
                        context.read<HomeCubit>().selectCategory(category.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Карточки товаров (GridView)
            // Карточки товаров (GridView)
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // 1. Делаем карточку более вытянутой вниз, чтобы все влезло
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount:
                state.products.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.products.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final product = state.products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias, // Закругляет края картинки
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Картинка берет на себя все оставшееся место
                          Expanded(
                            child: Container(
                              color: Colors.grey[300],
                              width: double.infinity,
                              child: product.images.isNotEmpty
                                  ? Image.network(
                                product.images.first,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.fastfood, size: 50),
                            ),
                          ),
                          // Информационный блок с жесткими ограничениями текста
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Не дает колонке расширяться
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1, // 2. Обязательно ограничиваем в 1 строку
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.weightValue} ${product.weightUnit}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.price} сом',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CartButtonWidget(product: product),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Виджет кнопки для карточки товара
class CartButtonWidget extends StatelessWidget {
  final ProductModel product;

  const CartButtonWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        // Ищем товар в корзине
        final cartItemIndex = state.items.indexWhere((item) => item.product.id == product.id);
        final inCart = cartItemIndex >= 0;
        final quantity = inCart ? state.items[cartItemIndex].quantity : 0;

        if (!inCart) {
          // Если нет в корзине — показываем кнопку добавления
          return SizedBox(
            width: double.infinity,
            height: 36, // Фиксированная высота для аккуратности
            child: ElevatedButton(
              onPressed: () => context.read<CartCubit>().addProduct(product),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('В корзину', style: TextStyle(fontSize: 13)),
            ),
          );
        }

        // Если в корзине — показываем счетчик - 1 +
        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, color: Colors.deepPurple, size: 20),
                onPressed: () => context.read<CartCubit>().removeProduct(product),
              ),
              Text(
                  '$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.deepPurple, size: 20),
                onPressed: () => context.read<CartCubit>().addProduct(product),
              ),
            ],
          ),
        );
      },
    );
  }
}
