import 'package:flutter/material.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          _buildStoryItem("Your Story", isMyStory: true),
          _buildStoryItem("Mimi & Mom", imgUrl: 'https://i.pravatar.cc/150?img=9'),
          _buildStoryItem("Dr. Karim", imgUrl: 'https://i.pravatar.cc/150?img=11'),
          _buildStoryItem("Rescue Paws", imgUrl: 'https://i.pravatar.cc/150?img=12'),
          _buildStoryItem("Adoption", imgUrl: 'https://i.pravatar.cc/150?img=3'),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, {String? imgUrl, bool isMyStory = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: isMyStory 
                      ? const NetworkImage('https://i.pravatar.cc/150?img=5') 
                      : NetworkImage(imgUrl!),
                ),
              ),
              if (isMyStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}