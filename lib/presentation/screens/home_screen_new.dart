import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../shared/shared.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import 'place_detail_screen.dart';
import 'place_list_screen.dart';
import 'guide_detail_screen.dart';
import 'guide_list_screen.dart';

/// Home screen - main dashboard of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Carousel state
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  final _heroImages = const [
    'https://picsum.photos/id/1018/800/400',
    'https://picsum.photos/id/1040/800/400',
    'https://picsum.photos/id/1043/800/400',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startAutoPlay();
  }

  void _initializeData() {
    // Load data using providers
    final destinationProvider = context.read<DestinationProvider>();
    final guideProvider = context.read<GuideProvider>();

    destinationProvider.loadDestinations();
    destinationProvider.loadPopular();
    guideProvider.loadGuides();
    guideProvider.loadFeatured();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(AppConstants.carouselInterval, (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _heroImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: AppConstants.defaultAnimationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.bgPattern),
            repeat: ImageRepeat.repeat,
            opacity: 0.7,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
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
              _buildPopularSection(),
              const SizedBox(height: 28),
              _buildNearbySection(),
              const SizedBox(height: 28),
              _buildGuidesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final destinationProvider = context.read<DestinationProvider>();
    final guideProvider = context.read<GuideProvider>();

    await Future.wait([
      destinationProvider.loadDestinations(),
      destinationProvider.loadPopular(),
      guideProvider.loadGuides(),
      guideProvider.loadFeatured(),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Row(
          children: [
            AppAvatar(
              imageUrl: auth.user?.imageUrl,
              name: auth.userName,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${auth.user?.firstName ?? "Sobat"}! 👋',
                    style: AppTextStyles.heading4,
                  ),
                  Text('Mau kemana hari ini?', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            CircularIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _heroImages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppNetworkImage(
                imageUrl: _heroImages[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return SearchTextField(
      hint: 'Cari destinasi atau teman...',
      onSubmitted: (query) {
        // TODO: Navigate to search results
      },
    );
  }

  Widget _buildCategoryRow() {
    final categories = [
      _CategoryItem(Icons.landscape_rounded, 'Alam', AppColors.success),
      _CategoryItem(Icons.museum_rounded, 'Budaya', AppColors.warning),
      _CategoryItem(Icons.restaurant_rounded, 'Kuliner', AppColors.danger),
      _CategoryItem(Icons.beach_access_rounded, 'Pantai', AppColors.info),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories.map((cat) => _buildCategoryItem(cat)).toList(),
    );
  }

  Widget _buildCategoryItem(_CategoryItem category) {
    return GestureDetector(
      onTap: () {
        // TODO: Filter by category
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(category.label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildPopularSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Tempat Trending',
          onSeeAll: () => _navigateToPlaceList('Tempat Trending'),
        ),
        const SizedBox(height: 12),
        Consumer<DestinationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.popularDestinations.isEmpty) {
              return const SizedBox(height: 200, child: LoadingWidget());
            }

            if (provider.popularDestinations.isEmpty) {
              return const EmptyWidget(
                message: 'Tidak ada destinasi',
                icon: Icons.location_off_outlined,
              );
            }

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: provider.popularDestinations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final destination = provider.popularDestinations[index];
                  return _DestinationCard(
                    destination: destination,
                    onTap: () => _navigateToPlaceDetail(destination),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNearbySection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Terdekat dari Kamu',
          onSeeAll: () => _navigateToPlaceList('Terdekat'),
        ),
        const SizedBox(height: 12),
        Consumer<DestinationProvider>(
          builder: (context, provider, _) {
            final destinations = provider.destinations.take(3).toList();

            if (destinations.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children:
                  destinations.map((d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NearbyCard(
                        destination: d,
                        onTap: () => _navigateToPlaceDetail(d),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGuidesSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Teman Pilihan',
          onSeeAll: () => _navigateToGuideList(),
        ),
        const SizedBox(height: 12),
        Consumer<GuideProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.featuredGuides.isEmpty) {
              return const SizedBox(height: 150, child: LoadingWidget());
            }

            if (provider.featuredGuides.isEmpty) {
              return const EmptyWidget(
                message: 'Tidak ada teman tersedia',
                icon: Icons.people_outline,
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: provider.featuredGuides.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final guide = provider.featuredGuides[index];
                  return _GuideCard(
                    guide: guide,
                    onTap: () => _navigateToGuideDetail(guide),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════

  void _navigateToPlaceList(String title) {
    final destinations = context.read<DestinationProvider>().destinations;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceListScreen(title: title, places: destinations),
      ),
    );
  }

  void _navigateToPlaceDetail(Destination destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: destination)),
    );
  }

  void _navigateToGuideList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GuideListScreen()),
    );
  }

  void _navigateToGuideDetail(Guide guide) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuideDetailScreen(g: guide)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;

  _CategoryItem(this.icon, this.label, this.color);
}

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(
              imageUrl: destination.imageUrl,
              height: 110,
              width: 160,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
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
          ],
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _NearbyCard({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              imageUrl: destination.imageUrl,
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        destination.location,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (destination.distance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    destination.distance!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback onTap;

  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        guide.interests.take(2).map((interest) {
                          return AppBadge.success(interest);
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
