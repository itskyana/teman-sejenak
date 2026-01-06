import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/shared.dart';
import '../../data/models/models.dart';
import 'place_detail_screen.dart';

class PlaceListScreen extends StatefulWidget {
  final String title;
  final List<Destination> places;
  const PlaceListScreen({super.key, required this.title, required this.places});

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  final _searchCtrl = TextEditingController();
  late List<Destination> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.places;
  }

  void _runSearch(String query) {
    setState(() {
      _filtered = widget.places
          .where(
            (d) =>
                d.title.toLowerCase().contains(query.toLowerCase()) ||
                d.location.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.danger),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceListScreen(
                    title: 'Favorite place',
                    places: widget.places,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search field ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SearchTextField(
                hint: 'Search place…',
                controller: _searchCtrl,
                onChanged: _runSearch,
              ),
            ),
            // ── List ────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? const EmptyWidget(
                      message: 'Tidak ada hasil',
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _PlaceCard(
                        place: _filtered[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlaceDetailScreen(place: _filtered[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Destination place;
  final VoidCallback onTap;
  const _PlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: AppNetworkImage(
                imageUrl: place.imageUrl,
                width: 88,
                height: 88,
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: AppTextStyles.labelLarge,
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
                        Flexible(
                          child: Text(
                            place.location,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
