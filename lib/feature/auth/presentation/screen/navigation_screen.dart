import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/bloc/auth_cubit.dart';





class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().logOut();
          },
          child: const Text('Выйти из аккаунта'),
        ),
      ),
    );
  }
}
