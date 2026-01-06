import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/shared.dart';
import '../../data/models/models.dart';

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
                  AppAvatar(imageUrl: g.imageUrl, name: g.name, radius: 48),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(g.name, style: AppTextStyles.heading3),
                      if (g.verified) ...[
                        const SizedBox(width: 6),
                        AppBadge.info('Verified', icon: Icons.verified_rounded),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${g.gender}, ${g.age} • Teman Sejenak',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray700,
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
                children: g.available
                    .map((a) => AppBadge.warning(a))
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
                children: g.interests
                    .map((i) => AppBadge.success(i))
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
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 24),

            // ── Tombol aksi ─────────────────────────────────────
            Row(
              children: [
                // Let's Meet button
                Expanded(
                  child: PrimaryButton(
                    text: 'Ayo Bertemu',
                    onPressed: () {
                      // TODO: Navigate to order screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur order akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Let's Chat button
                Expanded(
                  child: SecondaryButton(
                    text: 'Ayo Ngobrol',
                    onPressed: () {
                      // TODO: Navigate to chat screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur chat akan segera hadir!'),
                        ),
                      );
                    },
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
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(imageUrl: g.gallery[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── helper widgets ──────────────────────────────────
  Widget _ratingRow() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 16, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            g.rating.toStringAsFixed(1),
            style: AppTextStyles.labelLarge,
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
            Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
          ],
        ),
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: AppTextStyles.labelLarge,
      );
}
