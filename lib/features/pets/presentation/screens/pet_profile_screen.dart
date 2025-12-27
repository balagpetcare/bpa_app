import 'package:flutter/material.dart';

class PetProfileScreen extends StatelessWidget {
  final int petId;

  const PetProfileScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: Text("Pet Profile #$petId"),
      ),
      body: const Center(
        child: Text(
          "Next: এখানে Pet Details API কল করে\nEdit button + sections বানাবো ✅",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
