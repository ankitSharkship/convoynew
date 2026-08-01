import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/wallet_entity.dart';
import '../utils/currency.dart';

/// A large, credit-card-shaped hero widget: same navy background as the
/// home dashboard's "Your truck is ready to earn" banner (AppColors
/// .primaryDark), the user's name styled like a cardholder name, and the
/// current reward balance as the headline number. A "Redeem to UPI" pill
/// is docked at the bottom, same as most reward-wallet apps put their
/// primary action on the card itself rather than as a separate button
/// below it.
class WalletBalanceCard extends StatelessWidget {
  final String userName;
  final WalletEntity wallet;
  final VoidCallback? onRedeemTap;

  const WalletBalanceCard({
    super.key,
    required this.userName,
    required this.wallet,
    required this.onRedeemTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reserved = double.tryParse(wallet.reservedBalance) ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppColors.primaryDark),
        child: Stack(
          children: [
            // Decorative — purely visual, gives the flat gradient some of
            // the depth a real card's foil/emboss pattern would have.
            Positioned(
              right: -30,
              top: -40,
              child: _fadedCircle(120),
            ),
            Positioned(
              right: 40,
              bottom: -50,
              child: _fadedCircle(90),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.walletBalanceCardLabel,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.card_giftcard,
                      color: AppColors.white.withValues(alpha: 0.85),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupees(wallet.availableBalance),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (reserved > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.walletPendingPayout(formatRupees(wallet.reservedBalance)),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (wallet.isFrozen) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.walletFrozenMessage,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        userName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RedeemPill(onTap: onRedeemTap, label: l10n.walletRedeemButton),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fadedCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

class _RedeemPill extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const _RedeemPill({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? AppColors.white
          : AppColors.white.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? AppColors.primaryBlueDark
                  : AppColors.primaryBlueDark.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
