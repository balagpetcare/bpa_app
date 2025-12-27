import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;

  const HomeAppBar({super.key, this.userName = "Guest"});

  @override
  Widget build(BuildContext context) {
    String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "G";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // ✅ [Step 3] এখানে ক্লিক ইভেন্ট যোগ করা হলো
          InkWell(
            onTap: () {
              // এই কমান্ডটি প্যারেন্ট (HomeScreen) এর ড্রয়ার ওপেন করবে
              Scaffold.of(context).openDrawer();
            },
            borderRadius: BorderRadius.circular(
              50,
            ), // ক্লিকের শ্যাডো গোল করার জন্য
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1E60AA),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // --- Search Bar (Fixed Center Text) ---
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                textAlignVertical:
                    TextAlignVertical.center, // ✅ টেক্সট মাঝখানে আনার জন্য
                decoration: InputDecoration(
                  hintText: "Search BPA...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // ✅ প্যাডিং ফিক্স
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // --- Notification Icon ---
          // (বাকি কোড আগের মতোই থাকবে...)
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 26,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
