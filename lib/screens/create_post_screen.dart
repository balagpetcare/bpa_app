import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // পোস্ট সাবমিট লজিক এখানে হবে
              Navigator.pop(context); // কাজ শেষে হোমপেজে ফিরে যাবে
            },
            child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind regarding your pet?",
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20),
            // ছবি আপলোড বাটন ডামি
            Row(
              children: [
                Icon(Icons.photo, color: Colors.green),
                SizedBox(width: 10),
                Text("Add Photo/Video"),
              ],
            )
          ],
        ),
      ),
    );
  }
}