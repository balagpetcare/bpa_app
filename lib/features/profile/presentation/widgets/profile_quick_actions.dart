import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileQuickActions extends StatelessWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onAddNewPet;

  const ProfileQuickActions({
    super.key,
    this.onEditProfile,
    this.onAddNewPet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Action(
            title: "Edit Profile",
            icon: Icons.edit,
            onTap: onEditProfile,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Action(
            title: "Add New Pet",
            icon: Icons.add,
            onTap: onAddNewPet,
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _Action({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF1E60AA),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x33000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // if no handler, keep UI but disable ripple semantics
    if (onTap == null) return Opacity(opacity: 0.75, child: child);
    return child;
  }
}
