

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/screen/navigation_screen.dart';

import '../bloc/auth_cubit.dart';
import 'home_screen.dart';
import 'login_scree.dart';
// import 'auth_cubit.dart';
// import 'auth_state.dart';
// import 'login_scree.dart';
// import 'home_screen.dart'; // Подключите ваш экран

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Запускаем проверку при загрузке экрана
    context.read<AuthCubit>().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Авторизован -> Идем на главный экран
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthUnauthenticated || state is AuthError) {
          // Не авторизован -> Идем на логин
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          // Простой UI для загрузки
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

