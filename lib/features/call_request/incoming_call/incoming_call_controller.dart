import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/push_events_service.dart';
import '../../../core/services/voip_token_source.dart';
import '../../../core/storage/shared_preferences_provider.dart';
import '../presentation/call/call_session_controller.dart';
import '../presentation/state/call_providers.dart';
import '../presentation/state/call_request_notifier.dart';
import '../presentation/state/outgoing_requests_notifier.dart';
import 'android_callkit_ui.dart';
import 'incoming_call_ui.dart';
import 'ios_callkit_ui.dart';

/// The phone's own incoming-call screen for this platform.
final incomingCallUiProvider = Provider<IncomingCallUi>((ref) {
  if (kIsWeb) return const NoIncomingCallUi();
  if (Platform.isIOS) return IosCallKitUi();
  if (Platform.isAndroid) return const AndroidCallkitUi();
  return const NoIncomingCallUi();
});

/// Where device registration gets the iPhone's VoIP token.
final voipTokenSourceProvider = Provider<VoipTokenSource>(
  (ref) => ref.watch(incomingCallUiProvider),
);

/// Requests whose system call screen is up right now. While one is, the app's
/// own ring screen must not also appear for it.
final callKitShownProvider = StateProvider<Set<String>>((ref) => const {});

/// A request the person answered from the system call screen, waiting for the
/// app to be ready (past login) to open the call. Read and cleared by the
/// coordinator.
final pendingAnsweredCallProvider = StateProvider<String?>((ref) => null);

/// Remembers that the call-screen permissions were already asked for.
const permissionsAskedKey = 'call_ui_permissions_asked';

/// How close together two "answered" signals for the same request count as one
/// (the answer event and the "answered while away" check can both report it).
const answerDedupeWindow = Duration(seconds: 20);

final incomingCallControllerProvider =
    NotifierProvider<IncomingCallController, void>(IncomingCallController.new);

/// Connects the phone's call screen to the app: Answer opens the call, Decline
/// tells the server, "the driver hung up" (a silent push) takes the screen
/// down, and a call ended from the system's own controls hangs the app's call
/// up. Watched once from [App] while 1:1 calls are on.
class IncomingCallController extends Notifier<void> {
  final Map<String, DateTime> _answeredAt = {};
  late IncomingCallUi _ui;
  bool _disposed = false;

  @override
  void build() {
    _disposed = false;
    _ui = ref.watch(incomingCallUiProvider);
    final push = ref.watch(pushEventsSourceProvider);
    final subscriptions = [
      _ui.events.listen(_onUiEvent),
      push.whileOpen.listen(_onPush),
      push.tapped.listen(_onPush),
    ];
    ref.onDispose(() {
      _disposed = true;
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await _ui.prepare();
      // An answer given while the app was closed may have been missed.
      for (final id in await _ui.acceptedWhileAway()) {
        _answered(id);
      }
    } catch (e) {
      debugPrint('Starting the incoming-call screen failed: $e');
    }
  }

  /// The permissions can open system dialogs or the settings app, so they are
  /// asked for the first time only (after that the person has decided), and only
  /// once the person is logged in: the app calls this then, not at launch.
  Future<void> askPermissionsOnce() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs.getBool(permissionsAskedKey) ?? false) return;
      await prefs.setBool(permissionsAskedKey, true);
      await _ui.requestPermissions();
    } catch (e) {
      debugPrint('Asking for call-screen permissions failed: $e');
    }
  }

  void _onPush(PushEvent event) {
    final id = event.requestId;
    if (event.type == 'call_cancelled' && id != null) {
      _forget(id);
      unawaited(_ui.end(id));
    }
  }

  void _onUiEvent(IncomingCallEvent event) {
    if (_disposed) return;
    final id = event.requestId;
    switch (event.type) {
      case IncomingCallEventType.shown:
        ref.read(callKitShownProvider.notifier).update((s) => {...s, id});
      case IncomingCallEventType.accepted:
        _answered(id);
      case IncomingCallEventType.declined:
        _forget(id);
        unawaited(_decline(id));
      case IncomingCallEventType.ended:
        _forget(id);
        _hangUpIfInCall(id);
      case IncomingCallEventType.timedOut:
        _forget(id);
    }
  }

  void _forget(String id) {
    final shown = ref.read(callKitShownProvider);
    if (shown.contains(id)) {
      ref.read(callKitShownProvider.notifier).state = {...shown}..remove(id);
    }
  }

  void _answered(String id) {
    final now = ref.read(callClockProvider)();
    final before = _answeredAt[id];
    if (before != null && now.difference(before) < answerDedupeWindow) return;
    _answeredAt[id] = now;
    ref.read(pendingAnsweredCallProvider.notifier).state = id;
  }

  /// Decline on the system screen means what Decline means in the app: the
  /// request is cancelled and the money released. Best effort: if the phone is
  /// offline the ring simply runs out.
  Future<void> _decline(String id) async {
    try {
      await ref.read(callRepositoryProvider).end(id);
    } catch (e) {
      debugPrint('Declining call $id failed: $e');
    }
    if (!_disposed) ref.invalidate(outgoingActiveRequestsProvider);
  }

  void _hangUpIfInCall(String id) {
    // Only if the app's call screen is up for it: never create a session here.
    if (ref.exists(callSessionProvider(id))) {
      unawaited(ref.read(callSessionProvider(id).notifier).hangUp());
    }
  }
}
