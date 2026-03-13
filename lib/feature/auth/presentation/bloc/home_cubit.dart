import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:equatable/equatable.dart';

import '../model/product_model.dart';
// Импорт ваших моделей

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final List<ProductModel> products;
  final bool hasReachedMax; // Флаг конца списка для пагинации
  final String errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.selectedCategoryId,
    this.products = const [],
    this.hasReachedMax = false,
    this.errorMessage = '',
  });

  HomeState copyWith({
    HomeStatus? status,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    List<ProductModel>? products,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    selectedCategoryId,
    products,
    hasReachedMax,
    errorMessage,
  ];
}


class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  final _supabase = Supabase.instance.client;
  final int _limit = 6;

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // 1. Получаем категории из базы
      final categoriesData = await _supabase.from('categories').select().order('created_at');
      final fetchedCategories = categoriesData.map((e) => CategoryModel.fromJson(e)).toList();

      // 2. Создаем виртуальную категорию "Все" и ставим её первой
      final allCategory = CategoryModel(id: 'all', name: 'Все');
      final categories = [allCategory, ...fetchedCategories];

      emit(state.copyWith(
        categories: categories,
        selectedCategoryId: 'all', // Делаем "Все" выбранной по умолчанию
        products: [],
        hasReachedMax: false,
      ));

      // 3. Грузим товары
      await fetchProducts();
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    emit(state.copyWith(
      selectedCategoryId: categoryId,
      products: [],
      hasReachedMax: false,
      status: HomeStatus.loading, // Можно убрать, если хотите чтобы лоадер был только снизу
    ));

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    if (state.hasReachedMax) return;

    try {
      final currentLength = state.products.length;
      final categoryId = state.selectedCategoryId;

      if (categoryId == null) return;

      // Базовый запрос
      var query = _supabase.from('products').select();

      // Если выбрана конкретная категория (не "Все"), добавляем фильтр
      if (categoryId != 'all') {
        query = query.eq('category_id', categoryId);
      }

      // Добавляем пагинацию к итоговому запросу
      final response = await query.range(currentLength, currentLength + _limit - 1);

      final newProducts = response.map((e) => ProductModel.fromJson(e)).toList();

      emit(state.copyWith(
        status: HomeStatus.success,
        products: [...state.products, ...newProducts],
        hasReachedMax: newProducts.length < _limit,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
