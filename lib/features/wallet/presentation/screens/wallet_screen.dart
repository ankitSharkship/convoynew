import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../../../scratch_cards/domain/entities/scratch_card_entity.dart';
import '../../../scratch_cards/presentation/state/scratch_cards_notifier.dart';
import '../../../scratch_cards/presentation/widgets/scratch_card_grid_tile.dart';
import '../../domain/entities/wallet_entity.dart';
import '../state/wallet_notifier.dart';
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
                      loading: () => const AppLoader(),
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
      loading: () => const AppLoader(),
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
