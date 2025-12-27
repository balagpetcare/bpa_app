import 'package:bpa_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme, // ✅
      home: SplashScreen(),
    );
  }
}
