import 'package:flutter/material.dart';

/// ===========================
/// BPA Drawer Destination Enum
/// ===========================
enum BPADrawerDestination {
  home,
  petList,
  petRegister,
  services,
  vet,
  grooming,
  training,
  shop,
  adoption,
  donation,
  profile,
  community,
  events,
  messages,
  notifications,
  settings,
  help,
  about,
  logout,
}

/// =====================================
/// Premium BPA Drawer (Glass + Sections)
/// =====================================
class BPACustomDrawer extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? avatarUrl; // optional
  final bool isLoggedIn;

  /// Drawer item click handling parent screen এ করবেন
  final void Function(BPADrawerDestination destination) onSelect;

  /// Brand
  static const Color _primaryBlue = Color(0xFF1E60AA);
  static const Color _gold = Color(0xFFFFD700);

  const BPACustomDrawer({
    super.key,
    required this.onSelect,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.isLoggedIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = (userName == null || userName!.trim().isEmpty)
        ? (isLoggedIn ? "BPA Member" : "Guest")
        : userName!.trim();

    final email = (userEmail == null || userEmail!.trim().isEmpty)
        ? (isLoggedIn ? "member@bpa.app" : "Login to unlock features")
        : userEmail!.trim();

    return Drawer(
      backgroundColor: const Color(0xFFF6F8FB),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(
              name: name,
              email: email,
              avatarUrl: avatarUrl,
              isLoggedIn: isLoggedIn,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                children: [
                  _sectionTitle("MAIN"),
                  _drawerTile(
                    context,
                    icon: Icons.home_rounded,
                    title: "Home",
                    onTap: () => onSelect(BPADrawerDestination.home),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.notifications_rounded,
                    title: "Notifications",
                    trailing: _badge("3"),
                    onTap: () => onSelect(BPADrawerDestination.notifications),
                  ),

                  const SizedBox(height: 14),
                  _sectionTitle("PETS"),
                  _drawerTile(
                    context,
                    icon: Icons.pets_rounded,
                    title: "My Pets (Pet List)",
                    onTap: () => onSelect(BPADrawerDestination.petList),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.add_circle_rounded,
                    title: "Register New Pet",
                    subtitle: "Create pet profile + photo",
                    onTap: () => onSelect(BPADrawerDestination.petRegister),
                  ),

                  const SizedBox(height: 14),
                  _sectionTitle("SERVICES"),
                  _expansionCard(
                    context,
                    title: "All Services",
                    subtitle: "Vet • Grooming • Training • More",
                    icon: Icons.medical_services_rounded,
                    children: [
                      _drawerTile(
                        context,
                        dense: true,
                        icon: Icons.local_hospital_rounded,
                        title: "Vet Service",
                        onTap: () => onSelect(BPADrawerDestination.vet),
                      ),
                      _drawerTile(
                        context,
                        dense: true,
                        icon: Icons.cut_rounded,
                        title: "Grooming",
                        onTap: () => onSelect(BPADrawerDestination.grooming),
                      ),
                      _drawerTile(
                        context,
                        dense: true,
                        icon: Icons.school_rounded,
                        title: "Training",
                        onTap: () => onSelect(BPADrawerDestination.training),
                      ),
                      _drawerTile(
                        context,
                        dense: true,
                        icon: Icons.grid_view_rounded,
                        title: "Browse Services",
                        onTap: () => onSelect(BPADrawerDestination.services),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  _sectionTitle("COMMUNITY"),
                  _drawerTile(
                    context,
                    icon: Icons.people_alt_rounded,
                    title: "Community Feed",
                    onTap: () => onSelect(BPADrawerDestination.community),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.event_rounded,
                    title: "Events",
                    onTap: () => onSelect(BPADrawerDestination.events),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.chat_bubble_rounded,
                    title: "Messages",
                    onTap: () => onSelect(BPADrawerDestination.messages),
                  ),

                  const SizedBox(height: 14),
                  _sectionTitle("SHOP & CAUSES"),
                  _drawerTile(
                    context,
                    icon: Icons.storefront_rounded,
                    title: "Pet Shop",
                    onTap: () => onSelect(BPADrawerDestination.shop),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.volunteer_activism_rounded,
                    title: "Donation",
                    subtitle: "Support rescues & shelters",
                    trailing: _pill("New"),
                    onTap: () => onSelect(BPADrawerDestination.donation),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.favorite_rounded,
                    title: "Adoption",
                    subtitle: "Find a new friend",
                    onTap: () => onSelect(BPADrawerDestination.adoption),
                  ),

                  const SizedBox(height: 14),
                  _sectionTitle("APP"),
                  _drawerTile(
                    context,
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    onTap: () => onSelect(BPADrawerDestination.settings),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.help_rounded,
                    title: "Help & Support",
                    onTap: () => onSelect(BPADrawerDestination.help),
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.info_rounded,
                    title: "About BPA",
                    onTap: () => onSelect(BPADrawerDestination.about),
                  ),

                  const SizedBox(height: 12),
                  _divider(),

                  // Logout / Login
                  _drawerTile(
                    context,
                    icon: isLoggedIn
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
                    title: isLoggedIn ? "Logout" : "Login",
                    titleColor: isLoggedIn ? Colors.redAccent : _primaryBlue,
                    onTap: () => onSelect(BPADrawerDestination.logout),
                  ),
                ],
              ),
            ),

            // footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: const [
                  Icon(Icons.pets, size: 16, color: Colors.black54),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "BPA Super App • Premium Pet Community",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI helpers
  // =========================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 10),
    color: Colors.black12,
  );

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _gold.withOpacity(0.45)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8A6A00),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _expansionCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: _primaryBlue),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: (subtitle == null)
              ? null
              : Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    bool dense = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        dense: dense,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: titleColor ?? Colors.black87,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.pop(context); // drawer close
          onTap();
        },
      ),
    );
  }
}

/// ===========================
/// Header (Premium Look)
/// ===========================
class _DrawerHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isLoggedIn;

  static const Color _primaryBlue = Color(0xFF1E60AA);
  static const Color _gold = Color(0xFFFFD700);

  const _DrawerHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "B";

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [_primaryBlue, _primaryBlue.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLoggedIn ? _gold : Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isLoggedIn
                        ? Icons.workspace_premium_rounded
                        : Icons.lock_outline_rounded,
                    size: 14,
                    color: isLoggedIn ? const Color(0xFF5B4300) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _miniChip(icon: Icons.pets_rounded, label: "Pet Care"),
                    const SizedBox(width: 8),
                    _miniChip(icon: Icons.favorite_rounded, label: "Community"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
