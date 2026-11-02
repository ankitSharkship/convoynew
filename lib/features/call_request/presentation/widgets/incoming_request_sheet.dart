import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../domain/failures/call_request_exception.dart';
import '../call/call_routes.dart';
import '../call/call_screen_registry.dart';
import '../state/call_request_notifier.dart';
import 'call_request_countdown.dart';

/// The driver's side of one 1:1 request: who wants a call, about what, what the
/// driver earns, and Accept / Reject. Opened from the Home banner or from a
/// tapped push. Once accepted it offers "Start call", after a reminder not to
/// use the phone while driving.
class IncomingRequestSheet extends ConsumerWidget {
  final String requestId;

  const IncomingRequestSheet({super.key, required this.requestId});

  static Future<void> show(BuildContext context, String requestId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IncomingRequestSheet(requestId: requestId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(callRequestNotifierProvider(requestId));

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
              state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Column(
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
                      ApiException.messageFor(error),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(
                        callRequestNotifierProvider(requestId),
                      ),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
                data: (request) =>
                    _IncomingBody(request: request, requestId: requestId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingBody extends ConsumerStatefulWidget {
  final CallRequestEntity request;
  final String requestId;

  const _IncomingBody({required this.request, required this.requestId});

  @override
  ConsumerState<_IncomingBody> createState() => _IncomingBodyState();
}

class _IncomingBodyState extends ConsumerState<_IncomingBody> {
  bool _busy = false;
  bool _starting = false; // a second tap on Start while the reminder is up
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      // e.g. the requester cancelled, or the request ran out, while this sheet
      // was open: say so, and show what the request is now.
      setState(
        () => _error = e is CallRequestException
            ? e.message
            : ApiException.messageFor(e),
      );
      ref.invalidate(callRequestNotifierProvider(widget.requestId));
      ref.invalidate(incomingCallRequestsNotifierProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept() => _run(
    () => ref
        .read(callRequestNotifierProvider(widget.requestId).notifier)
        .accept(),
  );

  Future<void> _reject(String name) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.oneToOneRejectConfirmTitle),
        content: Text(l10n.oneToOneRejectConfirmBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.oneToOneKeepButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(l10n.oneToOneRejectButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => ref
          .read(callRequestNotifierProvider(widget.requestId).notifier)
          .reject(),
    );
  }

  /// "Don't use the phone while driving", then the call screen. The reminder
  /// comes first so nobody is rung for a call the driver can't safely take.
  Future<void> _start() async {
    if (_starting) return;
    // This call is already open on this phone: don't open it a second time.
    if (ref.read(callScreenRegistryProvider).liveOpen(widget.request.id)) return;
    _starting = true;
    try {
      await _confirmAndStart();
    } finally {
      _starting = false;
    }
  }

  Future<void> _confirmAndStart() async {
    final l10n = AppLocalizations.of(context)!;
    final parked = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.local_parking, color: AppColors.primaryBlue),
        title: Text(l10n.callSafetyTitle),
        content: Text(l10n.callSafetyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.callCancelRingButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.callSafetyOk),
          ),
        ],
      ),
    );
    if (parked != true || !mounted) return;
    final router = GoRouter.of(context);
    Navigator.of(context).pop(); // close this sheet
    router.push(
      CallRoutes.call(widget.request.id, mode: 'start', driver: true),
    );
  }

  String _statusText(AppLocalizations l10n, CallRequestEntity r, String name) =>
      switch (r.status) {
        CallStatus.accepted => l10n.oneToOneIncomingAccepted(name),
        CallStatus.ringing || CallStatus.live => l10n.oneToOneStatusLive(name),
        CallStatus.awaitingFeedback => l10n.oneToOneIncomingFeedback(name),
        CallStatus.completed => l10n.oneToOneIncomingCompleted(
          formatRupees(r.settledAmount ?? r.holdAmount),
        ),
        CallStatus.rejected => l10n.oneToOneIncomingRejected,
        CallStatus.expired => l10n.oneToOneIncomingExpired,
        CallStatus.cancelled => l10n.oneToOneIncomingCancelled(name),
        _ => l10n.oneToOneStatusFailed,
      };

  (IconData, Color) _look(String status) => switch (status) {
    CallStatus.accepted ||
    CallStatus.ringing ||
    CallStatus.live ||
    CallStatus.awaitingFeedback ||
    CallStatus.completed => (Icons.check_circle, AppColors.green),
    _ => (Icons.info_outline, AppColors.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = widget.request;
    final name = (r.requester.name ?? '').trim().isEmpty
        ? l10n.oneToOneRequesterFallback
        : r.requester.name!;
    final isPending = r.status == CallStatus.pending;
    final showsEarnings = isPending || r.status == CallStatus.accepted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.oneToOneIncomingTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.oneToOneIncomingFrom(name),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
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
                l10n.oneToOneIncomingTopicLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r.topic,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.oneToOneOfferSummary(
                  formatRupees(r.amount),
                  r.durationMinutes,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 6),
                CallRequestCountdown(expiresAt: r.expiresAt),
              ],
            ],
          ),
        ),
        if (showsEarnings) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.oneToOneEarningsTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.oneToOneEarningsBody(
                    formatRupees(r.holdAmount),
                    formatRupees(r.amount),
                    name,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!isPending) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(_look(r.status).$1, color: _look(r.status).$2, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusText(l10n, r, name),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        if (isPending) ...[
          ElevatedButton(
            onPressed: _busy ? null : _accept,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(l10n.oneToOneAcceptButton),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy ? null : () => _reject(name),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(l10n.oneToOneRejectButton),
          ),
        ] else ...[
          if (r.status == CallStatus.accepted) ...[
            Text(
              l10n.oneToOneStartCallHint(name),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.videocam),
              label: Text(l10n.oneToOneStartCallButton),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(l10n.oneToOneDoneButton),
          ),
        ],
      ],
    );
  }
}
