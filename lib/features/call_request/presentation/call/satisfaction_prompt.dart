import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/state/wallet_notifier.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../domain/failures/call_request_exception.dart';
import '../state/call_providers.dart';
import '../state/outgoing_requests_notifier.dart';
import 'call_formatting.dart';

/// "Were you satisfied with the call?" The requester's answer decides what the
/// driver is paid: yes pays the full offer, no pays only the call amount.
/// Shown right after a call that counted, and again (from the app's start) if
/// it was put off. [onLater] is the "Decide later" choice, [onDone] closes the
/// prompt after the answer was saved.
class SatisfactionPrompt extends ConsumerStatefulWidget {
  final CallRequestEntity request;
  final VoidCallback onLater;
  final VoidCallback onDone;

  const SatisfactionPrompt({
    super.key,
    required this.request,
    required this.onLater,
    required this.onDone,
  });

  @override
  ConsumerState<SatisfactionPrompt> createState() => _SatisfactionPromptState();
}

class _SatisfactionPromptState extends ConsumerState<SatisfactionPrompt> {
  bool _busy = false;
  String? _error;
  CallRequestEntity? _paid;

  Future<void> _answer(bool satisfied) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(callRepositoryProvider)
          .submitFeedback(widget.request.id, satisfied);
      ref.invalidate(walletNotifierProvider);
      ref.invalidate(outgoingActiveRequestsProvider);
      if (mounted) setState(() => _paid = updated);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e is CallRequestException
            ? e.message
            : ApiException.messageFor(e),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = widget.request;
    final name = partyName(r.provider, l10n.oneToOneRequesterFallback);
    final paid = _paid;

    if (paid != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.check_circle, color: AppColors.green, size: 40),
          const SizedBox(height: 10),
          Text(
            l10n.callFeedbackThanks(
              formatRupees(paid.settledAmount ?? r.holdAmount),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onDone,
            child: Text(l10n.callDoneButton),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.callFeedbackTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.callFeedbackBody(name),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _busy ? null : () => _answer(true),
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(l10n.callFeedbackYes(formatRupees(r.amount))),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _busy ? null : () => _answer(false),
          child: Text(l10n.callFeedbackNo(formatRupees(r.holdAmount))),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.callFeedbackNoNote(formatRupees(r.holdAmount)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : widget.onLater,
          child: Text(l10n.callFeedbackLater),
        ),
        Text(
          l10n.callFeedbackLaterNote(formatRupees(r.holdAmount)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
