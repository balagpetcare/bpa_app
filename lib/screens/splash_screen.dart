import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slideUp;

  static const Color _primaryBlue = Color(0xFF1E60AA);
  static const Color _gold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BPAHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF6FAFF),
                  Color(0xFFEAF3FF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Soft blob shapes (premium vibe)
          Positioned(
            top: -90,
            left: -70,
            child: _softBlob(size: 220, color: _primaryBlue.withOpacity(0.18)),
          ),
          Positioned(
            bottom: -110,
            right: -80,
            child: _softBlob(size: 260, color: _gold.withOpacity(0.18)),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slideUp,
                  child: ScaleTransition(
                    scale: _scale,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width * 0.88),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glass card container
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Doctor Image
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Image.asset(
                                    'assets/images/doctor.png',
                                    height: 220,
                                    width: 220,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // App Name
                                const Text(
                                  "Bangladesh Pet Association",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: _primaryBlue,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Tagline
                                Text(
                                  "We care your love",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Premium loading row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                        color: _primaryBlue,
                                        backgroundColor: _primaryBlue
                                            .withOpacity(0.12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Loading pet joy...",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.55),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Footer small text
                          Text(
                            "BPA Super App • Premium Pet Community",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.45),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softBlob({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}
