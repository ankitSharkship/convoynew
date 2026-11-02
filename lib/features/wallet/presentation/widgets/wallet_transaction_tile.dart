import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/wallet_entity.dart';
import '../utils/currency.dart';

class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionEntity transaction;

  const WalletTransactionTile({super.key, required this.transaction});

  String _label(AppLocalizations l10n, String type) => switch (type) {
    'credit' => l10n.walletTxnCredit,
    'reserve_redeem' => l10n.walletTxnReserveRedeem,
    'confirm_payout' => l10n.walletTxnConfirmPayout,
    'release_reserve' => l10n.walletTxnReleaseReserve,
    'call_hold' => l10n.walletTxnCallHold,
    'call_release' => l10n.walletTxnCallRelease,
    'call_debit' => l10n.walletTxnCallDebit,
    'call_earning' => l10n.walletTxnCallEarning,
    _ => type,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.green : AppColors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(l10n, transaction.type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'dd MMM, hh:mm a',
                  ).format(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${formatRupees(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
