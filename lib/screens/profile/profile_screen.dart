import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../login_screen.dart';
import '../pets/create_pet_screen.dart';
import '../../services/profile_service.dart';

// ---------------------------------------------------------
// 1. CONFIGURATION CLASS
// ---------------------------------------------------------
class ApiConfig {
  static const String baseUrl = "http://192.168.10.111:3000/api/v1";
  static const String profileUrl = "$baseUrl/user/profile";
}

// ---------------------------------------------------------
// 2. DATA MODELS (UPDATED WITH NEW FIELDS)
// ---------------------------------------------------------
class UserProfile {
  final String name;
  final String email;
  final String profileImage;
  final String coverImage;
  final String followers;
  final String rank;
  final int pawPoints;
  final List<Pet> pets;

  // New Fields for Details Section
  final String profession;
  final String gender;
  final String location;
  final String dob;
  final String education;
  final String passion;
  final String bio;
  final List<String> galleryImages;

  UserProfile({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.coverImage,
    required this.followers,
    required this.rank,
    required this.pawPoints,
    required this.pets,
    required this.profession,
    required this.gender,
    required this.location,
    required this.dob,
    required this.education,
    required this.passion,
    required this.bio,
    required this.galleryImages,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var petList = json['pets'] as List? ?? [];
    var galleryList = json['gallery'] as List? ?? [];

    return UserProfile(
      name: json['name'] ?? 'Gobinda Bala',
      email: json['email'] ?? 'gobinda@example.com',
      profileImage:
          json['profileImage'] ??
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1887&auto=format&fit=crop',
      coverImage:
          json['coverImage'] ??
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=2069&auto=format&fit=crop',
      followers: json['followers']?.toString() ?? '12.5k',
      rank: json['rank'] ?? '#5',
      pawPoints:
          int.tryParse(json['pawPoints']?.toString() ?? '15000') ?? 15000,
      pets: petList.isNotEmpty
          ? petList.map((i) => Pet.fromJson(i)).toList()
          : _getDummyPets(),

      // Mapping new fields (Default values added for design preview)
      profession: json['profession'] ?? 'Veterinary Doctor',
      gender: json['gender'] ?? 'Male',
      location: json['location'] ?? 'Dhaka, Bangladesh',
      dob: json['dob'] ?? '15 July 1995',
      education:
          json['education'] ??
          'DVM, Patuakhali Science & Technology University',
      passion: json['passion'] ?? 'Animal Welfare & Tech',
      bio:
          json['bio'] ??
          'Founder of Balaji Pet Clinic. Dedicated to ensuring the health and happiness of every pet.',
      galleryImages: galleryList.isNotEmpty
          ? galleryList.map((e) => e.toString()).toList()
          : _getDummyGallery(),
    );
  }

  static List<Pet> _getDummyPets() {
    return [
      Pet(
        name: "Buddy",
        breed: "Golden R.",
        image:
            "https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=1000",
      ),
      Pet(
        name: "Luna",
        breed: "Persian",
        image:
            "https://images.unsplash.com/photo-1573865526739-10659fec78a5?q=80&w=1000",
      ),
      Pet(
        name: "Rio",
        breed: "Parrot",
        image:
            "https://images.unsplash.com/photo-1552728089-57bdde30ebd1?q=80&w=1000",
      ),
      Pet(
        name: "Simba",
        breed: "Cat",
        image:
            "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000",
      ),
      Pet(
        name: "Max",
        breed: "G. Shep",
        image:
            "https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?q=80&w=1000",
      ),
    ];
  }

  static List<String> _getDummyGallery() {
    return [
      "https://images.unsplash.com/photo-1601758124510-52d02ddb7cbd?q=80&w=1000",
      "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000",
      "https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?q=80&w=1000",
      "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?q=80&w=1000",
      "https://images.unsplash.com/photo-1599141014588-771f28b2a3fb?q=80&w=1000",
      "https://images.unsplash.com/photo-1450778869180-41d0601e046e?q=80&w=1000",
    ];
  }
}

class Pet {
  final String name;
  final String breed;
  final String image;

  Pet({required this.name, required this.breed, required this.image});

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'] ?? 'Unknown',
      breed: json['breed'] ?? 'Unknown',
      image: json['image'] ?? 'https://via.placeholder.com/150',
    );
  }
}

// ---------------------------------------------------------
// 3. UI SCREEN
// ---------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  UserProfile? userProfile;
  final Color goldColor = const Color(0xFFCfaa56);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // For testing without API, remove or comment out this block later
    if (token == null) {
      setState(() {
        userProfile = UserProfile.fromJson({});
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] ?? data['user'];
        setState(() {
          userProfile = UserProfile.fromJson(userData);
          isLoading = false;
        });
      } else {
        // Fallback dummy data
        setState(() {
          userProfile = UserProfile.fromJson({});
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userProfile = UserProfile.fromJson({});
        isLoading = false;
      });
    }
  }

  // Logout function... (omitted for brevity, keep same as before)
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: goldColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 15),
                  _buildStats(),
                  const SizedBox(height: 25),
                  _buildTrophySection(),
                  const SizedBox(height: 25),

                  // 1. HORIZONTAL PET LIST
                  _buildHorizontalPetSection(),

                  const SizedBox(height: 25),

                  // 2. PHOTO GALLERY
                  _buildPhotoGallery(),

                  const SizedBox(height: 25),

                  // 3. USER DETAILS
                  _buildUserDetails(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. COVER IMAGE
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(userProfile!.coverImage),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),

        // 2. PROFILE SECTION (With Crown & Ribbon)
        Positioned(
          bottom: -65, // নিচে নামানো হলো যাতে রিবনটা সুন্দরভাবে বসে
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // A. Glowing Background Effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // B. Profile Border Ring
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(userProfile!.profileImage),
                  ),
                ),
              ),

              // C. The Crown Icon (Top of Profile)
              Positioned(
                top: -12,
                child: Transform.rotate(
                  angle: -0.1, // হালকা বাঁকানো স্টাইলিশ লুকের জন্য
                  child: const Icon(
                    Icons
                        .emoji_events_rounded, // অথবা Icons.crown যদি প্যাকেজ থাকে
                    size: 40,
                    color: Color(0xFFFFD700),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // D. The Ribbon Banner (Bottom of Profile)
              Positioned(
                bottom: -15,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ribbon Tail (Back visual)
                    Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8860B), // Dark Gold
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Main Ribbon Body
                    Container(
                      margin: const EdgeInsets.only(bottom: 4), // Lift effect
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        // রিবনের দুই কোণা একটু কেটে দেওয়ার জন্য (Optional style)
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "BPA LEGEND",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              fontSize: 12,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.star, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // UPDATED STATS SECTION (With Card & Icons)
  // =========================================================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 70.0,
        left: 20,
        right: 20,
      ), // পাশে প্যাডিং দেওয়া হলো
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(
              userProfile!.followers,
              "Followers",
              Icons.people_alt_rounded,
            ),
            _buildDivider(), // মাঝের দাগ
            _statItem(userProfile!.rank, "Rank", Icons.emoji_events_rounded),
            _buildDivider(), // মাঝের দাগ
            // Paw Points এর জন্য কাস্টম আইকন ব্যবহার করা হয়েছে
            _statItem(
              userProfile!.pawPoints.toString(),
              "Paw Points",
              Icons.pets_rounded,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget for Divider ---
  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  // =========================================================
  // UPDATED STAT ITEM (With Icon Support)
  // =========================================================
  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        // Value with Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: goldColor), // আইকন যোগ করা হলো
            const SizedBox(width: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800, // আরো বোল্ড করা হলো
                color: goldColor,
                fontFamily: 'Sans', // আপনার অ্যাপের ডিফল্ট ফন্ট দিন
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Label Text
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrophySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // সেকশন টাইটেল (অপশনাল, চাইলে রাখতে পারেন)
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: Color(0xFFDAA520),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Sans', // আপনার ফন্ট ফ্যামিলি
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // মেইন ট্রফি কন্টেইনার
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              // গেমের মতো কার্ড শ্যাডো
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              // হালকা গোল্ডেন বর্ডার
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGameTrophyItem(
                  title: "Top Donor",
                  icon: Icons.emoji_events_rounded,
                  colors: [
                    const Color(0xFFFFD700),
                    const Color(0xFFFFA500),
                  ], // Gold Gradient
                  shadowColor: const Color(0xFFFFA500),
                ),
                _buildGameTrophyItem(
                  title: "Quiz Pro",
                  icon: Icons.psychology_rounded,
                  colors: [
                    const Color(0xFF4FACFE),
                    const Color(0xFF00F2FE),
                  ], // Blue Gradient
                  shadowColor: const Color(0xFF4FACFE),
                ),
                _buildGameTrophyItem(
                  title: "Verified",
                  icon: Icons.verified_user_rounded,
                  colors: [
                    const Color(0xFF43E97B),
                    const Color(0xFF38F9D7),
                  ], // Green Gradient
                  shadowColor: const Color(0xFF43E97B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // এই হেল্পার উইজেটটি ক্লাসের নিচে বা ভিতরে কোথাও পেস্ট করুন
  Widget _buildGameTrophyItem({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required Color shadowColor,
  }) {
    return Column(
      children: [
        // আইকন কন্টেইনার (মেডেল স্টাইল)
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6), // শ্যাডো নিচে পড়বে
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2,
            ), // সাদা রিং বর্ডার
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 10),

        // টাইটেল টেক্সট
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 1. UPDATED: MY PET FAMILY (HORIZONTAL SCROLL)
  // =========================================================
  // =========================================================
  // UPDATED (FULL): MY PET FAMILY (HORIZONTAL SCROLL)
  // - Add New + -> CreatePetScreen navigate
  // - CachedNetworkImage used
  // - Empty state handled
  // - Safer URL + placeholder/error UI
  // =========================================================
  Widget _buildHorizontalPetSection() {
    final pets = userProfile?.pets ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Pet Family",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePetScreen()),
                  );

                  if (changed == true) {
                    // ✅ এখানে আপনার profile data reload করবেন
                    // আপনার ফাইলে যে method দিয়ে profile/pet list আনেন সেটার নাম বসান:
                    await _loadProfileData(); // <-- যদি আপনার method name ভিন্ন হয়, সেটাই লিখবেন
                    setState(() {});
                  }
                },
                child: const Text(
                  "Add New +",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // ✅ Empty State
        if (pets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.pets, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "No pets added yet. Tap 'Add New +' to create your first pet.",
                      style: TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                // ✅ আপনার pet model অনুযায়ী image url field এখানে adjust করুন
                // আপনি আগে pet.image ব্যবহার করেছেন
                final String imageUrl = (pet.image ?? "").toString().trim();
                final String petName = (pet.name ?? "Pet").toString();

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.10),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: (imageUrl.isEmpty)
                              ? Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(Icons.pets, size: 28),
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: double.infinity,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: Text(
                                        "Loading pet joy...",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: double.infinity,
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: Icon(Icons.pets, size: 28),
                                        ),
                                      ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          petName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // =========================================================
  // 2. NEW: PHOTO GALLERY SECTION
  // =========================================================
  Widget _buildPhotoGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Photo Gallery",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: userProfile!.galleryImages.length > 6
                ? 6
                : userProfile!.galleryImages.length, // Show max 6
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 photos per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  userProfile!.galleryImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          // More Photos Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to full gallery
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.blueAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "More Photos",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 3. NEW: USER DETAILS SECTION
  // =========================================================
  Widget _buildUserDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Me",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio Section
                const Text(
                  "Bio",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userProfile!.bio,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 30),

                // Details Rows
                _buildDetailRow(
                  Icons.work,
                  "Profession",
                  userProfile!.profession,
                ),
                _buildDetailRow(Icons.person, "Gender", userProfile!.gender),
                _buildDetailRow(
                  Icons.calendar_today,
                  "Date of Birth",
                  userProfile!.dob,
                ),
                _buildDetailRow(
                  Icons.location_on,
                  "Location",
                  userProfile!.location,
                ),
                _buildDetailRow(
                  Icons.school,
                  "Education",
                  userProfile!.education,
                ),
                _buildDetailRow(
                  Icons.favorite,
                  "Passion",
                  userProfile!.passion,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Button (Moved here)
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
