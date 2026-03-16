import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/feature/auth/presentation/screen/home_screen.dart';
import 'package:shop/feature/auth/presentation/screen/navigation_screen.dart';
import 'package:shop/feature/auth/presentation/screen/sign_up_screen.dart';
import '../bloc/auth_cubit.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Инициализируем контроллеры из твоей логики
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
            );
            // Здесь можно добавить навигацию на Home Screen
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView( // Чтобы клавиатура не закрывала поля
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Center(
                    child: Image(
                      image: AssetImage('assets/carrot_logo.png'),
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text("Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Enter your email and password", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),

                  // Текстовые поля с контроллерами
                  CustomTextField(
                    label: "Email",
                    controller: _emailController,
                    hint: "imshuvo97@gmail.com",
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    label: "Password",
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  // Забыли пароль
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      text: "Forgot Password?",
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Основная кнопка входа с логикой Bloc
                  PrimaryButton(
                    text: "Log In",
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      context.read<AuthCubit>().login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Переход на SignUp (из твоей логики)
                  Center(
                    child: CustomTextButton(
                      text: "Don't have an account?",
                      actionText: "Signup",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



// --- Кастомное текстовое поле ---
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isPassword;
  final TextEditingController controller; // Теперь контроллер обязателен

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Colors.grey) : null,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF71B07D))),
          ),
        ),
      ],
    );
  }
}

// --- Основная кнопка с состоянием загрузки ---
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF71B07D),
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// --- Текстовая кнопка (Забыли пароль / Регистрация) ---
class CustomTextButton extends StatelessWidget {
  final String text;
  final String? actionText;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    this.actionText,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          children: [
            if (actionText != null)
              TextSpan(
                text: ' $actionText',
                style: const TextStyle(color: Color(0xFF71B07D), fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
