import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_cubit.dart';

// import 'cart_cubit.dart';
// import 'cart_state.dart';

// CartScreen
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const Center(child: Text('Cart is empty'));
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (c, i) {
                  final item = state.items[i];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('${item.product.price} x ${item.quantity}'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => context.read<CartCubit>().removeProduct(item.product)),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Total: ${state.totalPrice} сом', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ElevatedButton(onPressed: () {}, child: const Text('Checkout'))
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
