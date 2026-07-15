import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';
import '../../../search/presentation/state/search_notifier.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../state/home_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final displayName = profileAsync.valueOrNull?.name ?? 'Pilot';

    // No full-page loading/error gate here: the greeting, hero banner and
    // quick actions don't depend on any of this screen's remote data, so
    // they always render immediately. Only the "Manage Post & Searches"
    // section below watches its own (independent, per-tab) history
    // providers and shows its own loading/error state, scoped to itself.
    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: _HomeContent(userName: displayName),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final String userName;

  const _HomeContent({required this.userName});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.userName.split(' ').first;
    final l10n = AppLocalizations.of(context)!;

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
                            Text(
                              l10n.homeHello,
                              style: const TextStyle(
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
                      const LanguageSwitcherButton(),
                      // const SizedBox(width: 10),
                      // const _IconButton(
                      //   icon: Icons.notifications_none_rounded,
                      //   showBadge: true,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _HeroBanner(
                    onPostTap: () => navigateToPostTruck(context, ref),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    l10n.homeQuickActions,
                    style: const TextStyle(
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
                          title: l10n.homePostNewTruck,
                          subtitle: l10n.homePostNewTruckSubtitle,
                          onTap: () => navigateToPostTruck(context, ref),
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
                          title: l10n.homeSearchTrucks,
                          subtitle: l10n.homeSearchTrucksSubtitle,
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    l10n.homeManageSection,
                    style: const TextStyle(
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
                          label: l10n.homeRecentPosts,
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        _TabItem(
                          label: l10n.homeRecentSearch,
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
                ? const _PostHistorySliver()
                : const _SearchHistorySliver(),
          ),
        ],
      ),
    );
  }
}

// ─── Hero banner ────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final VoidCallback onPostTap;

  const _HeroBanner({required this.onPostTap});

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
                  Text(
                    AppLocalizations.of(context)!.homeHeroTitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.homeHeroSubtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: onPostTap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.homeHeroButton,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
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

// ─── Section-scoped async wrappers ──────────────────────────────────────────
//
// Each section watches its own history provider independently, so a failure
// fetching one list only replaces that section's content with a small
// "something went wrong" state — the rest of the Home screen is unaffected.

class _PostHistorySliver extends ConsumerWidget {
  const _PostHistorySliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postHistoryNotifierProvider);
    return postsAsync.when(
      loading: () => const _SectionLoadingSliver(),
      error: (e, _) => _SectionErrorSliver(
        onRetry: () => ref.invalidate(postHistoryNotifierProvider),
      ),
      data: (posts) => _RecentPostsSliver(posts: posts),
    );
  }
}

class _SearchHistorySliver extends ConsumerWidget {
  const _SearchHistorySliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync = ref.watch(searchHistoryNotifierProvider);
    return searchesAsync.when(
      loading: () => const _SectionLoadingSliver(),
      error: (e, _) => _SectionErrorSliver(
        onRetry: () => ref.invalidate(searchHistoryNotifierProvider),
      ),
      data: (searches) => _RecentSearchSliver(searches: searches),
    );
  }
}

class _SectionLoadingSliver extends StatelessWidget {
  const _SectionLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionErrorSliver extends StatelessWidget {
  final VoidCallback onRetry;

  const _SectionErrorSliver({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 28,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.somethingWentWrong,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent posts sliver ────────────────────────────────────────────────────

class _RecentPostsSliver extends StatelessWidget {
  final List<TripEntity> posts;

  const _RecentPostsSliver({required this.posts});

  @override
  Widget build(BuildContext context) {
    final list = posts.take(3).toList();

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(AppLocalizations.of(context)!.homeNoRecentPosts),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        if (i.isOdd) return const SizedBox(height: 10);
        return _PostCard(trip: list[i ~/ 2]);
      }, childCount: list.length * 2 - 1),
    );
  }
}

class _PostCard extends StatelessWidget {
  final TripEntity trip;

  const _PostCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final originLabel = trip.origin.city ?? trip.origin.name;
    final destinationLabel = trip.destinations.isNotEmpty
        ? (trip.destinations.first.city ?? trip.destinations.first.name)
        : l10n.resultsAnyDestination;
    final dateText = DateFormat(
      'd MMM y',
      Localizations.localeOf(context).toString(),
    ).format(trip.createdAt);

    return GestureDetector(
      onTap: () => context.push('/profile/trips'),
      child: Container(
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
                    '$originLabel → $destinationLabel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.vehicleNumber} · $dateText',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent search sliver ───────────────────────────────────────────────────

class _RecentSearchSliver extends ConsumerWidget {
  final List<SearchHistoryEntity> searches;

  const _RecentSearchSliver({required this.searches});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = searches.take(3).toList();

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(AppLocalizations.of(context)!.homeNoRecentSearches),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((_, i) {
        if (i.isOdd) return const SizedBox(height: 10);
        return _SearchCard(search: list[i ~/ 2]);
      }, childCount: list.length * 2 - 1),
    );
  }
}

class _SearchCard extends ConsumerWidget {
  final SearchHistoryEntity search;

  const _SearchCard({required this.search});

  // Navigates immediately and lets the results screen's own skeleton loader
  // show while the search runs, rather than waiting here before pushing.
  void _repeat(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    ref
        .read(searchNotifierProvider.notifier)
        .repeatSearch(
          origin: search.origin,
          destination: search.destination,
          truckType: search.truckType,
          capacityDisplay: search.capacity != null
              ? l10n.capacityTon(search.capacity!)
              : null,
        );
    context.push('/search/results');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final originLabel =
        search.origin?.city ?? search.origin?.name ?? l10n.resultsAnyOrigin;
    final destinationLabel =
        search.destination?.city ??
        search.destination?.name ??
        l10n.resultsAnyDestination;
    final dateText = DateFormat(
      'd MMM y',
      Localizations.localeOf(context).toString(),
    ).format(search.searchedAt);

    final metaParts = <String>[
      if (search.truckType != null) truckTypeLabel(context, search.truckType!),
      if (search.capacity != null) l10n.capacityTon(search.capacity!),
      dateText,
    ];

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
                  '$originLabel → $destinationLabel',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metaParts.join(' · '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _repeat(context, ref, l10n),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, size: 18, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
