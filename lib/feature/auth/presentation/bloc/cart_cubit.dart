
import 'package:isar/isar.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import '../model/cart_item_entity.dart';
import '../model/cart_model.dart';
import '../model/product_model.dart';
// import 'cart_item_model.dart';

class CartState extends Equatable {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  // Геттер для подсчета общей суммы корзины
  double get totalPrice => items.fold(0, (total, item) => total + (item.product.price * item.quantity));

  // Геттер для подсчета общего количества всех товаров
  int get totalItems => items.fold(0, (total, item) => total + item.quantity);

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}








class CartCubit extends Cubit<CartState> {
  final Isar _isar;

  CartCubit(this._isar) : super(const CartState()) {
    _loadCart();
  }

  // Загрузка данных из Isar
  Future<void> _loadCart() async {
    final entities = await _isar.cartItemEntitys.where().findAll();
    final items = entities.map((e) => e.toModel()).toList();
    emit(state.copyWith(items: items));
  }

  // Добавление или обновление товара
  Future<void> addProduct(ProductModel product) async {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    CartItemModel updatedItem;

    if (index >= 0) {
      updatedItem = items[index].copyWith(quantity: items[index].quantity + 1);
      items[index] = updatedItem;
    } else {
      updatedItem = CartItemModel(product: product, quantity: 1);
      items.add(updatedItem);
    }

    emit(state.copyWith(items: items));

    // Сохраняем в Isar
    final entity = CartItemEntity.fromModel(updatedItem);
    await _isar.writeTxn(() async {
      await _isar.cartItemEntitys.put(entity); // put обновляет запись, если id совпадает (благодаря @Index(replace: true))
    });
  }

  // Уменьшение количества или удаление товара
  Future<void> removeProduct(ProductModel product) async {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (items[index].quantity > 1) {
        final updatedItem = items[index].copyWith(quantity: items[index].quantity - 1);
        items[index] = updatedItem;
        emit(state.copyWith(items: items));

        // Обновляем в Isar
        final entity = CartItemEntity.fromModel(updatedItem);
        await _isar.writeTxn(() async {
          await _isar.cartItemEntitys.put(entity);
        });
      } else {
        items.removeAt(index);
        emit(state.copyWith(items: items));

        // Удаляем из Isar по productId
        await _isar.writeTxn(() async {
          await _isar.cartItemEntitys.deleteByProductId(product.id);
        });
      }
    }
  }

  // Очистка всей корзины (после заказа)
  Future<void> clearCart() async {
    emit(state.copyWith(items: []));
    await _isar.writeTxn(() async {
      await _isar.cartItemEntitys.clear();
    });
  }
}