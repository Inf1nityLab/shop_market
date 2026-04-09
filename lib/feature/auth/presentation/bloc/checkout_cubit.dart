
import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/cart_model.dart';
enum CheckoutStatus { initial, loading, success, error }

class OrderRepository {
  final _supabase = Supabase.instance.client;

  Future<void> placeOrder({
    required String delivery,
    required String payment,
    required String address,
    required String phone,
    required List<CartItemModel> cartItems,
    String? promoCode,
    String? bank,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final itemsJson = cartItems.map((e) => {
      'product_id': e.product.id,
      'quantity': e.quantity,
      'price': e.product.price,
    }).toList();

    print('[ORDER_REPO] Starting RPC create_order_v3');
    print('[ORDER_REPO] Payload: {user: $userId, items_count: ${itemsJson.length}, promo: $promoCode}');

    try {
      await _supabase.rpc('create_order_v3', params: {
        'p_user_id': userId,
        'p_delivery_method': delivery,
        'p_payment_method': payment,
        'p_bank_name': bank,
        'p_delivery_address': address,
        'p_contact_phone': phone,
        'p_promo_code': promoCode,
        'p_items': itemsJson,
      });
      print('[ORDER_REPO] SUCCESS: Order created in Database');
    } catch (e) {
      print('[ORDER_REPO] ERROR: Failed to create order: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> fetchOrders() async {
    print('[ORDER_REPO] Fetching orders for user: ${_supabase.auth.currentUser?.id}');
    final response = await _supabase
        .from('orders')
        .select('*, order_items(*, products(name))')
        .order('created_at', ascending: false);

    final orders = (response as List).map((e) => OrderModel.fromJson(e)).toList();
    print('[ORDER_REPO] Fetched ${orders.length} orders');
    return orders;
  }
}






class CheckoutState {
  final CheckoutStatus status;
  final double discountPercent;
  final String? error;
  CheckoutState({this.status = CheckoutStatus.initial, this.discountPercent = 0, this.error});
  CheckoutState copyWith({CheckoutStatus? status, double? discountPercent, String? error}) =>
      CheckoutState(status: status ?? this.status, discountPercent: discountPercent ?? this.discountPercent, error: error ?? this.error);
}

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutState());
  final _supabase = Supabase.instance.client;

  Future<void> checkPromo(String code) async {
    print('[CHECKOUT_CUBIT] Checking promo code: $code');
    try {
      final res = await _supabase.from('promo_codes').select().eq('code', code).eq('is_active', true).maybeSingle();
      if (res != null) {
        final pct = (res['discount_percent'] as int).toDouble();
        print('[CHECKOUT_CUBIT] Promo Valid: $pct%');
        emit(state.copyWith(discountPercent: pct));
      } else {
        print('[CHECKOUT_CUBIT] Promo Invalid or Expired');
      }
    } catch (e) {
      print('[CHECKOUT_CUBIT] Promo Check Error: $e');
    }
  }

  Future<void> confirmOrder(Map<String, dynamic> data) async {
    print('[CHECKOUT_CUBIT] Confirming order...');
    emit(state.copyWith(status: CheckoutStatus.loading));
    try {
      await OrderRepository().placeOrder(
        delivery: data['delivery'],
        payment: data['payment'],
        address: data['address'],
        phone: data['phone'],
        cartItems: data['items'],
        promoCode: data['promoCode'],
        bank: data['bank'],
      );
      print('[CHECKOUT_CUBIT] Status: SUCCESS');
      emit(state.copyWith(status: CheckoutStatus.success));
    } catch (e) {
      print('[CHECKOUT_CUBIT] Status: ERROR ($e)');
      emit(state.copyWith(status: CheckoutStatus.error, error: e.toString()));
    }
  }
}

// --- Order History Cubit ---
enum OrderHistoryStatus { loading, success, error }
class OrderHistoryState {
  final OrderHistoryStatus status;
  final List<OrderModel> orders;
  OrderHistoryState({this.status = OrderHistoryStatus.loading, this.orders = const []});
}

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit() : super(OrderHistoryState());
  Future<void> loadOrders() async {
    print('[HISTORY_CUBIT] Loading history...');
    try {
      final orders = await OrderRepository().fetchOrders();
      emit(OrderHistoryState(status: OrderHistoryStatus.success, orders: orders));
    } catch (e) {
      print('[HISTORY_CUBIT] Error: $e');
      emit(OrderHistoryState(status: OrderHistoryStatus.error));
    }
  }
}