import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

import '../models/guide.dart';
import '../models/destination.dart'; // diperlukan untuk OrderScreen
import '../screens/chat_screen.dart';
import '../screens/order_screen.dart';

class GuideDetailScreen extends StatelessWidget {
  final Guide g;
  const GuideDetailScreen({super.key, required this.g});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Teman'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── Header (foto, nama, rating) ─────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(g.imageUrl),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        g.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (g.verified) ...[
                        const SizedBox(width: 6),
                        _badge('Verified', AppColors.info),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${g.gender}, ${g.age} • Teman Sejenak',
                    style: const TextStyle(
                      color: AppColors.gray700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ratingRow(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Info section ─────────────────────────────────────
            _sectionTitle('Biodata Diri'),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_outlined, g.location),
            _infoRow(
              Icons.language_rounded,
              'Bahasa: ${g.languages.join(', ')}',
            ),
            _infoRow(
              Icons.check_circle_outline_rounded,
              'Sudah berteman: ${g.ordersHandled}',
            ),

            // Available badges
            if (g.available.isNotEmpty) ...[
              _infoRow(Icons.access_time_rounded, 'Tersedia pada waktu:'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    g.available
                        .map((a) => _badge(a, AppColors.warning))
                        .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Interests badges
            if (g.interests.isNotEmpty) ...[
              _infoRow(Icons.local_activity_outlined, 'Minat:'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    g.interests
                        .map((i) => _badge(i, AppColors.success))
                        .toList(),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 16),

            // ── About section ────────────────────────────────────
            _sectionTitle('Tentang ${g.name}'),
            const SizedBox(height: 6),
            Text(
              (g.description == null || g.description!.trim().isEmpty)
                  ? 'Dia tidak menuliskan deskripsi.'
                  : g.description!,
              style: const TextStyle(fontSize: 13, height: 1.4),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 24),

            // ── Tombol aksi ─────────────────────────────────────
            Row(
              children: [
                // ===== Let’s Meet -> OrderScreen =========
                Expanded(
                  child: ElevatedButton(
                    style: _blueBtn,
                    onPressed: () {
                      // Jika sudah punya Destination asli, kirimkan objeknya
                      final destDummy = Destination(
                        title: g.location.split(',').first, // nama singkat
                        location: g.location,
                        description: 'Bertemu dengan ${g.name}',
                        imageUrl: g.imageUrl,
                        distance: null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => OrderScreen(place: destDummy, guide: g),
                        ),
                      );
                    },
                    child: Text(
                      "Ayo Bertemu",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // ===== Let’s Chat -> ChatScreen =========
                Expanded(
                  child: OutlinedButton(
                    style: _outlineBtn,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatScreen(guide: g)),
                      );
                    },
                    child: Text(
                      "Ayo Ngobrol",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Galeri grid ─────────────────────────────────────
            if (g.gallery.isNotEmpty) ...[
              _sectionTitle('Galeri ${g.name}'),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: g.gallery.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder:
                    (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(g.gallery[i], fit: BoxFit.cover),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── helper styles/widgets ──────────────────────────────────
  ButtonStyle get _blueBtn => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.background,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  ButtonStyle get _outlineBtn => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    minimumSize: const Size(0, 48),
    side: const BorderSide(color: AppColors.primary, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _ratingRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.star, size: 16, color: AppColors.warning),
      const SizedBox(width: 4),
      Text(
        g.rating.toStringAsFixed(1),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  Widget _badge(String label, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg.withOpacity(0.15), // latar belakang tipis
      border: Border.all(color: bg), // outline tegas
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: bg, // warna teks sama dengan border
      ),
    ),
  );
}
