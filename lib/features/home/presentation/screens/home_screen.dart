import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/loader.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/truck_listing_entity.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../../../../shared/widgets/truck_card.dart';
import '../state/home_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeNotifierProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final displayName = profileAsync.valueOrNull?.name ?? 'Pilot';

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: homeAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => _HomeContent(data: data, userName: displayName),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final HomeDataEntity data;
  final String userName;

  const _HomeContent({required this.data, required this.userName});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.userName.split(' ').first;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _IconButton(icon: Icons.translate),
                      // const SizedBox(width: 10),
                      // const _IconButton(
                      //   icon: Icons.notifications_none_rounded,
                      //   showBadge: true,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const _HeroBanner(),
                  const SizedBox(height: 24),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add,
                          iconColor: AppColors.primaryBlue,
                          iconBackground: AppColors.primaryBlueLight,
                          title: 'Post New Truck',
                          subtitle: 'Ready in 30 seconds',
                          onTap: () => context.go('/post'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.search,
                          iconColor: AppColors.primaryDark,
                          iconBackground: AppColors.primaryDark.withValues(
                            alpha: 0.1,
                          ),
                          title: 'Search Trucks',
                          subtitle: 'Find available vehicles',
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Manage Post & Searches',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab selector
                  Container(
                    height: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _TabItem(
                          label: 'Recent Posts',
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        _TabItem(
                          label: 'Recent Search',
                          selected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Tab content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: _selectedTab == 0
                ? _RecentPostsSliver(posts: widget.data.recentPosts)
                : _RecentSearchSliver(trucks: widget.data.nearbyTrucks),
          ),
        ],
      ),
    );
  }
}

// ─── Header icon button ─────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool showBadge;

  const _IconButton({required this.icon, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: 20, color: AppColors.textPrimary)),
          if (showBadge)
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Hero banner ────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppColors.primaryDark,
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: 0,
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/truck.png',
                  width: 150,
                  height: 130,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 130, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your truck is ready\nto earn 💰',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Post now and get verified load requests instantly.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => context.go('/post'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Post Truck Now', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
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

// ─── Quick action card ──────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab item ───────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recent posts sliver ────────────────────────────────────────────────────

class _RecentPostsSliver extends StatelessWidget {
  final List<RecentPostEntity> posts;

  const _RecentPostsSliver({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('No recent posts')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        if (i.isOdd) return const SizedBox(height: 10);
        final p = posts[i ~/ 2];
        return _PostCard(post: p);
      }, childCount: posts.length * 2 - 1),
    );
  }
}

class _PostCard extends StatelessWidget {
  final RecentPostEntity post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.origin} → ${post.destination}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.vehicleNumber} · ${post.postedDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Repost', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Recent search sliver ───────────────────────────────────────────────────

class _RecentSearchSliver extends StatelessWidget {
  final List<TruckListingEntity> trucks;

  const _RecentSearchSliver({required this.trucks});

  @override
  Widget build(BuildContext context) {
    final list = trucks.take(3).toList();

    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('No recent searches')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        if (i.isOdd) return const SizedBox(height: 10);
        return TruckCard(truck: list[i ~/ 2]);
      }, childCount: list.length * 2 - 1),
    );
  }
}
