import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../bloc/cart_cubit.dart';
import '../bloc/checkout_cubit.dart';

// import 'cart_cubit.dart';
// import 'cart_state.dart';

// CartScreen
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        print('[UI_CART] Rebuilding Cart. Items: ${state.items.length}');
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
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          print('[UI_CART] Removing ${item.product.name}');
                          context.read<CartCubit>().removeProduct(item.product);
                        }
                    ),
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
                  ElevatedButton(
                      onPressed: () {
                        print('[UI_CART] Opening Checkout Sheet');
                        _showCheckout(context, state);
                      },
                      child: const Text('Checkout')
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void _showCheckout(BuildContext context, CartState cartState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (context) => CheckoutCubit(),
        child: CheckoutSheet(cartState: cartState),
      ),
    );
  }
}

class CheckoutSheet extends StatefulWidget {
  final CartState cartState;
  const CheckoutSheet({super.key, required this.cartState});
  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _promo = TextEditingController();
  String _deliv = 'Delivery'; String _pay = 'Cash'; String? _bank;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.status == CheckoutStatus.success) {
          print('[UI_CHECKOUT] Order Successful! Closing sheet and clearing cart.');
          context.read<CartCubit>().clearCart();
          Navigator.pop(context);
        }
        if (state.status == CheckoutStatus.error) {
          print('[UI_CHECKOUT] Error SnackBar: ${state.error}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error ?? 'Error')));
        }
      },
      builder: (context, state) {
        double discount = (widget.cartState.totalPrice * state.discountPercent) / 100;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Телефон')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Адрес')),
              DropdownButton<String>(value: _deliv, items: ['Delivery', 'Pickup'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_deliv=v!)),
              DropdownButton<String>(value: _pay, items: ['Cash', 'Card'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_pay=v!)),
              Row(children: [
                Expanded(child: TextField(controller: _promo, decoration: const InputDecoration(hintText: 'Промокод'))),
                IconButton(onPressed: () {
                  print('[UI_CHECKOUT] Click: Check Promo ${_promo.text}');
                  context.read<CheckoutCubit>().checkPromo(_promo.text);
                }, icon: const Icon(Icons.check))
              ]),
              Text('Итого: ${widget.cartState.totalPrice - discount} сом', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              state.status == CheckoutStatus.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: () {
                    print('[UI_CHECKOUT] Click: Place Order');
                    context.read<CheckoutCubit>().confirmOrder({
                      'delivery': _deliv,
                      'payment': _pay,
                      'address': _address.text,
                      'phone': _phone.text,
                      'items': widget.cartState.items,
                      'promoCode': _promo.text,
                      'bank': _bank,
                    });
                  },
                  child: const Text('Заказать')
              )
            ],
          ),
        );
      },
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderHistoryCubit()..loadOrders(),
      child: Scaffold(
        body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          builder: (context, state) {
            print('[UI_HISTORY] Building list. Status: ${state.status}');
            if (state.status == OrderHistoryStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.orders.isEmpty) return const Center(child: Text('История пуста'));

            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, i) {
                final o = state.orders[i];
                return ExpansionTile(
                  title: Text('Заказ #${o.id.substring(0,5)} - ${o.finalAmount} сом'),
                  subtitle: Text('Статус: ${o.status} | ${o.createdAt.toLocal()}'),
                  children: o.items.map((it) => ListTile(title: Text(it.productName), trailing: Text('${it.quantity} шт'))).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
