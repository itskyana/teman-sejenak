import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

import '../models/destination.dart';
import '../models/guide.dart';
import '../utils/json_loader.dart';
import '../widgets/guide_card.dart';
import 'guide_detail_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Destination place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<Guide> guides = [];

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    final list = await JsonLoader.loadList<Guide>(
      'guide_data.json',
      Guide.fromJson,
    );
    setState(() => guides = list);
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
              background: Image.network(
                widget.place.imageUrl,
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

          // ── Guide list (gaya GuideListScreen) ─────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, idx) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuideDetailScreen(g: guides[idx]),
                          ),
                        ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GuideCard(g: guides[idx]),
                    ),
                  ),
                ),
                childCount: guides.length,
              ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 4),
              Text(place.location, style: const TextStyle(color: AppColors.gray600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            place.description,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Text(
            'Teman Sejenak sekitar sini :',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
