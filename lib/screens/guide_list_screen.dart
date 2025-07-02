import 'package:flutter/material.dart';
import 'package:flutter_ins/screens/root_navigator.dart';
import 'package:flutter_ins/utils/app_colors.dart';

import '../models/guide.dart';
import '../models/destination.dart';
import '../utils/json_loader.dart';
import '../widgets/guide_card.dart';
import 'place_detail_screen.dart';
import 'guide_detail_screen.dart';

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  final _searchCtrl = TextEditingController();

  List<Guide> _guides = [];
  List<Guide> _filtered = [];
  Destination? _nearby; // hero (nullable)

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // load guides
    final guides = await JsonLoader.loadList<Guide>(
      'guide_data.json',
      Guide.fromJson,
    );

    // load destinations
    final dests = await JsonLoader.loadList<Destination>(
      'destination_data.json',
      Destination.fromJson,
    );

    Destination? near;
    if (dests.isNotEmpty) {
      near = dests.firstWhere(
        (d) => d.location.toLowerCase().contains('bogor'),
        orElse: () => dests.first,
      );
    }

    setState(() {
      _guides = guides;
      _filtered = guides;
      _nearby = near;
    });
  }

  void _runSearch(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered =
          _guides
              .where(
                (g) =>
                    g.name.toLowerCase().contains(lower) ||
                    g.location.toLowerCase().contains(lower) ||
                    g.languages.join(',').toLowerCase().contains(lower),
              )
              .toList();
    });
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RootNavigation(initialIndex: 0)),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_nearby != null) _NearYouHero(place: _nearby!),
            const SizedBox(height: 12),

            // search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _runSearch,
                decoration: InputDecoration(
                  hintText: 'Cari nama, lokasi, atau bahasa',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.gray200,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder:
                    (_, i) => GestureDetector(
                      // 🆕 tapable
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => GuideDetailScreen(g: _filtered[i]),
                            ),
                          ),
                      child: GuideCard(g: _filtered[i]),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero widget “Near You” ──────────────────────────────────────────
class _NearYouHero extends StatelessWidget {
  final Destination place;
  const _NearYouHero({required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
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
              const Text(
                'Tempat Terdekat',
                style: TextStyle(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                place.title,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
                    style: const TextStyle(
                      color: AppColors.gray100,
                      fontSize: 12,
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
