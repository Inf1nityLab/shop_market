import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';






class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Получаем инстанс клиента Supabase
  final _supabase = Supabase.instance.client;

  Future<void> login({required String email, required String password}) async {

    emit(AuthLoading());

    try {
      // Запрос на авторизацию в Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Достаем имя из метадаты (если есть), иначе ставим дефолтное
        final userName = user.userMetadata?['username'] ?? 'User';

        final authModel = AuthModel(
          id: user.id,
          userName: userName,
          email: user.email ?? email,
        );
        emit(AuthAuthenticated(authModel));
      } else {
        emit(const AuthError('Пользователь не найден'));
      }
    } on AuthException catch (e) {
      // Специфичные ошибки Supabase (например, неверный пароль)
      emit(AuthError(e.message));
    } catch (e) {
      // Любые другие ошибки
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp({required String userName, required String email, required String password}) async {
    emit(AuthLoading());
    try {
      // Запрос на регистрацию в Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': userName}, // Сохраняем имя пользователя в metadata
      );

      final user = response.user;
      if (user != null) {
        final authModel = AuthModel(
          id: user.id,
          userName: userName,
          email: user.email ?? email,
        );
        emit(AuthAuthenticated(authModel));
      } else {
        emit(const AuthError('Не удалось зарегистрировать пользователя'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Добавьте этот метод внутрь AuthCubit

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    try {
      // Имитация небольшой задержки, чтобы сплеш не мелькал слишком быстро
      await Future.delayed(const Duration(milliseconds: 1000));

      final session = _supabase.auth.currentSession;
      final user = session?.user;

      if (user != null) {
        // Достаем данные, если сессия жива
        final userName = user.userMetadata?['username'] ?? 'User';

        final authModel = AuthModel(
          id: user.id,
          userName: userName,
          email: user.email ?? '',
        );
        emit(AuthAuthenticated(authModel));
      } else {
        // Сессии нет -> отправляем на логин
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // При любой ошибке проверки сессии безопаснее отправить на логин
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logOut() async {
    emit(AuthLoading());
    try {
      // Выход из сессии Supabase
      await _supabase.auth.signOut();

      // Переводим стейт в неавторизованный
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
