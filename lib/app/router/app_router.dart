import 'package:flutter/material.dart';
import 'app_routes.dart';

// screens imports (refactor path অনুযায়ী)
import '../../features/home/presentation/screens/bpa_home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/shop_screen.dart';
import '../../screens/services_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../screens/create_post_screen.dart';
import 'package:bpa_app/features/pets/presentation/pet_create_screen.dart';

// import '../../features/pets/presentation/pet_list_screen.dart'; // থাকলে

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen()); // const নয়

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const BPAHomeScreen());

      case AppRoutes.shop:
        return MaterialPageRoute(builder: (_) => const ShopScreen());

      case AppRoutes.services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());

      case AppRoutes.petCreate:
        return MaterialPageRoute(builder: (_) => const PetCreateScreen());

      // case AppRoutes.petList:
      //   return MaterialPageRoute(builder: (_) => const PetListScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
