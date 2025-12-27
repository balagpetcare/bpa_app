import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/user_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final VoidCallback? onMore;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onBack,
    this.onFavorite,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final title = profile.name;
    final subtitle = profile.username?.isNotEmpty == true
        ? "@${profile.username}"
        : (profile.email ?? profile.phone ?? "BPA Member");

    final cover = profile.coverUrl;
    final avatar = profile.photoUrl;

    return Stack(
      children: [
        // Cover
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          child: SizedBox(
            height: 260,
            width: double.infinity,
            child: cover == null || cover.isEmpty
                ? _DefaultCover()
                : CachedNetworkImage(
                    imageUrl: cover,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _DefaultCover(),
                    errorWidget: (_, __, ___) => _DefaultCover(),
                  ),
          ),
        ),

        // Cover overlay (glass/gradient)
        Positioned.fill(
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.05),
                  const Color(0xFF0B1220).withOpacity(0.80),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Top actions
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _TopIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack ?? () => Navigator.maybePop(context),
                ),
                const Spacer(),
                _TopIcon(icon: Icons.favorite_border, onTap: onFavorite),
                const SizedBox(width: 10),
                _TopIcon(icon: Icons.more_horiz, onTap: onMore),
              ],
            ),
          ),
        ),

        // Center avatar + badge + name
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Column(
            children: [
              _AvatarWithRibbon(name: title, photoUrl: avatar),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _AvatarWithRibbon extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _AvatarWithRibbon({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Avatar ring
        Container(
          height: 92,
          width: 92,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: (photoUrl == null || photoUrl!.isEmpty)
                ? Container(
                    color: Colors.white.withOpacity(0.08),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.white.withOpacity(0.06),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white.withOpacity(0.08),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // Ribbon badge
        Positioned(
          bottom: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.25),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 16, color: Color(0xFF0B1220)),
                SizedBox(width: 8),
                Text(
                  "BPA Legend",
                  style: TextStyle(
                    color: Color(0xFF0B1220),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DefaultCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E60AA), Color(0xFF0B1220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 56,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}
