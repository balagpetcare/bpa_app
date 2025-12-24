import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// উইজেট ইমপোর্ট
import 'widgets/home_app_bar.dart';
import 'widgets/story_section.dart';
import 'widgets/service_grid.dart';
import 'widgets/feed_list.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/custom_drawer.dart';

// স্ক্রিন ইমপোর্ট
import '../login_screen.dart' hide HomeAppBar;
import '../create_post_screen.dart';
import '../shop_screen.dart';
import '../services_screen.dart';
import '../profile/profile_screen.dart';

// ✅ Pet create screen import (আপনার path অনুযায়ী ঠিক করুন)
import '../pets/create_pet_screen.dart';

class BPAHomeScreen extends StatefulWidget {
  const BPAHomeScreen({super.key});

  @override
  State<BPAHomeScreen> createState() => _BPAHomeScreenState();
}

class _BPAHomeScreenState extends State<BPAHomeScreen> {
  int _selectedIndex = 0;

  String userName = "Guest";
  String userEmail = "";
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ইউজার ডাটা লোড করা
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName') ?? "Guest";
      userEmail = prefs.getString('userEmail') ?? "";
      token = prefs.getString('token');
    });
  }

  bool get _isLoggedIn => token != null && token!.isNotEmpty;

  // সোয়াইপ টু রিফ্রেশ হ্যান্ডলার
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadUserData();
  }

  // bottom nav tap
  void _onItemTapped(int index) async {
    if (index == 3) {
      // প্রোফাইলে যাওয়ার আগে টোকেন চেক
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('token');

      if (t != null && t.isNotEmpty) {
        setState(() => _selectedIndex = index);
      } else {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        ).then((_) => _loadUserData());
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  // ✅ Drawer click handler
  Future<void> _handleDrawerSelect(BPADrawerDestination dest) async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    final loggedIn = t != null && t.isNotEmpty;

    // helper: login screen open
    Future<void> _openLogin() async {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
      await _loadUserData();
    }

    // Protected routes (login needed)
    bool requiresLogin(BPADrawerDestination d) {
      return d == BPADrawerDestination.petList ||
          d == BPADrawerDestination.petRegister ||
          d == BPADrawerDestination.messages ||
          d == BPADrawerDestination.notifications ||
          d == BPADrawerDestination.settings ||
          d == BPADrawerDestination.adoption ||
          d == BPADrawerDestination.donation;
    }

    if (requiresLogin(dest) && !loggedIn) {
      await _openLogin();
      return;
    }

    // Navigate / switch tabs
    switch (dest) {
      case BPADrawerDestination.home:
        setState(() => _selectedIndex = 0);
        return;

      case BPADrawerDestination.shop:
        setState(() => _selectedIndex = 1);
        return;

      case BPADrawerDestination.services:
        setState(() => _selectedIndex = 2);
        return;

      case BPADrawerDestination.petRegister:
        {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePetScreen()),
          );

          // pet create শেষে true return করলে profile/home refresh
          if (changed == true) {
            await _loadUserData();
            if (mounted) setState(() {});
          }
          return;
        }

      case BPADrawerDestination.petList:
        {
          // ✅ আপনার কাছে PetListScreen থাকলে এখানে বসাবেন
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const PetListScreen()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pet List screen এখনো যুক্ত হয়নি")),
          );
          return;
        }

      case BPADrawerDestination.vet:
      case BPADrawerDestination.grooming:
      case BPADrawerDestination.training:
        {
          // আপাতত Services tab এ নিয়ে যাওয়া হলো
          setState(() => _selectedIndex = 2);
          return;
        }

      case BPADrawerDestination.community:
      case BPADrawerDestination.events:
      case BPADrawerDestination.messages:
      case BPADrawerDestination.notifications:
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("এই ফিচারটি শীঘ্রই আসছে ✅")),
          );
          return;
        }

      case BPADrawerDestination.profile:
        setState(() => _selectedIndex = 3);
        return;

      case BPADrawerDestination.settings:
      case BPADrawerDestination.help:
      case BPADrawerDestination.about:
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Settings/Help/About screen যুক্ত করা হয়নি"),
            ),
          );
          return;
        }

      case BPADrawerDestination.adoption:
      case BPADrawerDestination.donation:
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Adoption/Donation screen যুক্ত করা হয়নি"),
            ),
          );
          return;
        }

      case BPADrawerDestination.logout:
        {
          // Logout
          await prefs.remove('token');
          await prefs.remove('userName');
          await prefs.remove('userEmail');

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
          return;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // পেজ লিস্ট
    final List<Widget> pages = [
      RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF1E60AA),
        backgroundColor: Colors.white,
        child: HomeContentAssembly(userName: userName),
      ),
      const ShopScreen(),
      const ServicesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ✅ Updated drawer (required parameters)
      drawer: BPACustomDrawer(
        isLoggedIn: _isLoggedIn,
        userName: userName,
        userEmail: userEmail,
        onSelect: _handleDrawerSelect,
      ),

      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // login না থাকলে post create করার আগে login screen দেখাবেন
          if (!_isLoggedIn) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
            await _loadUserData();
            return;
          }

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFF1E60AA),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onFabPressed: () {},
      ),
    );
  }
}

// ------------------------------------------
// HOME CONTENT ASSEMBLY
// ------------------------------------------
class HomeContentAssembly extends StatelessWidget {
  final String userName;

  const HomeContentAssembly({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                HomeAppBar(userName: userName),
                const StorySection(),
                const SizedBox(height: 15),
                const ServiceGrid(),
                const SizedBox(height: 10),
                const Divider(
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                  height: 1,
                ),
              ],
            ),
          ),
        ),
        const FeedList(),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
