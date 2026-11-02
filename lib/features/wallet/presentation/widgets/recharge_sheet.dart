import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/recharge_entities.dart';
import '../state/recharge_controller.dart';
import '../utils/currency.dart';

/// "1,000.00" style rupee text for an amount in paise.
String rupeesOfPaise(int paise) =>
    formatRupees('${paise ~/ 100}.${(paise % 100).toString().padLeft(2, '0')}');

/// Adds money to the wallet: the person types what they want IN the wallet, sees
/// the gateway fee added on top and what they will pay, and pays in Razorpay's
/// checkout. [suggestedRupees] pre-fills the amount (e.g. the shortfall that
/// stopped a 1:1 request).
class RechargeSheet extends ConsumerStatefulWidget {
  final int? suggestedRupees;

  const RechargeSheet({super.key, this.suggestedRupees});

  static Future<void> show(BuildContext context, {int? suggestedRupees}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RechargeSheet(suggestedRupees: suggestedRupees),
    );
  }

  @override
  ConsumerState<RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends ConsumerState<RechargeSheet> {
  static const _quickAmounts = [100, 250, 500, 1000];
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    final suggested = widget.suggestedRupees;
    _amount = TextEditingController(text: suggested?.toString() ?? '');
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int? get _rupees => int.tryParse(_amount.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(rechargeConfigProvider);
    final flow = ref.watch(rechargeControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.rechargeTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                config.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => _Message(
                    text: l10n.rechargeUnavailable,
                    actionLabel: l10n.tryAgain,
                    onAction: () => ref.invalidate(rechargeConfigProvider),
                  ),
                  data: (c) => !c.enabled
                      ? _Message(text: l10n.rechargeUnavailable)
                      : _body(context, l10n, c, flow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    RechargeConfig config,
    RechargeState flow,
  ) {
    switch (flow.phase) {
      case RechargePhase.creating:
        return _Progress(text: l10n.rechargeCreating);
      case RechargePhase.paying:
        return _Progress(text: l10n.rechargePaying);
      case RechargePhase.confirming:
        return _Progress(text: l10n.rechargeConfirming);
      case RechargePhase.done:
        return _Result(
          icon: Icons.check_circle,
          color: AppColors.green,
          text: l10n.rechargeDone(formatRupees(flow.order!.creditAmount)),
          buttonLabel: l10n.callDoneButton,
          onButton: () => Navigator.of(context).maybePop(),
        );
      case RechargePhase.pending:
        return _Result(
          icon: Icons.hourglass_top,
          color: AppColors.primaryBlue,
          text: flow.message ?? l10n.rechargePending,
          buttonLabel: l10n.rechargeClose,
          onButton: () => Navigator.of(context).maybePop(),
        );
      case RechargePhase.failed:
      case RechargePhase.idle:
        return _form(context, l10n, config, flow);
    }
  }

  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    RechargeConfig config,
    RechargeState flow,
  ) {
    final rupees = _rupees;
    final valid = rupees != null && config.allows(rupees);
    final quote = valid ? config.quote(rupees) : null;
    final min = config.minRupees.toString();
    final max = config.maxRupees.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _amount,
          autofocus: widget.suggestedRupees == null,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: l10n.rechargeAmountLabel,
            helperText: l10n.rechargeRange(min, max),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amount in _quickAmounts.where(config.allows))
              ActionChip(
                label: Text('₹$amount'),
                onPressed: () => _amount.text = amount.toString(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (quote != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _Row(
                  l10n.rechargeAddedToWallet,
                  rupeesOfPaise(quote.creditPaise),
                ),
                const SizedBox(height: 6),
                _Row(
                  l10n.rechargeGatewayFee,
                  rupeesOfPaise(quote.feePaise),
                  muted: true,
                ),
                const Divider(height: 18),
                _Row(
                  l10n.rechargeYouPay,
                  rupeesOfPaise(quote.totalPaise),
                  bold: true,
                ),
              ],
            ),
          )
        else if (rupees != null)
          Text(
            l10n.rechargeInvalidAmount(min, max),
            style: const TextStyle(fontSize: 12, color: AppColors.red),
          ),
        if (flow.phase == RechargePhase.failed) ...[
          const SizedBox(height: 12),
          Text(
            flow.message ?? l10n.rechargeFailedGeneric,
            style: const TextStyle(fontSize: 12, color: AppColors.red),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: quote == null
              ? null
              : () => ref
                    .read(rechargeControllerProvider.notifier)
                    .start(rupees!),
          child: Text(
            quote == null
                ? l10n.oneToOneAddMoneyButton
                : l10n.rechargePayButton(rupeesOfPaise(quote.totalPaise)),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool muted;

  const _Row(this.label, this.value, {this.bold = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      color: muted ? AppColors.textSecondary : AppColors.textPrimary,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  final String text;

  const _Progress({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String buttonLabel;
  final VoidCallback onButton;

  const _Result({
    required this.icon,
    required this.color,
    required this.text,
    required this.buttonLabel,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Icon(icon, color: color, size: 44),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: onButton, child: Text(buttonLabel)),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
