import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop/feature/auth/presentation/bloc/home_cubit.dart';
import 'package:shop/feature/auth/presentation/screen/category.dart';
import 'package:shop/feature/auth/presentation/screen/login_scree.dart';
import 'package:shop/feature/auth/presentation/screen/sign_up_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Не забудьте импортировать ваши файлы
// import 'auth_cubit.dart';
// import 'login_scree.dart';

Future<void> main() async {
  // Обязательно для асинхронного main в Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Supabase
  await Supabase.initialize(
    url: 'https://cmhwxpowyhecaymjgrxw.supabase.co', // Замените на ваш URL из настроек проекта Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtaHd4cG93eWhlY2F5bWpncnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyOTU0MjIsImV4cCI6MjA4ODg3MTQyMn0.AaKsfopBz0lJqAsNA_JWwb4ZdGsFYtta0MlTpQjR_FM', // Замените на ваш anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => HomeCubit())
      ],
      
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}


