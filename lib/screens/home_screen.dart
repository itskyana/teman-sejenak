import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teman_sejenak/screens/guide_list_screen.dart';
import 'package:teman_sejenak/utils/app_colors.dart';

import 'place_detail_screen.dart';
import 'place_list_screen.dart';
import 'guide_detail_screen.dart';
import '../models/destination.dart';
import '../models/guide.dart';
import '../utils/json_loader.dart';
import '../widgets/popular_card.dart';
import '../widgets/nearby_card.dart';
import '../widgets/guide_card.dart';
import '../presentation/providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── data ──────────────────────────────────────────────────────────
  List<Destination> destinations = [];
  List<Destination> filteredDestinations = [];
  List<Guide> guides = [];

  // ── filter ───────────────────────────────────────────────────────
  String? _selectedCategory;

  // ── carousel hero ────────────────────────────────────────────────
  final _pageCtrl = PageController(viewportFraction: .9);
  int _currentPage = 0;
  Timer? _autoPlay;

  final _heroImages = const [
    'https://picsum.photos/id/1018/800/400',
    'https://picsum.photos/id/1040/800/400',
    'https://picsum.photos/id/1043/800/400',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();

    // autoplay carousel
    _autoPlay = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageCtrl.hasClients) {
        _currentPage = (_currentPage + 1) % _heroImages.length;
        _pageCtrl.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // Load destinations from API via Provider
    final destinationProvider = context.read<DestinationProvider>();
    await destinationProvider.loadDestinations();
    await destinationProvider.loadPopular();
    
    // Convert API model to local model for backward compatibility
    destinations = destinationProvider.destinations.map((d) => Destination(
      id: d.id,
      title: d.title,
      type: d.type,
      location: d.location,
      imageUrl: d.imageUrl,
      description: d.description,
      distance: d.distance,
    )).toList();
    
    // Initialize filtered destinations with all destinations
    filteredDestinations = List.from(destinations);
    
    // Load guides from API via Provider
    final guideProvider = context.read<GuideProvider>();
    await guideProvider.loadGuides();
    
    // Convert API model to local model for backward compatibility
    guides = guideProvider.guides.map((g) => Guide(
      id: g.id,
      name: g.name,
      gender: g.gender,
      age: g.age,
      location: g.location,
      languages: g.languages,
      available: g.available,
      interests: g.interests,
      imageUrl: g.imageUrl,
      verified: g.verified,
      rating: g.rating,
      ordersHandled: g.ordersHandled,
      gallery: g.gallery,
      description: g.description,
    )).toList();
    
    if (mounted) setState(() {});
  }

  // ── Filter destinations by category ──────────────────────────────
  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null || category.isEmpty) {
        filteredDestinations = List.from(destinations);
      } else {
        filteredDestinations = destinations
            .where((d) => d.type.toLowerCase() == category.toLowerCase())
            .toList();
      }
    });
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg_pattern.webp',
            ), // Gambar corak kamu
            repeat: ImageRepeat.repeat,
            opacity: 0.7, // Halus dan tidak mengganggu
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildHeroCarousel(),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 24),
            _buildCategoryRow(),
            const SizedBox(height: 28),

            // ── Popular Destination ─────────────────────────────
            _buildSectionHeader(
              _selectedCategory != null 
                  ? 'Tempat $_selectedCategory' 
                  : 'Tempat yang sedang trending', 
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PlaceListScreen(
                          title: _selectedCategory != null 
                              ? 'Tempat $_selectedCategory' 
                              : 'Tempat Trending',
                          places: filteredDestinations,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            if (filteredDestinations.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: AppColors.gray400),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada tempat untuk kategori ini',
                      style: TextStyle(color: AppColors.gray500),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 219,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(bottom: 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredDestinations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder:
                      (_, i) => PopularCard(
                        destination: filteredDestinations[i],
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        PlaceDetailScreen(place: filteredDestinations[i]),
                              ),
                            ),
                      ),
                ),
              ),

            const SizedBox(height: 28),

            // ── Nearby ──────────────────────────────────────────
            _buildSectionHeader('Terdekat dari kamu', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PlaceListScreen(
                        title: 'Terdekat dari Kamu',
                        places: destinations,
                      ),
                ),
              );
            }),
            const SizedBox(height: 12),
            if (destinations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: NearbyCard(
                  destination: destinations.first.copyWith(distance: '3.5 km'),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  PlaceDetailScreen(place: destinations.first),
                        ),
                      ),
                ),
              ),

            const SizedBox(height: 32),

            // ── Top Guides ──────────────────────────────────────
            if (guides.isNotEmpty) ...[
              _buildSectionHeader('Teman yang sedang trending', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuideListScreen()),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                height: 214,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.only(bottom: 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: guides.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder:
                      (_, i) => SizedBox(
                        width: 300,
                        child: GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => GuideDetailScreen(g: guides[i]),
                                ),
                              ),
                          child: GuideCard(g: guides[i]),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ── Hero carousel widget ────────────────────────────────────────
  Widget _buildHeroCarousel() => Column(
    children: [
      SizedBox(
        height: 190,
        child: PageView.builder(
          controller: PageController(viewportFraction: 1.0),
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemCount: _heroImages.length,
          itemBuilder:
              (_, i) => GestureDetector(
                onTap: () {
                  if (i < destinations.length) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PlaceDetailScreen(place: destinations[i]),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_heroImages[i], fit: BoxFit.cover),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Text(
                          'Destinasi yang sedang trend',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _heroImages.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == i ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color:
                  _currentPage == i ? AppColors.primaryDark : AppColors.gray300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    ],
  );

  // ── Header (greeting + avatar) ──────────────────────────────────
  Widget _buildHeader() => Consumer<AuthProvider>(
    builder: (context, auth, _) {
      final firstName = auth.userName.split(' ').first;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $firstName,',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Temukan teman sejenakmu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: auth.user?.imageUrl != null
                ? NetworkImage(auth.user!.imageUrl!)
                : null,
            child: auth.user?.imageUrl == null
                ? Text(
                    auth.userInitials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ],
      );
    },
  );

  // ── Search field ────────────────────────────────────────────────
  Widget _buildSearchField() => GestureDetector(
    onTap:
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    PlaceListScreen(title: 'All places', places: destinations),
          ),
        ),
    child: AbsorbPointer(
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Mari cari tempat seru',
          hintStyle: const TextStyle(color: AppColors.gray500),
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: AppColors.gray200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );

  // ── Category chips ──────────────────────────────────────────────
  Widget _buildCategoryRow() {
    final cats = [
      {'label': 'Semua', 'icon': Icons.apps_rounded, 'value': null},
      {'label': 'Taman', 'icon': Icons.park_rounded, 'value': 'Taman'},
      {'label': 'Pantai', 'icon': Icons.beach_access_rounded, 'value': 'Pantai'},
      {'label': 'Wisata Alam', 'icon': Icons.nature_people_rounded, 'value': 'Wisata Alam'},
      {'label': 'Museum', 'icon': Icons.museum_rounded, 'value': 'Museum'},
      {'label': 'Kuliner', 'icon': Icons.restaurant_rounded, 'value': 'Kuliner'},
      {'label': 'Mall', 'icon': Icons.shopping_basket, 'value': 'Mall'},
      {'label': 'Bioskop', 'icon': Icons.movie_rounded, 'value': 'Bioskop'},
      {'label': 'Waterpark', 'icon': Icons.water_rounded, 'value': 'Waterpark'},
      {'label': 'Olahraga', 'icon': Icons.sports_baseball_rounded, 'value': 'Olahraga'},
      {'label': 'Religi', 'icon': Icons.church_rounded, 'value': 'Religi'},
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final catValue = cats[i]['value'] as String?;
          final sel = _selectedCategory == catValue;
          return ChoiceChip(
            selected: sel,
            showCheckmark: false,
            onSelected: (_) => _filterByCategory(catValue),
            avatar: Icon(
              cats[i]['icon'] as IconData,
              size: 18,
              color: sel ? AppColors.background : AppColors.primaryDark,
            ),
            label: Text(cats[i]['label'] as String),
            labelStyle: TextStyle(
              color: sel ? AppColors.background : AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: AppColors.gray100,
            selectedColor: AppColors.primary,
          );
        },
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      TextButton(
        onPressed: onSeeAll,
        child: const Text(
          'Lihat Semua',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
