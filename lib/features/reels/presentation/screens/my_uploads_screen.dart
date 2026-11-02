import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../domain/entities/my_uploads_entity.dart';
import '../state/my_uploads_notifier.dart';
import '../widgets/reel_formatters.dart';
import '../widgets/reel_delete.dart';

/// The signed-in user's own reels: creator totals up top, category tabs, and
/// a two-column grid with views / likes / posted-ago per reel.
class MyUploadsScreen extends ConsumerStatefulWidget {
  const MyUploadsScreen({super.key});

  @override
  ConsumerState<MyUploadsScreen> createState() => _MyUploadsScreenState();
}

class _MyUploadsScreenState extends ConsumerState<MyUploadsScreen> {
  /// `null` = the "All Reels" tab.
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uploads = ref.watch(myUploadsProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlueLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.profileMyUploads,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [
          LanguageSwitcherButton(card: false),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/reels/create/record'),
        icon: const Icon(Icons.videocam),
        label: Text(
          l10n.uploadsRecordCta,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: uploads.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  ApiException.messageFor(e),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(myUploadsProvider),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _buildContent(context, l10n, data),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    MyUploadsEntity data,
  ) {
    // Category tabs are built from the categories the user has actually used.
    final categoryCounts = <String, ({String name, int count})>{};
    for (final item in data.items) {
      for (final c in item.reel.categories) {
        final prev = categoryCounts[c.id];
        categoryCounts[c.id] = (name: c.name, count: (prev?.count ?? 0) + 1);
      }
    }
    final selectedId = categoryCounts.containsKey(_selectedCategoryId)
        ? _selectedCategoryId
        : null;
    final visible = selectedId == null
        ? data.items
        : data.items
              .where((i) => i.reel.categories.any((c) => c.id == selectedId))
              .toList();

    final weekAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    final thisWeek = data.items
        .where((i) => i.reel.createdAt.isAfter(weekAgo))
        .length;
    final totalComments = data.items.fold<int>(
      0,
      (sum, i) => sum + i.reel.commentCount,
    );

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myUploadsProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _InsightsCard(
              data: data,
              thisWeek: thisWeek,
              totalComments: totalComments,
            ),
          ),
          if (data.items.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  children: [
                    _TabChip(
                      label: l10n.uploadsAllReelsTab(data.items.length),
                      selected: selectedId == null,
                      onTap: () => setState(() => _selectedCategoryId = null),
                    ),
                    for (final entry in categoryCounts.entries)
                      _TabChip(
                        label: l10n.uploadsCategoryTab(
                          entry.value.name,
                          entry.value.count,
                        ),
                        selected: selectedId == entry.key,
                        onTap: () =>
                            setState(() => _selectedCategoryId = entry.key),
                      ),
                  ],
                ),
              ),
            ),
          if (data.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  l10n.uploadsEmpty,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                itemCount: visible.length,
                itemBuilder: (context, i) => _UploadCard(item: visible[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final MyUploadsEntity data;
  final int thisWeek;
  final int totalComments;

  const _InsightsCard({
    required this.data,
    required this.thisWeek,
    required this.totalComments,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.primaryBlue,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.uploadsCreatorInsights,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue.withValues(
                    alpha: 0.12,
                  ),
                  foregroundColor: AppColors.primaryBlueDark,
                  shape: const StadiumBorder(),
                ),
                onPressed: () => context.push('/reels/create/record'),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(l10n.uploadsNewPost),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.uploadsStatReels,
                  value: '${data.totalReels}',
                  footer: thisWeek > 0 ? l10n.uploadsThisWeek(thisWeek) : null,
                  footerColor: AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.uploadsStatTotalViews,
                  value: formatCount(data.totalViews),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.uploadsStatAppreciation,
                  value: formatCount(data.totalLikes),
                  valueColor: AppColors.primaryBlueDark,
                  footer:
                      '${formatCount(data.totalLikes)} ♥ • ${formatCount(totalComments)} 💬',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? footer;
  final Color? footerColor;

  const _StatTile({
    required this.label,
    required this.value,
    this.valueColor,
    this.footer,
    this.footerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            footer ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: footerColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _CardAction { delete }

class _UploadCard extends ConsumerWidget {
  final MyUploadItemEntity item;

  const _UploadCard({required this.item});

  String _duration(int? seconds) {
    if (seconds == null) return '';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _postedAgo(AppLocalizations l10n, DateTime at) {
    final days = DateTime.now().toUtc().difference(at).inDays;
    if (days <= 0) return l10n.uploadsPostedToday;
    if (days == 1) return l10n.uploadsPostedYesterday;
    if (days < 7) return l10n.uploadsPostedDaysAgo(days);
    if (days < 30) return l10n.uploadsPostedWeeksAgo(days ~/ 7);
    return l10n.uploadsPostedMonthsAgo(days ~/ 30);
  }

  void _open(BuildContext context, AppLocalizations l10n) {
    final reel = item.reel;
    if (reel.status == 'ready' && reel.streamUrl != null) {
      context.push('/reels/view', extra: reel);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.uploadsReelNotPlayable)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reel = item.reel;
    final isReady = reel.status == 'ready';
    final statusLabel = switch (reel.status) {
      'ready' => null,
      'rejected' => l10n.uploadsStatusRejected,
      'failed' => l10n.uploadsStatusFailed,
      _ => l10n.uploadsStatusProcessing,
    };

    return GestureDetector(
      onTap: () => _open(context, l10n),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: PopupMenuButton<_CardAction>(
                      padding: EdgeInsets.zero,
                      tooltip: '',
                      onSelected: (action) {
                        if (action == _CardAction.delete) {
                          confirmAndDeleteReel(context, ref, reel);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem<_CardAction>(
                          value: _CardAction.delete,
                          child: Text(l10n.uploadsMenuDelete),
                        ),
                      ],
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (statusLabel != null)
                    Positioned(
                      top: 10,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              reel.status == 'processing' ||
                                  reel.status == 'pending_upload'
                              ? Colors.black54
                              : AppColors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        if (isReady && item.viewCount != null) ...[
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatCount(item.viewCount!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _duration(reel.durationSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        formatCount(reel.likeCount),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _postedAgo(l10n, reel.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
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
