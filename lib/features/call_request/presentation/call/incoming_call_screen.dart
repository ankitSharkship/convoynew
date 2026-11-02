import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../incoming_call/incoming_call_controller.dart';
import '../state/call_providers.dart';
import '../state/outgoing_requests_notifier.dart';
import 'call_formatting.dart';
import 'call_routes.dart';
import 'call_screen_registry.dart';
import 'call_session_controller.dart';

/// "{driver} is calling you": the requester's ring screen. Answer joins the call
/// (microphone only); Decline cancels the request and releases the money. The
/// ring has a deadline from the server: after it (or if the driver hangs up
/// first) the screen says the call was missed.
class IncomingCallScreen extends ConsumerStatefulWidget {
  final CallRequestEntity request;

  const IncomingCallScreen({super.key, required this.request});

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  Timer? _timer;
  bool _declining = false;
  bool _declineFailed = false;
  late final CallScreenRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(callScreenRegistryProvider)
      ..enter(widget.request.id, live: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _registry.leave(widget.request.id, live: false);
    super.dispose();
  }

  /// The latest known state of this request: from the requester's open
  /// requests, which are refreshed every few seconds while a ring is likely.
  CallRequestEntity get _latest {
    final list = ref.watch(outgoingActiveRequestsProvider).valueOrNull;
    if (list == null) return widget.request;
    for (final r in list) {
      if (r.id == widget.request.id) return r;
    }
    // No longer open: the driver hung up (it is back to "accepted" only while
    // still open, so absence means cancelled / expired).
    return widget.request.copyWithStatus(CallStatus.cancelled);
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _decline() async {
    if (_declining) return;
    setState(() {
      _declining = true;
      _declineFailed = false;
    });
    final done = await ref
        .read(callSessionProvider(widget.request.id).notifier)
        .decline();
    if (!mounted) return;
    if (done) {
      ref.invalidate(outgoingActiveRequestsProvider);
      unawaited(ref.read(incomingCallUiProvider).end(widget.request.id));
      _leave();
    } else {
      // Not told to the server: stay, say so, and let them try again.
      setState(() {
        _declining = false;
        _declineFailed = true;
      });
    }
  }

  void _answer() {
    // Answered here, so a system call notification for the same ring (Android
    // shows one when a push arrives while the app is closed) must stop ringing.
    unawaited(ref.read(incomingCallUiProvider).end(widget.request.id));
    context.pushReplacement(
      CallRoutes.call(widget.request.id, mode: 'answer', driver: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The phone's own call screen has taken over this ring (it came up a moment
    // after ours): don't show two.
    ref.listen(callKitShownProvider, (_, shown) {
      if (shown.contains(widget.request.id) && mounted && !_declining) _leave();
    });
    // Keeps the call session alive while this screen is up, so declining can
    // finish its server call even though nothing else is watching it.
    ref.watch(callSessionProvider(widget.request.id));

    final r = _latest;
    final now = ref.read(callClockProvider)();
    final ends = r.ringEndsAt ?? widget.request.ringEndsAt;
    final secondsLeft = ends == null ? 0 : ends.difference(now).inSeconds;
    final stillRinging =
        r.status == CallStatus.ringing && ends != null && secondsLeft > 0;
    final name = partyName(r.provider, l10n.oneToOneRequesterFallback);

    return PopScope(
      canPop: !stillRinging,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryDarkLight,
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.callIncomingTitle(name),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r.topic,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.callIncomingOffer(
                    formatRupees(r.amount),
                    r.durationMinutes,
                  ),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                if (stillRinging)
                  Text(
                    l10n.callRingSeconds(secondsLeft),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  )
                else if (r.onAnotherDevice)
                  Text(
                    l10n.callAnsweredElsewhere,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    l10n.callMissed(name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                const Spacer(),
                if (stillRinging) ...[
                  Text(
                    l10n.callIncomingHint(name),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RingButton(
                        icon: Icons.call_end,
                        label: l10n.callDecline,
                        color: AppColors.red,
                        onTap: _declining ? null : _decline,
                      ),
                      _RingButton(
                        icon: Icons.call,
                        label: l10n.callAnswer,
                        color: AppColors.green,
                        onTap: _declining ? null : _answer,
                      ),
                    ],
                  ),
                  if (_declineFailed) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.callDeclineFailed,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    l10n.callDeclineHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                  ),
                ] else
                  OutlinedButton(
                    onPressed: _leave,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                    ),
                    child: Text(l10n.callClose),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _RingButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: onTap == null ? color.withValues(alpha: 0.4) : color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
