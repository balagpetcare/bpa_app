import 'package:flutter/material.dart';
import 'app/router/app_router.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
