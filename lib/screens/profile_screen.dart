import 'package:flutter/material.dart';
import 'package:flutter_ins/screens/login_screen.dart';
import 'package:flutter_ins/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── dummy user data (bisa diganti dari storage / provider) ─────────────
  Map<String, String> get _user => {
        'name'     : 'Lukman Hakim',
        'email'    : 'lukman.hakim@email.com',
        'location' : 'Depok, Indonesia',
        'avatar'   : 'https://picsum.photos/seed/profile/200',
      };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profil Kamu'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: ListView(
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
                    backgroundImage: NetworkImage(_user['avatar']!),
                  ),
                  const SizedBox(height: 12),
                  Text(_user['name']!,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(_user['location']!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(_user['email']!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {},
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
                title: const Text('Logout',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
                onTap: () {
                  // tampilkan feedback singkat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil Logout')),
                  );

                  // hapus semua halaman & buka LoginScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
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
