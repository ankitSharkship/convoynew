import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/feature_flags.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../../../scratch_cards/domain/entities/scratch_card_entity.dart';
import '../../../scratch_cards/presentation/state/scratch_cards_notifier.dart';
import '../../../scratch_cards/presentation/widgets/scratch_card_grid_tile.dart';
import '../../domain/entities/wallet_entity.dart';
import '../state/wallet_notifier.dart';
import '../widgets/recharge_sheet.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_transaction_tile.dart';
import 'redeem_upi_sheet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletNotifierProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final userName = profileAsync.valueOrNull?.name ?? '';
    final kycStatus = profileAsync.valueOrNull?.kycStatus;
    // Only gate once the profile fetch has actually confirmed the status
    // isn't approved — never block on a still-loading or errored profile,
    // since by the time this screen is reachable at all the profile is
    // almost always already cached from login.
    final showKycGate =
        profileAsync.hasValue &&
        kycStatus != 'approved' &&
        kycStatus != 'verified';

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: SafeArea(
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: showKycGate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.walletTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const LanguageSwitcherButton(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: walletAsync.when(
                      loading: () => const _WalletSkeleton(),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
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
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () => ref
                                    .read(walletNotifierProvider.notifier)
                                    .refresh(),
                                child: Text(l10n.tryAgain),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (data) => DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: WalletBalanceCard(
                                userName: userName,
                                wallet: data.wallet,
                                onRedeemTap:
                                    data.wallet.isFrozen ||
                                        (double.tryParse(
                                                  data.wallet.availableBalance,
                                                ) ??
                                                0) <=
                                            0
                                    ? null
                                    : () => showRedeemUpiSheet(context),
                                onAddMoneyTap:
                                    FeatureFlags.rechargeEnabled &&
                                        !data.wallet.isFrozen
                                    ? () => RechargeSheet.show(context)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TabBar(
                              labelColor: AppColors.primaryBlue,
                              unselectedLabelColor: AppColors.textTertiary,
                              indicatorColor: AppColors.primaryBlue,
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              tabs: [
                                Tab(text: l10n.walletScratchCardsTab),
                                Tab(text: l10n.walletTransactionsTab),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _ScratchCardsTab(),
                                  _TransactionsTab(
                                    transactions: data.transactions,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showKycGate) const _KycGateOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Blocks the whole wallet page behind a blur while KYC isn't approved —
/// the backend only creates/returns a wallet for approved users at all, so
/// this also avoids letting the page underneath even attempt (and fail) a
/// wallet fetch for nothing the user could act on anyway.
class _KycGateOverlay extends ConsumerWidget {
  const _KycGateOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: AppColors.primaryDark.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryDark,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.walletKycRequiredMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => navigateToKycVerification(
                    context,
                    ref,
                    onAlreadyVerified: () =>
                        ref.invalidate(profileNotifierProvider),
                  ),
                  child: Text(l10n.walletKycCompleteButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScratchCardsTab extends ConsumerWidget {
  const _ScratchCardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cardsAsync = ref.watch(scratchCardsNotifierProvider);

    return cardsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: _ScratchCardGridSkeleton(),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ApiException.messageFor(e),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(scratchCardsNotifierProvider.notifier).refresh(),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
      data: (cards) {
        final remaining = cards
            .where((c) => c.status == ScratchCardStatus.unscratched)
            .toList();
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(scratchCardsNotifierProvider.notifier).refresh(),
          child: remaining.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                  children: [
                    Center(
                      child: Text(
                        l10n.walletScratchCardsEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                )
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: remaining.length,
                  itemBuilder: (context, i) =>
                      ScratchCardGridTile(card: remaining[i]),
                ),
        );
      },
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  final List<WalletTransactionEntity> transactions;

  const _TransactionsTab({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: () => ref.read(walletNotifierProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          if (transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  l10n.walletNoTransactions,
                  style: const TextStyle(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < transactions.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 70,
                        color: AppColors.divider,
                      ),
                    WalletTransactionTile(transaction: transactions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Skeleton loader ─────────────────────────────────────────────────────────

/// Mirrors the loaded wallet page's layout (balance card, tab row, scratch
/// card grid) instead of a bare spinner, so the page doesn't visibly jump
/// in shape once real data arrives.
class _WalletSkeleton extends StatefulWidget {
  const _WalletSkeleton();

  @override
  State<_WalletSkeleton> createState() => _WalletSkeletonState();
}

class _WalletSkeletonState extends State<_WalletSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Pulses the balance card + tab row directly — the grid below
        // pulses on its own timer (it's reused standalone by
        // _ScratchCardsTab), and nesting two out-of-phase pulses would
        // just look flickery rather than smoothly synced.
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Opacity(
            opacity: 0.4 + (_pulseController.value * 0.4),
            child: child,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BalanceCardSkeleton(),
              const SizedBox(height: 20),
              Row(
                children: [
                  _SkeletonBox(width: 90, height: 16),
                  const SizedBox(width: 24),
                  _SkeletonBox(width: 80, height: 16),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _ScratchCardGridSkeleton(),
      ],
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppColors.primaryDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DarkSkeletonBox(width: 150, height: 12),
                const Spacer(),
                _DarkSkeletonBox(width: 22, height: 22, radius: 11),
              ],
            ),
            const SizedBox(height: 12),
            _DarkSkeletonBox(width: 140, height: 30),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _DarkSkeletonBox(width: double.infinity, height: 14),
                ),
                const SizedBox(width: 12),
                _DarkSkeletonBox(width: 90, height: 34, radius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Self-pulsing so it looks right whether it's embedded in [_WalletSkeleton]
/// or shown standalone by [_ScratchCardsTab] while its own data is still
/// loading.
class _ScratchCardGridSkeleton extends StatefulWidget {
  const _ScratchCardGridSkeleton();

  @override
  State<_ScratchCardGridSkeleton> createState() =>
      _ScratchCardGridSkeletonState();
}

class _ScratchCardGridSkeletonState extends State<_ScratchCardGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) =>
          Opacity(opacity: 0.4 + (_pulseController.value * 0.4), child: child),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
        children: List.generate(
          4,
          (_) => const _SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            radius: 20,
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Same as [_SkeletonBox] but tinted for the dark balance-card background —
/// a light-grey block would barely be visible against navy.
class _DarkSkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _DarkSkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
