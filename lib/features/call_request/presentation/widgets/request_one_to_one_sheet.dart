import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/feature_flags.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../../../wallet/presentation/state/wallet_notifier.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../../wallet/presentation/widgets/recharge_sheet.dart';
import '../../domain/call_amounts.dart';
import '../../domain/failures/call_request_exception.dart';
import '../state/call_request_notifier.dart';
import 'call_request_status_sheet.dart';

/// The "Request 1:1 Live Session" form, opened from a truck's details sheet.
/// Sends the offer, then hands over to [CallRequestStatusSheet].
class RequestOneToOneSheet extends ConsumerStatefulWidget {
  final TruckSearchResultEntity truck;

  const RequestOneToOneSheet({super.key, required this.truck});

  static Future<void> show(
    BuildContext context,
    TruckSearchResultEntity truck,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestOneToOneSheet(truck: truck),
    );
  }

  @override
  ConsumerState<RequestOneToOneSheet> createState() =>
      _RequestOneToOneSheetState();
}

class _RequestOneToOneSheetState extends ConsumerState<RequestOneToOneSheet> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _amountController = TextEditingController(text: '100');
  int _duration = 15;
  bool _submitting = false;
  bool _addingMoney = false;
  String? _error;

  /// Rupees the server said are missing (a 402 the form's own check didn't catch).
  double? _serverShortfall;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(
      () => setState(() => _serverShortfall = null),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int? get _amount => int.tryParse(_amountController.text.trim());

  /// The wallet's spendable balance, or null while it is loading / unavailable
  /// (then the server alone decides whether the offer is covered).
  double? get _spendable {
    final wallet = ref.watch(walletNotifierProvider).valueOrNull?.wallet;
    return wallet == null ? null : double.tryParse(wallet.spendableBalance);
  }

  /// Rupees the wallet is short of the current offer, or null if it covers it
  /// (or the balance isn't known yet).
  double? _shortfallFor(int amount) {
    final spendable = _spendable;
    if (spendable != null && spendable < amount) return amount - spendable;
    return _serverShortfall;
  }

  String _durationLabel(AppLocalizations l10n, int minutes) =>
      switch (minutes) {
        10 => l10n.oneToOneDurationQuick,
        15 => l10n.oneToOneDurationReview,
        _ => l10n.oneToOneDurationDeep,
      };

  String? _validateAmount(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final amount = int.tryParse((value ?? '').trim());
    if (amount == null || !isValidCallAmount(amount)) {
      return l10n.oneToOneOfferRange(
        formatRupees('$callMinAmountRupees'),
        formatRupees('$callMaxAmountRupees'),
      );
    }
    return null;
  }

  /// Real money through Razorpay: the shortfall is what should land in the
  /// wallet (the gateway fee is added on top). When the sheet closes the wallet
  /// has been refreshed if the payment went through.
  Future<void> _rechargeFor(double shortfall) async {
    await RechargeSheet.show(context, suggestedRupees: shortfall.ceil());
    if (!mounted) return;
    setState(() => _serverShortfall = null);
  }

  Future<void> _addMoney(double shortfall) async {
    // Test money only (FeatureFlags.devWalletCreditEnabled): top up to the next
    // ₹100 above what is missing.
    final credit = ((shortfall / 100).ceil() * 100).clamp(100, 10000);
    setState(() {
      _addingMoney = true;
      _error = null;
    });
    try {
      await ref.read(walletNotifierProvider.notifier).devCredit(credit);
      if (!mounted) return;
      setState(() {
        _addingMoney = false;
        _serverShortfall = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.oneToOneMoneyAdded),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _addingMoney = false;
        _error = ApiException.messageFor(e);
      });
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = _amount!;
    final shortfall = _shortfallFor(amount);
    if (shortfall != null) {
      // Not enough in the wallet: the prompt under the offer already says so.
      setState(() => _error = null);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    // Captured before the sheet closes: the status sheet opens from the root.
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    try {
      final request = await ref
          .read(callRequestComposerProvider.notifier)
          .submit(
            providerId: widget.truck.userId,
            truckRouteId: widget.truck.truckRouteId,
            topic: _topicController.text.trim(),
            durationMinutes: _duration,
            amountRupees: amount,
          );
      ref.invalidate(walletNotifierProvider); // part of the offer is frozen now
      if (!mounted) return;
      Navigator.pop(context);
      if (rootContext.mounted) {
        CallRequestStatusSheet.show(rootContext, request.id);
      }
    } on CallRequestException catch (e) {
      if (!mounted) return;
      if (e.isAlreadyOpen && e.existingRequestId != null) {
        // They already asked this driver: show that request instead.
        Navigator.pop(context);
        if (rootContext.mounted) {
          CallRequestStatusSheet.show(rootContext, e.existingRequestId!);
        }
        return;
      }
      setState(() {
        _submitting = false;
        if (e.isInsufficientBalance) {
          _serverShortfall = double.tryParse(e.shortfall ?? '');
        } else {
          _error = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = ApiException.messageFor(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = widget.truck.userName.trim().isEmpty
        ? l10n.oneToOneDriverFallback
        : widget.truck.userName;
    final amount = _amount;
    final amountOk = amount != null && isValidCallAmount(amount);
    final shortfall = amount == null ? null : _shortfallFor(amount);
    final spendable = _spendable;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // Lifts the sheet (and its Send button) above the keyboard.
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The fields scroll; the Send button below stays on screen.
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    l10n.oneToOneSheetTitle,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.oneToOneSheetBadge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.chipBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.oneToOneSheetSubtitle(name),
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.greenLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.videocam,
                                  size: 20,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.oneToOneHowTitle,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.oneToOneHowBody,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: SheetLabel(l10n.oneToOneTopicLabel),
                            ),
                            Text(
                              l10n.oneToOneRequiredTag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _topicController,
                          decoration: sheetFieldDecoration(
                            l10n.oneToOneTopicHint,
                          ),
                          minLines: 2,
                          maxLines: 3,
                          maxLength: 255,
                          buildCounter:
                              (
                                _, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) => null,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? l10n.oneToOneTopicRequired
                              : null,
                        ),
                        const SizedBox(height: 18),
                        SheetLabel(l10n.oneToOneDurationLabel),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final minutes
                                in callDurationOptionsMinutes) ...[
                              if (minutes != callDurationOptionsMinutes.first)
                                const SizedBox(width: 8),
                              Expanded(
                                child: _ChoiceTile(
                                  selected: _duration == minutes,
                                  title: l10n.oneToOneDurationMinutes(minutes),
                                  subtitle: _durationLabel(l10n, minutes),
                                  onTap: () =>
                                      setState(() => _duration = minutes),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),
                        SheetLabel(l10n.oneToOneOfferLabel),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: sheetFieldDecoration(
                            l10n.oneToOneOfferHint,
                          ).copyWith(prefixText: '₹ '),
                          validator: _validateAmount,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final quick in callQuickAmountsRupees) ...[
                              if (quick != callQuickAmountsRupees.first)
                                const SizedBox(width: 8),
                              Expanded(
                                child: _ChoiceTile(
                                  selected: amount == quick,
                                  title: '₹$quick',
                                  compact: true,
                                  onTap: () =>
                                      _amountController.text = '$quick',
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (amountOk) ...[
                          const SizedBox(height: 10),
                          Text(
                            l10n.oneToOneHoldExplainer(
                              formatRupees(callHoldAmountText(amount)),
                              formatRupees('$amount'),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (spendable != null)
                          Text(
                            l10n.oneToOneWalletAvailable(
                              formatRupees(spendable.toStringAsFixed(2)),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (shortfall != null && amountOk) ...[
                          const SizedBox(height: 8),
                          _NeedMoneyNotice(
                            message: l10n.oneToOneNeedMoney(
                              formatRupees(shortfall.toStringAsFixed(2)),
                            ),
                            onAddMoney: FeatureFlags.rechargeEnabled
                                ? () => _rechargeFor(shortfall)
                                : FeatureFlags.devWalletCreditEnabled
                                ? () => _addMoney(shortfall)
                                : null,
                            adding: _addingMoney,
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: ElevatedButton(
                    onPressed: _submitting || _addingMoney ? null : _send,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(l10n.oneToOneSendButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String? subtitle;
  final bool compact;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryBlue.withValues(alpha: 0.10)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Add ₹X to your wallet to send this request", with an Add money button only
/// where test money is allowed (the real recharge arrives with Razorpay).
class _NeedMoneyNotice extends StatelessWidget {
  final String message;
  final VoidCallback? onAddMoney;
  final bool adding;

  const _NeedMoneyNotice({
    required this.message,
    required this.onAddMoney,
    required this.adding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 8),
          if (onAddMoney != null)
            OutlinedButton(
              onPressed: adding ? null : onAddMoney,
              child: adding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.oneToOneAddMoneyButton),
            )
          else
            Text(
              l10n.oneToOneRechargeSoon,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
