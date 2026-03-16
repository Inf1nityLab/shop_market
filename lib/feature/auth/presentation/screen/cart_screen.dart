import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_cubit.dart';

// import 'cart_cubit.dart';
// import 'cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Корзина пуста'));
            }

            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final cartItem = state.items[index];
                final product = cartItem.product;

                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: product.images.isNotEmpty
                        ? Image.network(product.images.first, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood),
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.price} сом'),
                  // Используем тот же виджет - 1 +, но пересобранный для ListTile
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            context.read<CartCubit>().removeProduct(product),
                      ),
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            context.read<CartCubit>().addProduct(product),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Итого:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${state.totalPrice} сом',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Логика оформления заказа
                          showDialog(context: context, builder: (context)=> AlertDialog(
                            title: Text('Заказать'),
                            content: Column(
                              mainAxisSize: .min,
                              children: [
                                TextFormField(),

                                ElevatedButton(onPressed: (){}, child: Text('Заказать'))
                              ],

                            ),

                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Оформить'),
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
  }
}
