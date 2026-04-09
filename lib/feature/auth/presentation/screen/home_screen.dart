import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_cubit.dart';
import '../bloc/home_cubit.dart';
import 'cart_screen.dart';
import 'navigation_screen.dart';


// MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  final _screens = [const HomeScreen(), const CartScreen(), const Scaffold(body: Center(child: Text('Favorites'))), const AccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Fav'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadInitialData();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.8) context.read<HomeCubit>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            // Простейшие категории
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.length,
                itemBuilder: (c, i) => TextButton(
                  onPressed: () => context.read<HomeCubit>().selectCategory(state.categories[i].id),
                  child: Text(state.categories[i].name, style: TextStyle(color: state.selectedCategoryId == state.categories[i].id ? Colors.green : Colors.black)),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: _scroll,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
                itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (c, i) {
                  if (i >= state.products.length) return const Center(child: CircularProgressIndicator());
                  final p = state.products[i];
                  return Card(
                    child: Column(
                      children: [
                        Expanded(child: p.images.isNotEmpty ? Image.network(p.images.first) : const Icon(Icons.image)),
                        Text(p.name, maxLines: 1),
                        Text('${p.price} сом'),
                        // Кнопка корзины
                        BlocBuilder<CartCubit, CartState>(builder: (context, cartState) {
                          final itemIdx = cartState.items.indexWhere((it) => it.product.id == p.id);
                          return itemIdx == -1
                              ? ElevatedButton(onPressed: () => context.read<CartCubit>().addProduct(p), child: const Text('Add'))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            IconButton(onPressed: () => context.read<CartCubit>().removeProduct(p), icon: const Icon(Icons.remove)),
                            Text('${cartState.items[itemIdx].quantity}'),
                            IconButton(onPressed: () => context.read<CartCubit>().addProduct(p), icon: const Icon(Icons.add)),
                          ]);
                        })
                      ],
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
