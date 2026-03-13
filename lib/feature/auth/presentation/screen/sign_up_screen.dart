import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/screen/home_screen.dart';

import '../bloc/auth_cubit.dart';
// Импорты ваших файлов

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          } else if (state is AuthError) {
            // Ошибка: показ снекбара
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          // Дизайн оставлен без изменений 1 в 1
          return Column(
            spacing: 15,
            children: [
              TextFormField(controller: _nameController),
              TextFormField(controller: _emailController),
              TextFormField(controller: _passwordController, obscureText: true),
              ElevatedButton(
                onPressed: state is AuthLoading
                    ? null
                    : () {
                  context.read<AuthCubit>().signUp(
                    userName: _nameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                },
                child: Text(state is AuthLoading ? 'Loading...' : 'Sign up'),
              ),
              TextButton(
                onPressed: () {
                  // Навигация на экран логина
                },
                child: const Text('login'),
              ),
            ],
          );
        },
      ),
    );
  }
}
