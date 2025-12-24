import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const BpaApp());
}

class BpaApp extends StatelessWidget {
  const BpaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BPA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
     home: const SplashScreen(),
    );
  }
}