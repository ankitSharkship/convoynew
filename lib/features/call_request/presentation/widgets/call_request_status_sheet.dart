import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/state/wallet_notifier.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../domain/failures/call_request_exception.dart';
import '../state/call_request_notifier.dart';
import 'call_request_countdown.dart';

/// Follows one of the user's own 1:1 requests: waiting for the driver, accepted,
/// and how it ended. Refreshes itself while the request is still going. The call
/// screens themselves (ringing, live, "were you satisfied?") come in a later
/// stage; until then those states are shown as plain text.
class CallRequestStatusSheet extends ConsumerWidget {
  final String requestId;

  const CallRequestStatusSheet({super.key, required this.requestId});

  static Future<void> show(BuildContext context, String requestId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CallRequestStatusSheet(requestId: requestId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(callRequestNotifierProvider(requestId));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
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
                l10n.oneToOneStatusTitle,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _LoadError(
                  message: ApiException.messageFor(error),
                  onRetry: () =>
                      ref.invalidate(callRequestNotifierProvider(requestId)),
                ),
                data: (request) =>
                    _RequestBody(request: request, requestId: requestId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.oneToOneStatusLoadError,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
      ],
    );
  }
}

class _RequestBody extends ConsumerStatefulWidget {
  final CallRequestEntity request;
  final String requestId;

  const _RequestBody({required this.request, required this.requestId});

  @override
  ConsumerState<_RequestBody> createState() => _RequestBodyState();
}

class _RequestBodyState extends ConsumerState<_RequestBody> {
  bool _cancelling = false;

  @override
  void didUpdateWidget(covariant _RequestBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The frozen part of an offer came back (or was paid): refresh the wallet.
    if (oldWidget.request.status != widget.request.status) {
      ref.invalidate(walletNotifierProvider);
    }
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref
          .read(callRequestNotifierProvider(widget.requestId).notifier)
          .cancel();
      ref.invalidate(walletNotifierProvider);
    } catch (e) {
      if (!mounted) return;
      final message = e is CallRequestException
          ? e.message
          : ApiException.messageFor(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  String _statusText(AppLocalizations l10n, CallRequestEntity r, String name) =>
      switch (r.status) {
        CallStatus.pending => l10n.oneToOneStatusPending(name),
        CallStatus.accepted => l10n.oneToOneStatusAccepted(name),
        CallStatus.ringing => l10n.oneToOneStatusRinging(name),
        CallStatus.live => l10n.oneToOneStatusLive(name),
        CallStatus.awaitingFeedback => l10n.oneToOneStatusAwaitingFeedback,
        CallStatus.completed => l10n.oneToOneStatusCompleted(
          formatRupees(r.settledAmount ?? r.holdAmount),
        ),
        CallStatus.rejected => l10n.oneToOneStatusRejected(name),
        CallStatus.expired => l10n.oneToOneStatusExpired,
        CallStatus.cancelled => l10n.oneToOneStatusCancelled,
        _ => l10n.oneToOneStatusFailed,
      };

  (IconData, Color) _look(String status) => switch (status) {
    CallStatus.accepted ||
    CallStatus.ringing ||
    CallStatus.live => (Icons.call, AppColors.green),
    CallStatus.completed ||
    CallStatus.awaitingFeedback => (Icons.check_circle, AppColors.green),
    CallStatus.rejected ||
    CallStatus.expired ||
    CallStatus.cancelled ||
    CallStatus.failed => (Icons.call_end, AppColors.red),
    _ => (Icons.hourglass_top, AppColors.primaryBlue),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = widget.request;
    final name = (r.otherParty.name ?? '').trim().isEmpty
        ? l10n.oneToOneDriverFallback
        : r.otherParty.name!;
    final (icon, color) = _look(r.status);
    final holding = r.isInProgress || r.status == CallStatus.awaitingFeedback;
    final waiting =
        r.status == CallStatus.pending || r.status == CallStatus.accepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _statusText(l10n, r, name),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.topic,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.oneToOneOfferSummary(
                  formatRupees(r.amount),
                  r.durationMinutes,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (holding) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.oneToOneFrozenSummary(formatRupees(r.holdAmount)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              if (waiting) ...[
                const SizedBox(height: 8),
                CallRequestCountdown(expiresAt: r.expiresAt),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (r.canCancel)
          OutlinedButton(
            onPressed: _cancelling ? null : _cancel,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
            child: _cancelling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.oneToOneCancelButton),
          )
        else
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(l10n.oneToOneDoneButton),
          ),
      ],
    );
  }
}
