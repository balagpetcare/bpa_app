import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math'; // র‍্যান্ডম ডাটার জন্য

// ==========================================
// 1. DATA MODELS & ENUMS (Pet Themed)
// ==========================================

enum PostType { image, video, donation, adoption, text }

// কাস্টম রিঅ্যাকশন টাইপ (ফেসবুকের বদলে পেট থিম)
enum PetReaction { none, highFive, love, treat, meow, woof }

class Comment {
  final String user;
  final String text;
  final int likes;
  final String time;

  Comment({
    required this.user,
    required this.text,
    required this.likes,
    required this.time,
  });
}

class FeedItem {
  final String id;
  final String userName;
  final String userImage;
  final String timeAgo;
  final String caption;
  final PostType type;
  final String mediaUrl;
  final int shareCount;

  // Mutable interaction fields
  PetReaction currentReaction;
  List<Comment> comments;

  FeedItem({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.timeAgo,
    required this.caption,
    required this.type,
    required this.mediaUrl,
    this.shareCount = 0,
    this.currentReaction = PetReaction.none,
    this.comments = const [],
  });
}

// ==========================================
// 2. DATA GENERATOR (40 Mixed Posts)
// ==========================================
List<FeedItem> _generateFeed() {
  final List<String> images = [
    'https://images.unsplash.com/photo-1548199973-03cce0bbc87b', // Dog 1
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba', // Cat 1
    'https://images.unsplash.com/photo-1552053831-71594a27632d', // Dog 2
    'https://images.unsplash.com/photo-1533738363-b7f9aef128ce', // Cat 2
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e', // Puppy
    'https://images.unsplash.com/photo-1517849845537-4d257902454a', // Dog and Human
  ];

  final List<String> users = [
    'BPA Official',
    'Cat Lovers',
    'Dr. Arefin',
    'Pet Haven',
    'Cute Paws',
  ];
  final Random random = Random();

  List<FeedItem> items = [];

  for (int i = 0; i < 40; i++) {
    // র‍্যান্ডম সিলেকশন
    String img = images[i % images.length];
    String user = users[i % users.length];
    PostType type = PostType.values[i % 4]; // Image, Video, Donation, Adoption

    items.add(
      FeedItem(
        id: 'post_$i',
        userName: user,
        userImage: 'https://i.pravatar.cc/150?img=${i + 1}',
        timeAgo: '${(i + 1) * 2}m ago',
        caption: i % 3 == 0
            ? 'আমাদের নতুন ক্যাম্পেইনে যোগ দিন! প্রাণীদের ভালোবাসুন। ❤️🐶 #BPA'
            : 'আজকের বিকেলের কিছু সুন্দর মুহূর্ত। দেখুন কত কিউট! 😍',
        type: type,
        mediaUrl: img,
        shareCount: random.nextInt(50) + 1,
        currentReaction: PetReaction.none,
        comments: [
          Comment(
            user: "User ${random.nextInt(100)}",
            text: "অসাধারণ! ❤️",
            likes: random.nextInt(10),
            time: "2m",
          ),
          Comment(
            user: "Pet Lover",
            text: "কিভাবে এডপ্ট করতে পারি?",
            likes: random.nextInt(5),
            time: "5m",
          ),
          if (i % 2 == 0)
            Comment(
              user: "Dr. Smith",
              text: "খুবই সুন্দর উদ্যোগ।",
              likes: 12,
              time: "10m",
            ),
        ],
      ),
    );
  }
  return items;
}

final List<FeedItem> _feedData = _generateFeed();

// ==========================================
// 3. MAIN FEED LIST (Sliver)
// ==========================================
class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    // এটি SliverList রিটার্ন করছে, তাই CustomScrollView এর slivers[] এর ভেতরে সরাসরি বসবে
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = _feedData[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FeedPostWidget(item: item),
        );
      }, childCount: _feedData.length),
    );
  }
}

// ==========================================
// 4. INDIVIDUAL POST WIDGET
// ==========================================
class FeedPostWidget extends StatefulWidget {
  final FeedItem item;
  const FeedPostWidget({super.key, required this.item});

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget> {
  void _updateReaction(PetReaction type) {
    setState(() {
      if (widget.item.currentReaction == type) {
        widget.item.currentReaction = PetReaction.none; // Toggle off
      } else {
        widget.item.currentReaction = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Special Layouts for Donation/Adoption
    if (widget.item.type == PostType.donation)
      return DonationCard(item: widget.item);
    if (widget.item.type == PostType.adoption)
      return AdoptionCard(item: widget.item);

    // Standard Social Post
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0), // Flat list style or rounded
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. HEADER
          _buildHeader(),

          // B. CAPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              widget.item.caption,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // C. MEDIA
          _buildMedia(),

          // D. INTERACTION BAR (The main attraction)
          _buildInteractionSection(),

          // E. COMMENTS PREVIEW
          _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(widget.item.userImage),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              widget.item.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.verified, color: Color(0xFF1E60AA), size: 16),
        ],
      ),
      subtitle: Text(
        widget.item.timeAgo,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: const Icon(Icons.more_horiz, color: Colors.grey),
    );
  }

  Widget _buildMedia() {
    return CachedNetworkImage(
      imageUrl: widget.item.mediaUrl,
      width: double.infinity,
      height: 320,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 320,
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.pets, size: 50, color: Colors.black12),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 320,
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey),
      ),
    );
  }

  // --- PREMIUM INTERACTION BAR ---
  Widget _buildInteractionSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Reaction Count Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.item.currentReaction != PetReaction.none) ...[
                _getReactionIconSmall(widget.item.currentReaction),
                const SizedBox(width: 5),
              ],
              Text(
                widget.item.currentReaction != PetReaction.none
                    ? "You and 532 others"
                    : "532 Paws",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Spacer(),
              Text(
                "${widget.item.comments.length} comments • ${widget.item.shareCount} shares",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 0.5),

        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. CUSTOM REACTION BUTTON (Long Press Logic)
            GestureDetector(
              onLongPress: () => _showPetReactionMenu(context),
              onTap: () => _updateReaction(PetReaction.highFive),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 15,
                ),
                color: Colors.transparent, // Hitbox extend
                child: Row(
                  children: [
                    _getReactionIconMain(widget.item.currentReaction),
                    const SizedBox(width: 6),
                    Text(
                      _getReactionLabel(widget.item.currentReaction),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getReactionColor(widget.item.currentReaction),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Comment
            _actionBtn(Icons.chat_bubble_outline_rounded, "Comment"),

            // 3. Share
            _actionBtn(Icons.share_outlined, "Share"),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMMENTS PREVIEW (2-3 Items) ---
  Widget _buildCommentsSection() {
    return Container(
      color: const Color(0xFFFAFAFA), // Slightly different bg
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: widget.item.comments.map((comment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const NetworkImage(
                    "https://i.pravatar.cc/150?img=5",
                  ),
                ),
                const SizedBox(width: 8),

                // Comment Bubble
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comment.text,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Comment Actions (Like/Reply)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Row(
                          children: [
                            const Text(
                              "Like",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              "Reply",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (comment.likes > 0) ...[
                              const Icon(
                                Icons.thumb_up,
                                size: 10,
                                color: Color(0xFF1E60AA),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${comment.likes}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- PET REACTION POPUP (Facebook Style Logic) ---
  void _showPetReactionMenu(BuildContext context) async {
    final result = await showDialog<PetReaction>(
      context: context,
      barrierColor: Colors.transparent, // Background not dim
      builder: (context) => const _PetReactionDialog(),
    );

    if (result != null) {
      _updateReaction(result);
    }
  }

  // --- HELPER: Reaction Icons & Colors ---
  Widget _getReactionIconMain(PetReaction type) {
    switch (type) {
      case PetReaction.highFive:
        return const Icon(Icons.pets, color: Color(0xFF1E60AA));
      case PetReaction.love:
        return const Icon(Icons.favorite, color: Colors.red);
      case PetReaction.treat:
        return const Icon(
          Icons.lunch_dining,
          color: Colors.orange,
        ); // Bone replacement
      case PetReaction.meow:
        return const Icon(Icons.face, color: Colors.purple);
      default:
        return const Icon(Icons.pets, color: Colors.grey);
    }
  }

  Widget _getReactionIconSmall(PetReaction type) {
    switch (type) {
      case PetReaction.highFive:
        return _circleIcon(Icons.pets, const Color(0xFF1E60AA));
      case PetReaction.love:
        return _circleIcon(Icons.favorite, Colors.red);
      default:
        return _circleIcon(Icons.pets, const Color(0xFF1E60AA));
    }
  }

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  String _getReactionLabel(PetReaction type) {
    switch (type) {
      case PetReaction.highFive:
        return "High Five";
      case PetReaction.love:
        return "Love";
      case PetReaction.treat:
        return "Treat";
      case PetReaction.meow:
        return "Meow";
      default:
        return "Paw";
    }
  }

  Color _getReactionColor(PetReaction type) {
    if (type == PetReaction.none) return Colors.grey[700]!;
    if (type == PetReaction.love) return Colors.red;
    if (type == PetReaction.treat) return Colors.orange;
    if (type == PetReaction.meow) return Colors.purple;
    return const Color(0xFF1E60AA);
  }
}

// ==========================================
// 5. PET REACTION DIALOG (The Pop-up)
// ==========================================
class _PetReactionDialog extends StatelessWidget {
  const _PetReactionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.only(
        top: 250,
      ), // Position visually above the button
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reactionOption(
              context,
              "🐾",
              "High Five",
              PetReaction.highFive,
              const Color(0xFF1E60AA),
            ),
            _reactionOption(
              context,
              "❤️",
              "Love",
              PetReaction.love,
              Colors.red,
            ),
            _reactionOption(
              context,
              "🍖",
              "Treat",
              PetReaction.treat,
              Colors.orange,
            ),
            _reactionOption(
              context,
              "🐱",
              "Meow",
              PetReaction.meow,
              Colors.purple,
            ),
            _reactionOption(
              context,
              "🐶",
              "Woof",
              PetReaction.woof,
              Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reactionOption(
    BuildContext context,
    String emoji,
    String label,
    PetReaction type,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            // Optional: Label below emoji
            // Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. SPECIAL CARDS (Internal Classes)
// ==========================================

class DonationCard extends StatelessWidget {
  final FeedItem item;
  const DonationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.red.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            title: const Text(
              "Save The Paws",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Sponsored • Urgent"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: item.mediaUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.caption,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.7,
                  color: Colors.red,
                  backgroundColor: Colors.red[50],
                  minHeight: 6,
                ),
                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "৳70,000 Raised",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Goal: ৳100,000",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("DONATE NOW"),
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

class AdoptionCard extends StatelessWidget {
  final FeedItem item;
  const AdoptionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=8'),
            ),
            title: const Text(
              "Adoption Center",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.timeAgo),
            trailing: const Icon(Icons.home, color: Colors.green),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(item.caption, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.mediaUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pets),
                label: const Text("ADOPT ME"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
