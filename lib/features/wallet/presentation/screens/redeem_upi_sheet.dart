import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../state/wallet_notifier.dart';
import '../utils/currency.dart';

Future<void> showRedeemUpiSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const RedeemUpiSheet(),
  );
}

class RedeemUpiSheet extends ConsumerStatefulWidget {
  const RedeemUpiSheet({super.key});

  @override
  ConsumerState<RedeemUpiSheet> createState() => _RedeemUpiSheetState();
}

class _RedeemUpiSheetState extends ConsumerState<RedeemUpiSheet> {
  final _upiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  // Loose client-side check only — the backend is the source of truth on
  // validity, this just avoids an obviously-wrong round trip.
  String? _validateUpi(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) return l10n.walletUpiIdRequired;
    final pattern = RegExp(r'^[\w.\-]{2,64}@[a-zA-Z]{2,64}$');
    if (!pattern.hasMatch(value.trim())) return l10n.walletUpiIdInvalid;
    return null;
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(walletNotifierProvider.notifier)
          .redeem(_upiController.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.walletRedeemSuccessMessage)),
      );
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
    final available =
        ref.watch(walletNotifierProvider).valueOrNull?.wallet.availableBalance ??
        '0.00';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  l10n.walletRedeemSheetTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.walletRedeemAvailableLabel(formatRupees(available)),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SheetLabel(l10n.walletUpiIdLabel),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _upiController,
                  decoration: sheetFieldDecoration(l10n.walletUpiIdHint),
                  validator: _validateUpi,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _confirm,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(l10n.walletConfirmRedeemButton),
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
