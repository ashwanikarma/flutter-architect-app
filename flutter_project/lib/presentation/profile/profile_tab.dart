import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../auth/login/login_screen.dart';
import 'edit_profile_screen.dart';

/// Profile tab displaying user info, settings, and logout.
class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _userName = 'John Doe';
  String _userEmail = 'johndoe@email.com';
  int _avatarIndex = 0;

  static const _avatarIcons = [
    Icons.person_rounded,
    Icons.face_rounded,
    Icons.face_2_rounded,
    Icons.face_3_rounded,
    Icons.face_4_rounded,
    Icons.face_5_rounded,
    Icons.face_6_rounded,
    Icons.sports_martial_arts_rounded,
  ];

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialName: _userName,
          initialEmail: _userEmail,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _userName = result['name'] as String;
        _userEmail = result['email'] as String;
        _avatarIndex = result['avatarIndex'] as int;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ApiService().clearToken();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Avatar & name
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                child: Icon(_avatarIcons[_avatarIndex], size: 48, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 14),
              Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
              const SizedBox(height: 4),
              Text(_userEmail, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              // Edit profile button
              OutlinedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 28),

              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: 'Workouts', value: '128'),
                    _Divider(),
                    _StatItem(label: 'Kcal', value: '12.4k'),
                    _Divider(),
                    _StatItem(label: 'Streak', value: '14d'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings section
              _sectionHeader('Settings'),
              const SizedBox(height: 8),
              _settingsCard([
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                const Divider(height: 1),
                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: _darkModeEnabled,
                  onChanged: (v) => setState(() => _darkModeEnabled = v),
                ),
              ]),
              const SizedBox(height: 16),

              // General section
              _sectionHeader('General'),
              const SizedBox(height: 8),
              _settingsCard([
                _NavTile(icon: Icons.language_outlined, title: 'Language', trailing: 'English'),
                const Divider(height: 1),
                _NavTile(icon: Icons.shield_outlined, title: 'Privacy'),
                const Divider(height: 1),
                _NavTile(icon: Icons.help_outline_rounded, title: 'Help & Support'),
                const Divider(height: 1),
                _NavTile(icon: Icons.info_outline_rounded, title: 'About'),
              ]),
              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMain)),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

// ── Helper widgets ──────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: AppColors.background);
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primaryBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  const _NavTile({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {},
    );
  }
}
