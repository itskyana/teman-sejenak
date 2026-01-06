import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../shared/shared.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import 'guide_detail_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Destination place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load guides through provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideProvider>().loadGuides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero / Collapsible ────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * .45,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(
                imageUrl: widget.place.imageUrl,
                fit: BoxFit.cover,
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // ── Summary card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _SummaryCard(place: widget.place),
            ),
          ),

          // ── Guide list ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: Consumer<GuideProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.guides.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(height: 100, child: LoadingWidget()),
                  );
                }

                if (provider.guides.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyWidget(
                      message: 'Tidak ada teman tersedia',
                      icon: Icons.people_outline,
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GuideListItem(
                        guide: provider.guides[idx],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GuideDetailScreen(g: provider.guides[idx]),
                          ),
                        ),
                      ),
                    ),
                    childCount: provider.guides.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card widget ───────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final Destination place;
  const _SummaryCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.title, style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 4),
              Text(
                place.location,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            place.description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray700),
          ),
          const SizedBox(height: 20),
          Text('Teman Sejenak sekitar sini :', style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

// ── Guide list item widget ───────────────────────────────────────────
class _GuideListItem extends StatelessWidget {
  final Guide guide;
  final VoidCallback onTap;
  const _GuideListItem({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AppAvatar(imageUrl: guide.imageUrl, name: guide.name, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          guide.name,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (guide.verified) AppBadge.verified(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        guide.rating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Text(guide.genderAgeText, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          guide.location,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
