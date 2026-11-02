import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/utils/currency.dart';
import '../../domain/entities/call_request_entity.dart';
import '../state/call_providers.dart';
import 'call_foreground_service.dart';
import 'call_formatting.dart';
import 'call_prompts.dart';
import 'call_screen_registry.dart';
import 'call_session_controller.dart';
import 'call_session_state.dart';
import 'satisfaction_prompt.dart';

/// How the call screen is entered.
enum CallEntry {
  /// The driver rings the requester.
  start,

  /// The requester picks up the ring.
  answer,

  /// Back into a call that is still on.
  rejoin;

  static CallEntry parse(String? value) => CallEntry.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CallEntry.rejoin,
  );
}

/// The live call: the driver sees their own camera and the requester's state,
/// the requester sees the driver's camera (and sends only their microphone).
/// All the logic lives in [CallSessionNotifier]; this only shows its state.
class LiveCallScreen extends ConsumerStatefulWidget {
  final String requestId;
  final CallEntry entry;

  /// Whether this phone is the driver's (decides which camera is needed when
  /// rejoining; for start/answer it follows from [entry]).
  final bool isProvider;

  const LiveCallScreen({
    super.key,
    required this.requestId,
    required this.entry,
    required this.isProvider,
  });

  @override
  ConsumerState<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends ConsumerState<LiveCallScreen>
    with WidgetsBindingObserver {
  late final CallForegroundService _service;
  late final CallScreenRegistry _registry;

  @override
  void initState() {
    super.initState();
    _service = ref.read(callForegroundServiceProvider);
    _registry = ref.read(callScreenRegistryProvider);
    _registry.enter(widget.requestId, live: true);
    WidgetsBinding.instance.addObserver(this);
    // Keep the screen awake for the whole call (best effort: never an error).
    unawaited(WakelockPlus.enable().catchError((_) {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(
        callSessionProvider(widget.requestId).notifier,
      );
      switch (widget.entry) {
        case CallEntry.start:
          controller.startAsDriver();
        case CallEntry.answer:
          controller.answerAsRequester();
        case CallEntry.rejoin:
          controller.rejoin(isProvider: widget.isProvider);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_service.stop());
    unawaited(WakelockPlus.disable().catchError((_) {}));
    _registry.leave(widget.requestId, live: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    ref
        .read(callSessionProvider(widget.requestId).notifier)
        .lifecycleChanged(lifecycle);
  }

  CallSessionNotifier get _controller =>
      ref.read(callSessionProvider(widget.requestId).notifier);

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _confirmEnd(CallSessionState state) async {
    if (!state.isActive) return;
    // Cancelling a ring needs no question; ending a call that is on does.
    if (state.phase == CallPhase.ringing) {
      await _controller.hangUp();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final name = partyName(
      state.request!.otherParty,
      l10n.oneToOneRequesterFallback,
    );
    final end = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.callEndConfirmTitle),
        content: Text(
          state.counted
              ? l10n.callEndConfirmCounted(name)
              : l10n.callEndConfirmNotCounted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.callKeepGoing),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(l10n.callEndButton),
          ),
        ],
      ),
    );
    if (end == true && mounted) await _controller.hangUp();
  }

  Future<void> _openChat() async {
    final controller = _controller;
    controller.chatVisible(true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatSheet(requestId: widget.requestId),
    );
    controller.chatVisible(false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callSessionProvider(widget.requestId));

    // While the call is on (or ringing) Android needs a "call in progress"
    // service, or it silences the microphone when the person leaves the app.
    ref.listen<CallSessionState>(callSessionProvider(widget.requestId), (
      previous,
      next,
    ) {
      final wasActive = previous?.isActive ?? false;
      if (!wasActive && next.isActive) {
        final l10n = AppLocalizations.of(context)!;
        final request = next.request!;
        unawaited(
          _service.start(
            title: l10n.callOngoingTitle,
            text: l10n.callOngoingText(
              partyName(request.otherParty, l10n.oneToOneRequesterFallback),
            ),
            withCamera: request.isProvider,
          ),
        );
      } else if (wasActive && !next.isActive) {
        unawaited(_service.stop());
      }
    });

    return PopScope(
      canPop: !state.isActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmEnd(state);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: switch (state.phase) {
          CallPhase.starting => const _StartingPanel(),
          CallPhase.failed => _FailedPanel(
            failure: state.failure!,
            onClose: _leave,
            onSettings: () => ref.read(callPermissionsProvider).openSettings(),
          ),
          CallPhase.ended => _EndedPanel(
            state: state,
            onDone: _leave,
            onLater: () {
              // "Decide later" is respected: the coordinator must not put the
              // same question straight back on screen.
              ref
                  .read(handledCallPromptsProvider)
                  .add(CallPromptKeys.feedback(widget.requestId));
              _leave();
            },
          ),
          _ => _LiveView(
            requestId: widget.requestId,
            state: state,
            onEnd: () => _confirmEnd(state),
            onChat: _openChat,
          ),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _StartingPanel extends StatelessWidget {
  const _StartingPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.white),
          const SizedBox(height: 16),
          Text(
            l10n.callStarting,
            style: const TextStyle(color: AppColors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _FailedPanel extends StatelessWidget {
  final CallFailure failure;
  final VoidCallback onClose;
  final VoidCallback onSettings;

  const _FailedPanel({
    required this.failure,
    required this.onClose,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (failure.kind) {
      CallFailureKind.microphoneDenied ||
      CallFailureKind.microphoneBlocked => l10n.callPermissionMic,
      CallFailureKind.cameraDenied ||
      CallFailureKind.cameraBlocked => l10n.callPermissionCamera,
      CallFailureKind.onAnotherDevice => l10n.callOnAnotherDevice,
      _ => failure.message,
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              failure.isPermission ? Icons.mic_off : Icons.error_outline,
              color: AppColors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (failure.needsSettings) ...[
              ElevatedButton(
                onPressed: onSettings,
                child: Text(l10n.callOpenSettings),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton(
              onPressed: onClose,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white),
              ),
              child: Text(l10n.callClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndedPanel extends StatelessWidget {
  final CallSessionState state;
  final VoidCallback onDone;
  final VoidCallback onLater;

  const _EndedPanel({
    required this.state,
    required this.onDone,
    required this.onLater,
  });

  bool get isRequester =>
      (state.endedRequest ?? state.request)?.isRequester ?? false;

  String _message(
    AppLocalizations l10n,
    CallRequestEntity? r,
    String name,
    int connected,
  ) {
    if (state.endUnconfirmed) return l10n.callEndedUnconfirmed;
    switch (state.endStatus) {
      case CallStatus.awaitingFeedback:
        return isRequester
            ? l10n.callEndedRequesterCounted(name)
            : l10n.callEndedDriverCounted(
                formatSpoken(connected),
                name,
                formatRupees(r?.holdAmount ?? '0'),
                formatRupees(r?.amount ?? '0'),
              );
      case CallStatus.failed:
        return l10n.callEndedTooShort(state.thresholdSeconds);
      case CallStatus.accepted:
        return l10n.callEndedUnanswered(name);
      case CallStatus.cancelled:
        return l10n.callEndedDeclined(name);
      default:
        return l10n.callEndedOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = state.endedRequest ?? state.request;
    final name = r == null
        ? l10n.oneToOneRequesterFallback
        : partyName(r.otherParty, l10n.oneToOneRequesterFallback);
    final connected = r?.connectedSeconds ?? state.connectedSeconds;
    final askForFeedback =
        isRequester &&
        state.endStatus == CallStatus.awaitingFeedback &&
        r != null &&
        !state.endUnconfirmed;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.callEndedTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _message(l10n, r, name, connected),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                if (askForFeedback)
                  SatisfactionPrompt(
                    request: r,
                    onLater: onLater,
                    onDone: onDone,
                  )
                else
                  ElevatedButton(
                    onPressed: onDone,
                    child: Text(l10n.callDoneButton),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// The call while it rings or is on.
class _LiveView extends ConsumerWidget {
  final String requestId;
  final CallSessionState state;
  final VoidCallback onEnd;
  final VoidCallback onChat;

  const _LiveView({
    required this.requestId,
    required this.state,
    required this.onEnd,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(callSessionProvider(requestId).notifier);
    final engine = state.mediaReady ? controller.engine : null;
    final request = state.request!;
    final isRequester = request.isRequester;
    final name = partyName(request.otherParty, l10n.oneToOneRequesterFallback);
    final ringing = state.phase == CallPhase.ringing;

    // What fills the screen: the driver's own camera for the driver, the
    // driver's camera for the requester.
    Widget backdrop = const SizedBox.expand();
    if (engine != null) {
      if (!isRequester && !state.cameraOff) {
        backdrop = SizedBox.expand(child: engine.localVideo());
      } else if (isRequester && state.peerVideo && state.peerUid != null) {
        backdrop = SizedBox.expand(child: engine.remoteVideo(state.peerUid!));
      }
    }
    final showsVideo =
        engine != null &&
        ((!isRequester && !state.cameraOff) ||
            (isRequester && state.peerVideo && state.peerUid != null));

    final String statusLine;
    if (ringing) {
      statusLine = l10n.callRingingHint;
    } else if (state.connectionLost) {
      statusLine = l10n.callYouDropped;
    } else if (!state.peerPresent) {
      statusLine = state.peerEverJoined
          ? l10n.callPeerDropped(name)
          : l10n.callWaitingForPeer(name);
    } else {
      statusLine = isRequester ? '' : l10n.callAudioOnlyNote(name);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (showsVideo)
          backdrop
        else
          _AvatarBackdrop(name: name, photo: request.otherParty.photo),
        // A soft scrim so the white text reads over any video.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99000000), Colors.transparent, Color(0xB3000000)],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Text(
                      ringing ? l10n.callRingingTitle(name) : name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (statusLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        statusLine,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (!ringing) ...[
                      const SizedBox(height: 10),
                      _TimeAndCounted(requestId: requestId, state: state),
                    ],
                    if (state.serverUnreachable) ...[
                      const SizedBox(height: 10),
                      _Notice(text: l10n.callServerUnreachable),
                    ],
                    if (state.connectionLost) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: controller.reconnect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.white),
                        ),
                        child: Text(l10n.callReconnectButton),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (isRequester && !ringing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.callAudioOnlyNote(name),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                child: _Controls(
                  state: state,
                  isRequester: isRequester,
                  ringing: ringing,
                  controller: controller,
                  onEnd: onEnd,
                  onChat: onChat,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarBackdrop extends StatelessWidget {
  final String name;
  final String? photo;

  const _AvatarBackdrop({required this.name, this.photo});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      color: AppColors.primaryDark,
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 56,
        backgroundColor: AppColors.primaryDarkLight,
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.red),
      ),
    );
  }
}

/// "12:05 left" counting down between heartbeats, and whether the call has
/// counted yet.
class _TimeAndCounted extends ConsumerStatefulWidget {
  final String requestId;
  final CallSessionState state;

  const _TimeAndCounted({required this.requestId, required this.state});

  @override
  ConsumerState<_TimeAndCounted> createState() => _TimeAndCountedState();
}

class _TimeAndCountedState extends ConsumerState<_TimeAndCounted> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = widget.state;
    final asOf = s.remainingAsOf;
    final elapsed = asOf == null
        ? 0
        : ref.read(callClockProvider)().difference(asOf).inSeconds;
    final left = s.remainingSeconds - (elapsed < 0 ? 0 : elapsed);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        _Pill(
          icon: Icons.timer_outlined,
          text: l10n.callTimeLeft(formatClock(left)),
          color: AppColors.white,
        ),
        _Pill(
          icon: s.counted ? Icons.check_circle : Icons.hourglass_top,
          text: s.counted
              ? l10n.callCounted
              : l10n.callCountsAfter(s.thresholdSeconds),
          color: s.counted ? const Color(0xFF86EFAC) : AppColors.white,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Pill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x55000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          // Wraps rather than overflows: a long translation on a narrow phone.
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final CallSessionState state;
  final bool isRequester;
  final bool ringing;
  final CallSessionNotifier controller;
  final VoidCallback onEnd;
  final VoidCallback onChat;

  const _Controls({
    required this.state,
    required this.isRequester,
    required this.ringing,
    required this.controller,
    required this.onEnd,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final end = _RoundButton(
      icon: Icons.call_end,
      label: ringing ? l10n.callCancelRingButton : l10n.callEndButton,
      background: AppColors.red,
      onTap: onEnd,
    );
    if (ringing) return Center(child: end);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundButton(
          icon: state.micMuted ? Icons.mic_off : Icons.mic,
          label: state.micMuted ? l10n.callUnmute : l10n.callMute,
          active: state.micMuted,
          onTap: controller.toggleMic,
        ),
        if (isRequester)
          _RoundButton(
            icon: state.speakerOn ? Icons.volume_up : Icons.volume_down,
            label: l10n.callSpeaker,
            active: !state.speakerOn,
            onTap: controller.toggleSpeaker,
          )
        else ...[
          _RoundButton(
            icon: state.cameraOff ? Icons.videocam_off : Icons.videocam,
            label: state.cameraOff ? l10n.callCameraOn : l10n.callCameraOff,
            active: state.cameraOff,
            onTap: controller.toggleCamera,
          ),
          _RoundButton(
            icon: Icons.cameraswitch,
            label: l10n.callFlip,
            onTap: controller.switchCamera,
          ),
        ],
        _RoundButton(
          icon: Icons.chat_bubble_outline,
          label: l10n.callChat,
          badge: state.unreadChat,
          onTap: onChat,
        ),
        end,
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? background;
  final int badge;

  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.background,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fill =
        background ??
        (active
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.18));
    final iconColor = background == null && active
        ? AppColors.primaryDark
        : AppColors.white;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: AppColors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// The in-call chat. Lines live only in memory for this call.
class _ChatSheet extends ConsumerStatefulWidget {
  final String requestId;

  const _ChatSheet({required this.requestId});

  @override
  ConsumerState<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<_ChatSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _failed = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    final ok = await ref
        .read(callSessionProvider(widget.requestId).notifier)
        .sendChat(text);
    if (!mounted) return;
    setState(() => _failed = !ok);
    if (ok) _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chat = ref.watch(callSessionProvider(widget.requestId)).chat;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.callChatTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: chat.isEmpty
                  ? Center(
                      child: Text(
                        l10n.callChatEmpty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: chat.length,
                      itemBuilder: (_, i) => _Bubble(message: chat[i]),
                    ),
            ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.callChatSendFailed,
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      maxLength: 240,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: l10n.callChatHint,
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final CallChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryBlue : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: mine ? AppColors.white : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
