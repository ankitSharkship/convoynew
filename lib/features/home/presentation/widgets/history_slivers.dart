import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';
import '../../../search/presentation/state/search_notifier.dart';
import '../state/home_notifier.dart';

// ─── Tab item ───────────────────────────────────────────────────────────────

class TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabItem({
    super.key,
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
// "something went wrong" state — the rest of the page is unaffected.
//
// [limit] caps how many items render (used on Home's compact preview); pass
// null to show everything (used on the full Manage Posts & Searches page).

class PostHistorySliver extends ConsumerWidget {
  final int? limit;

  const PostHistorySliver({super.key, this.limit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postHistoryNotifierProvider);
    return postsAsync.when(
      loading: () => const SectionLoadingSliver(),
      error: (e, _) => SectionErrorSliver(
        onRetry: () => ref.invalidate(postHistoryNotifierProvider),
      ),
      data: (posts) => RecentPostsSliver(posts: posts, limit: limit),
    );
  }
}

class SearchHistorySliver extends ConsumerWidget {
  final int? limit;

  const SearchHistorySliver({super.key, this.limit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync = ref.watch(searchHistoryNotifierProvider);
    return searchesAsync.when(
      loading: () => const SectionLoadingSliver(),
      error: (e, _) => SectionErrorSliver(
        onRetry: () => ref.invalidate(searchHistoryNotifierProvider),
      ),
      data: (searches) => RecentSearchSliver(searches: searches, limit: limit),
    );
  }
}

class SectionLoadingSliver extends StatelessWidget {
  const SectionLoadingSliver({super.key});

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

class SectionErrorSliver extends StatelessWidget {
  final VoidCallback onRetry;

  const SectionErrorSliver({super.key, required this.onRetry});

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

class RecentPostsSliver extends StatelessWidget {
  final List<TripEntity> posts;
  final int? limit;

  const RecentPostsSliver({super.key, required this.posts, this.limit});

  @override
  Widget build(BuildContext context) {
    final list = limit == null ? posts : posts.take(limit!).toList();

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
        return PostCard(trip: list[i ~/ 2]);
      }, childCount: list.length * 2 - 1),
    );
  }
}

class PostCard extends StatelessWidget {
  final TripEntity trip;

  const PostCard({super.key, required this.trip});

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

class RecentSearchSliver extends ConsumerWidget {
  final List<SearchHistoryEntity> searches;
  final int? limit;

  const RecentSearchSliver({super.key, required this.searches, this.limit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = limit == null ? searches : searches.take(limit!).toList();

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
        return SearchCard(search: list[i ~/ 2]);
      }, childCount: list.length * 2 - 1),
    );
  }
}

class SearchCard extends ConsumerWidget {
  final SearchHistoryEntity search;

  const SearchCard({super.key, required this.search});

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
