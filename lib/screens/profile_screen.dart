import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teman_sejenak/screens/login_screen.dart';
import 'package:teman_sejenak/screens/edit_profile_screen.dart';
import 'package:teman_sejenak/utils/app_colors.dart';
import '../presentation/providers/providers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Perform logout
      await context.read<AuthProvider>().logout();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil Logout')),
        );

        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profil Kamu'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Header card ──────────────────────────────────────
                Container(
                  decoration: _cardBox,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: user?.imageUrl != null 
                            ? NetworkImage(user!.imageUrl!)
                            : null,
                        child: user?.imageUrl == null
                            ? Text(
                                auth.userInitials,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user?.placeOfBirth != null)
                        Text(
                          user!.placeOfBirth!,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        auth.userEmail,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // Session info
                      FutureBuilder<Duration?>(
                        future: auth.getRemainingSessionTime(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final remaining = snapshot.data!;
                            final hours = remaining.inHours;
                            final minutes = remaining.inMinutes % 60;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sesi: ${hours}j ${minutes}m tersisa',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          style: _blueBtn,
                          child: const Text('Ubah Profil'),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Settings list ────────────────────────────────────
                Container(
                  decoration: _cardBox,
                  child: Column(
                    children: [
                      _tile(Icons.credit_card_rounded, 'Metode Pembayaran', () {}),
                      _divider(),
                      _tile(Icons.notifications_rounded, 'Notifikasi', () {}),
                      _divider(),
                      _tile(Icons.settings_rounded, 'Pengaturan Aplikasi', () {}),
                      _divider(),
                      _tile(Icons.help_outline_rounded, 'Bantuan & Dukungan', () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── logout ───────────────────────────────────────────
                Container(
                  decoration: _cardBox,
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        color: AppColors.danger,
                      ),
                    ),
                    onTap: _handleLogout,
                  ),
                ),
              ],
            );
          },
        ),
      );

  // ── helpers ─────────────────────────────────────────────────
  Widget _tile(IconData icon, String title, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray500),
        onTap: onTap,
      );

  Divider _divider() =>
      Divider(height: 1, thickness: .8, color: AppColors.gray200);

  ButtonStyle get _blueBtn => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  BoxDecoration get _cardBox => BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      );
}
