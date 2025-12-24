import 'package:flutter/material.dart';

// ✅ আপনার পেজগুলোর সঠিক ইমপোর্ট (ফোল্ডার স্ট্রাকচার অনুযায়ী)
import '../../vet_screen.dart';
import '../../shop_screen.dart';
import '../../donation_screen.dart';
import '../../adoption_screen.dart';
// import '../../grooming_screen.dart'; // যদি থাকে

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // সার্ভিস লিস্ট এবং তাদের অন-ট্যাপ অ্যাকশন
    final List<Map<String, dynamic>> services = [
      {
        'icon': Icons.local_hospital_rounded,
        'label': 'Vet Services',
        'color': Colors.redAccent,
        'onTap': (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VetScreen()),
        ),
      },
      {
        'icon': Icons.store_rounded,
        'label': 'Pet Shop',
        'color': Colors.orange,
        'onTap': (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopScreen()),
        ),
      },
      {
        'icon': Icons.volunteer_activism_rounded,
        'label': 'Donation',
        'color': Colors.pink,
        'onTap': (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonationScreen()),
        ),
      },
      {
        'icon': Icons.home_rounded,
        'label': 'Adoption',
        'color': Colors.green,
        'onTap': (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdoptionScreen()),
        ),
      },
      // --- নিচের গুলোর জন্য পেজ তৈরি না থাকলে মেসেজ দেখাবে ---
      {
        'icon': Icons.content_cut_rounded,
        'label': 'Grooming',
        'color': Colors.purple,
        'onTap': (context) => _showComingSoon(context, "Grooming"),
      },
      {
        'icon': Icons.pets_rounded,
        'label': 'Training',
        'color': Colors.brown,
        'onTap': (context) => _showComingSoon(context, "Training"),
      },
      {
        'icon': Icons.hotel_rounded,
        'label': 'Pet Hotel',
        'color': Colors.blue,
        'onTap': (context) => _showComingSoon(context, "Pet Hotel"),
      },
      {
        'icon': Icons.local_shipping_rounded,
        'label': 'Transport',
        'color': Colors.teal,
        'onTap': (context) => _showComingSoon(context, "Transport"),
      },
    ];

    // ✅ Horizontal Scroll View (ডান-বাম স্ক্রল করার জন্য)
    return SizedBox(
      height: 100, // লিস্টের নির্দিষ্ট উচ্চতা
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // হরাইজন্টাল স্ক্রল
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceItem(context, services[index]);
        },
      ),
    );
  }

  // সার্ভিস আইটেম বিল্ডার
  Widget _buildServiceItem(BuildContext context, Map<String, dynamic> service) {
    return Container(
      width: 80, // প্রতিটি আইটেমের প্রস্থ
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ), // আইটেমের মাঝখানের গ্যাপ
      child: InkWell(
        onTap: () {
          if (service['onTap'] != null) {
            service['onTap'](context);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (service['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(service['icon'], color: service['color'], size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              service['label'],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // হেল্পার ফাংশন (যেগুলোর পেজ নেই)
  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title feature coming soon!"),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
