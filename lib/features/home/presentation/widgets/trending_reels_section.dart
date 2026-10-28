import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../reels/domain/entities/reel_entity.dart';
import '../../../reels/presentation/state/reels_notifier.dart';
import '../../../reels/domain/entities/reels_feed_key.dart';

const _trendingReelsPreviewLimit = 8;
const _reelCardWidth = 150.0;
const _reelCardHeight = 220.0;

/// Horizontal rail of recent reel thumbnails between Quick Actions and the
/// Manage Post & Searches section. Shares [reelsFeedNotifierProvider] with
/// the full-screen Reels tab, the same way the post/search history sections
/// share their provider with the "view all" screen — this is just a preview
/// of the same feed, not a separately-fetched list.
class TrendingReelsSection extends ConsumerWidget {
  const TrendingReelsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(reelsFeedNotifierProvider(const ReelsFeedKey()));
    final l10n = AppLocalizations.of(context)!;

    // Nothing loaded, nothing in flight, nothing to retry — rather than a
    // permanent empty-state card, the section just doesn't take up space.
    if (feed.items.isEmpty && !feed.isLoading && feed.error == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.theaters_outlined,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.homeTrendingReels,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/reels'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.homeViewFeed,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _reelCardHeight,
          child: feed.items.isEmpty
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: feed.items
                      .take(_trendingReelsPreviewLimit)
                      .length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return _ReelThumbnailCard(
                      reel: feed.items[i],
                      onTap: () => context.go('/reels'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ReelThumbnailCard extends StatelessWidget {
  final ReelEntity reel;
  final VoidCallback onTap;

  const _ReelThumbnailCard({required this.reel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _reelCardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (reel.thumbnailUrl != null)
                Image.network(
                  reel.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.primaryDark),
                )
              else
                const ColoredBox(color: AppColors.primaryDark),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _AuthorAvatar(author: reel.author),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reel.author?.name ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reel.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final ReelAuthorEntity? author;

  const _AuthorAvatar({required this.author});

  @override
  Widget build(BuildContext context) {
    final photo = author?.profilePhoto;
    final name = author?.name?.trim();
    final initial = (name != null && name.isNotEmpty)
        ? name[0].toUpperCase()
        : '?';

    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photo != null
          ? Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _InitialText(initial: initial),
            )
          : _InitialText(initial: initial),
    );
  }
}

class _InitialText extends StatelessWidget {
  final String initial;

  const _InitialText({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
