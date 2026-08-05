import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/wheel_number_picker.dart';
import '../../../contacts/presentation/state/contacts_sync_notifier.dart';
import '../../../contacts/presentation/widgets/mutual_contacts_sheet.dart';
import '../../domain/entities/truck_search_result_entity.dart';
import '../state/search_notifier.dart';

String _maskVehicleNumber(String number) {
  final buffer = StringBuffer();
  for (var i = 0; i < number.length; i++) {
    buffer.write(i.isEven ? number[i] : '*');
  }
  return buffer.toString();
}

Future<void> _callNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  final launched = await canLaunchUrl(uri) && await launchUrl(uri);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.resultsCallDialerError),
      ),
    );
  }
}

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    // Permission may have changed (granted or revoked) since this screen
    // was last shown — re-check rather than trusting a stale cached value.
    // Deferred to after the first frame: invalidating during initState
    // reaches for the ProviderScope container before this element has
    // finished mounting, which Flutter disallows.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(hasContactsPermissionProvider);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);
    final resultPage = state.resultPage;
    final l10n = AppLocalizations.of(context)!;

    final subtitle = state.searching
        ? l10n.resultsSearching
        : resultPage != null
        ? l10n.resultsFoundCount(resultPage.totalCount)
        : l10n.resultsYourResults;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          color: AppColors.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              resultPage != null ? 104 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(subtitle: subtitle),
                const SizedBox(height: 20),
                if (state.searching)
                  _ResultsSkeleton(pulse: _pulseController)
                else if (state.searchError != null)
                  _ErrorState(message: state.searchError!)
                else if (resultPage == null)
                  _EmptyState(message: l10n.resultsRunSearch)
                else ...[
                  _SummaryCard(state: state),
                  const SizedBox(height: 16),
                  _SortByRow(
                    sortBy: state.sortBy,
                    onChanged: notifier.setSortBy,
                  ),
                  const SizedBox(height: 16),
                  if (resultPage.posts.isEmpty)
                    _EmptyState(message: l10n.resultsNoneNearby)
                  else
                    ...resultPage.posts.map(
                      (post) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ResultCard(result: post),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: resultPage != null
          ? SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _PaginationBar(
                page: resultPage.page,
                totalPages: resultPage.totalPages,
                loading: state.searching,
                onPrevious: notifier.goToPreviousPage,
                onNext: notifier.goToNextPage,
              ),
            )
          : null,
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String subtitle;

  const _Header({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HeaderIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.resultsTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const LanguageSwitcherButton(),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryBlue),
      ),
    );
  }
}

// ─── Summary / recap card ────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final SearchState state;

  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RouteRow(
                      markerIsRing: true,
                      markerColor: AppColors.green,
                      title:
                          state.originLocation?.name ?? l10n.resultsAnyOrigin,
                      label: l10n.resultsOriginLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        width: 2,
                        height: 18,
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                      ),
                    ),
                    _RouteRow(
                      markerIsRing: false,
                      markerColor: AppColors.red,
                      title:
                          state.destinationLocation?.name ??
                          l10n.resultsAnyDestination,
                      label: l10n.resultsDestinationLabel,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F4F8)),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaColumn(
                icon: Icons.local_shipping_outlined,
                label: l10n.searchTruckTypeLabel,
                value: state.selectedTruckType != null
                    ? truckTypeLabel(context, state.selectedTruckType!)
                    : l10n.resultsAny,
              ),
              _MetaColumn(
                icon: Icons.fitness_center,
                label: l10n.searchCapacityLabel,
                value: state.selectedCapacity ?? l10n.resultsAny,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final bool markerIsRing;
  final Color markerColor;
  final String title;
  final String label;

  const _RouteRow({
    required this.markerIsRing,
    required this.markerColor,
    required this.title,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        markerIsRing
            ? Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: markerColor, width: 2.5),
                ),
              )
            : Icon(Icons.location_on, size: 20, color: markerColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Sort by row ──────────────────────────────────────────────────────────────

class _SortByRow extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onChanged;

  const _SortByRow({required this.sortBy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          l10n.resultsSortByLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  label: l10n.resultsSortNearestOrigin,
                  selected: sortBy == sortByNearestOrigin,
                  onTap: () => onChanged(sortByNearestOrigin),
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: l10n.resultsSortNearestDestination,
                  selected: sortBy == sortByNearestDestination,
                  onTap: () => onChanged(sortByNearestDestination),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Result card (person / truck) ────────────────────────────────────────────

class _ResultCard extends ConsumerWidget {
  final TruckSearchResultEntity result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // No mutuals to show, or no way to resolve them without permission
    // (e.g. the user synced once, then later revoked contacts access) —
    // either way, hide the section entirely rather than showing a count
    // that can't be backed up by anything.
    final hasContactsPermission =
        ref.watch(hasContactsPermissionProvider).valueOrNull ?? false;
    final showMutuals = result.mutualsCount > 0 && hasContactsPermission;
    final displayName = result.displayContactName;
    final initials = displayName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final destinationName =
        result.matchedDestination?.name ??
        (result.destinations.isNotEmpty ? result.destinations.first.name : '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(photoUrl: result.userPhoto, initials: initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!result.hasAlternateContact) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                    if (result.hasAlternateContact)
                      Text(
                        l10n.resultsPostedBy(result.userName),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _callNumber(context, result.displayContactNumber),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 2.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.origin,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(
                width: 2,
                height: 14,
                color: AppColors.textTertiary.withValues(alpha: 0.4),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destinationName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F8)),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaColumn(
                icon: Icons.local_shipping_outlined,
                label: l10n.searchTruckTypeLabel,
                value: truckTypeLabel(context, result.truckType),
              ),
              _MetaColumn(
                icon: Icons.numbers,
                label: l10n.searchVehicleNumberLabel,
                value: _maskVehicleNumber(result.truckNumber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaColumn(
                icon: Icons.fitness_center,
                label: l10n.searchCapacityLabel,
                value: result.capacity > 0
                    ? l10n.capacityTon(result.capacity)
                    : '—',
              ),
              if (result.length != null)
                _MetaColumn(
                  icon: Icons.straighten,
                  label: l10n.postLengthLabel,
                  value: l10n.feetValue(displayNum(result.length!)),
                ),
              if (result.height != null)
                _MetaColumn(
                  icon: Icons.height,
                  label: l10n.postHeightLabel,
                  value: l10n.feetValue(displayNum(result.height!)),
                ),
            ],
          ),
          if (showMutuals) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.resultsMutualCount(result.mutualsCount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => MutualContactsSheet.show(context, result.userId),
                  child: Text(
                    l10n.resultsViewAllMutuals,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;

  const _Avatar({required this.photoUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: photoUrl != null && photoUrl!.isNotEmpty
              ? Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _InitialsText(initials),
                )
              : _InitialsText(initials),
        ),
      ),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;

  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ─── Skeleton loader ──────────────────────────────────────────────────────────

class _ResultsSkeleton extends StatelessWidget {
  final Animation<double> pulse;

  const _ResultsSkeleton({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Opacity(opacity: 0.4 + (pulse.value * 0.4), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonSummaryCard(),
          const SizedBox(height: 20),
          _SkeletonResultCard(),
          const SizedBox(height: 12),
          _SkeletonResultCard(),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SkeletonSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 160, height: 16),
          const SizedBox(height: 16),
          const _SkeletonBox(width: 140, height: 16),
          const SizedBox(height: 20),
          Row(
            children: const [
              _SkeletonBox(width: 60, height: 28),
              SizedBox(width: 24),
              _SkeletonBox(width: 60, height: 28),
              SizedBox(width: 24),
              _SkeletonBox(width: 60, height: 28),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.chipBackground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const _SkeletonBox(width: 120, height: 16),
            ],
          ),
          const SizedBox(height: 18),
          const _SkeletonBox(width: 180, height: 12),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Pagination bar ───────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool loading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.loading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = !loading && page > 1;
    final canGoNext = !loading && page < totalPages;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PageButton(
            icon: Icons.chevron_left,
            onTap: canGoPrevious ? onPrevious : null,
          ),
          loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.resultsPageOf(page, totalPages),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
          _PageButton(
            icon: Icons.chevron_right,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PageButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.primaryBlue : AppColors.chipBackground,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ─── Error / empty states ────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
