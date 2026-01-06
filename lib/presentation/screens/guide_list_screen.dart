import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../shared/shared.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import 'place_detail_screen.dart';
import 'guide_detail_screen.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuideProvider>().loadGuides();
      context.read<DestinationProvider>().loadDestinations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Guide> _filterGuides(List<Guide> guides) {
    if (_searchQuery.isEmpty) return guides;
    final lower = _searchQuery.toLowerCase();
    return guides
        .where(
          (g) =>
              g.name.toLowerCase().contains(lower) ||
              g.location.toLowerCase().contains(lower) ||
              g.languages.join(',').toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teman yang Bisa Diandalkan'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Hero - Near you destination
            Consumer<DestinationProvider>(
              builder: (context, provider, _) {
                final nearby = provider.destinations.isNotEmpty
                    ? provider.destinations.firstWhere(
                        (d) => d.location.toLowerCase().contains('bogor'),
                        orElse: () => provider.destinations.first,
                      )
                    : null;

                if (nearby == null) return const SizedBox.shrink();
                return _NearYouHero(place: nearby);
              },
            ),
            const SizedBox(height: 12),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SearchTextField(
                hint: 'Cari nama, lokasi, atau bahasa',
                controller: _searchCtrl,
                onChanged: (q) {
                  setState(() => _searchQuery = q);
                },
              ),
            ),

            // Guide list
            Expanded(
              child: Consumer<GuideProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.guides.isEmpty) {
                    return const LoadingWidget();
                  }

                  final filtered = _filterGuides(provider.guides);

                  if (filtered.isEmpty) {
                    return const EmptyWidget(
                      message: 'Tidak ada teman ditemukan',
                      icon: Icons.people_outline,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _GuideCard(
                      guide: filtered[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuideDetailScreen(g: filtered[i]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero widget "Near You" ──────────────────────────────────────────
class _NearYouHero extends StatelessWidget {
  final Destination place;
  const _NearYouHero({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(place.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(.55), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tempat Terdekat',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gray100,
                ),
              ),
              Text(
                place.title,
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.gray100,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.location,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Guide card widget ──────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback onTap;
  const _GuideCard({required this.guide, required this.onTap});

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
                  if (guide.interests.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: guide.interests
                          .take(3)
                          .map((i) => AppBadge.success(i))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
