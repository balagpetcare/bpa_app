import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';

// ✅ আপনার প্রকৃত HomeScreen path দিন:
import 'package:bpa_app/features/home/presentation/screens/bpa_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(); // email OR mobile
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  late final LoginUseCase _loginUseCase;

  @override
  void initState() {
    super.initState();
    final remote = AuthRemoteDataSource();
    final repo = AuthRepositoryImpl(remote);
    _loginUseCase = LoginUseCase(repo);
  }

  String? _idValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please enter email or mobile';
    final isEmail = s.contains('@');
    final isPhone = RegExp(r'^[0-9]+$').hasMatch(s);
    if (!isEmail && !isPhone) return 'Enter a valid email or phone number';
    return null;
  }

  String? _passValidator(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Please enter password';
    if (s.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _loginUseCase.execute(
        identifier: _idController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BPAHomeScreen()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('Exception')
          ? e.toString().split('Exception: ').last
          : 'Login failed. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E60AA);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthHeader(
                    title: "Welcome Back!",
                    subtitle: "Sign in to continue to BPA",
                    titleColor: primary,
                    logoHeight: 80,
                  ),
                  const SizedBox(height: 30),

                  // ✅ Email or Mobile field (আগের login ডিজাইন + new hint)
                  AuthTextField(
                    controller: _idController,
                    hintText: 'Email or Mobile',
                    prefixIcon: Icons.email_outlined,
                    radius: 15,
                    borderNone: true,
                    validator: _idValidator,
                  ),
                  const SizedBox(height: 15),

                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    radius: 15,
                    borderNone: true,
                    validator: _passValidator,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  AuthButton(
                    text: 'Login',
                    loading: _isLoading,
                    onPressed: _handleLogin,
                    color: primary,
                    radius: 15,
                    height: 55,
                    elevation: 3,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Or connected with",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _social(FontAwesomeIcons.google, Colors.red, () {}),
                      const SizedBox(width: 15),
                      _social(
                        FontAwesomeIcons.facebookF,
                        const Color(0xFF1877F2),
                        () {},
                      ),
                      const SizedBox(width: 15),
                      _social(
                        FontAwesomeIcons.instagram,
                        const Color(0xFFE1306C),
                        () {},
                      ),
                      const SizedBox(width: 15),
                      _social(FontAwesomeIcons.tiktok, Colors.black, () {}),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Create",
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _social(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
