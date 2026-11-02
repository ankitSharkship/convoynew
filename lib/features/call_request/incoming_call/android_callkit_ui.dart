import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'incoming_call_ui.dart';

/// Android's full-screen incoming-call screen, through `flutter_callkit_incoming`.
/// Used from the app and, when the phone is asleep, from the push handler that
/// runs without the app (call_background_handler.dart).
class AndroidCallkitUi implements IncomingCallUi {
  const AndroidCallkitUi();

  @override
  bool get showsWhileAppIsOpen => false;

  @override
  Stream<IncomingCallEvent> get events => FlutterCallkitIncoming.onEvent
      .map(_map)
      .where((event) => event != null)
      .cast<IncomingCallEvent>();

  static IncomingCallEvent? _map(CallEvent? event) {
    IncomingCallEvent? of(IncomingCallEventType type, CallKitParams? params) =>
        params == null ? null : IncomingCallEvent(type, params.id);
    return switch (event) {
      CallEventActionCallIncoming(:final callKitParams) => of(
        IncomingCallEventType.shown,
        callKitParams,
      ),
      CallEventActionCallAccept(:final callKitParams) => of(
        IncomingCallEventType.accepted,
        callKitParams,
      ),
      CallEventActionCallDecline(:final callKitParams) => of(
        IncomingCallEventType.declined,
        callKitParams,
      ),
      CallEventActionCallEnded(:final callKitParams) => of(
        IncomingCallEventType.ended,
        callKitParams,
      ),
      CallEventActionCallTimeout(:final id) => IncomingCallEvent(
        IncomingCallEventType.timedOut,
        id,
      ),
      _ => null,
    };
  }

  @override
  Future<void> prepare() async {}

  @override
  Future<void> requestPermissions() async {
    try {
      await FlutterCallkitIncoming.requestNotificationPermission({
        'title': 'Notification permission',
        'rationaleMessagePermission':
            'Notification permission is required to show incoming calls.',
        'postNotificationMessageRequired':
            'Allow notifications in Settings to see incoming calls.',
      });
      if (await FlutterCallkitIncoming.canUseFullScreenIntent() == false) {
        await FlutterCallkitIncoming.requestFullIntentPermission();
      }
    } catch (e) {
      debugPrint('Preparing the call screen failed: $e');
    }
  }

  @override
  Future<void> show(IncomingCallInfo info) async {
    final remaining = info.remaining(DateTime.now().toUtc());
    // Nobody can still answer: do not ring for a call that is already over.
    if (remaining == Duration.zero) return;
    await FlutterCallkitIncoming.showCallkitIncoming(
      CallKitParams(
        id: info.requestId,
        nameCaller: info.callerName,
        appName: 'Bonut',
        handle: info.topic,
        type: 0, // audio: the requester sends only a microphone
        duration: remaining.inMilliseconds,
        extra: {'requestId': info.requestId},
        missedCallNotification: const NotificationParams(
          showNotification: false,
        ),
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#1C223B',
          actionColor: '#16A34A',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: 'Incoming 1:1 calls',
          isShowFullLockedScreen: true,
          textAccept: 'Answer',
          textDecline: 'Decline',
        ),
      ),
    );
  }

  @override
  Future<void> end(String requestId) async {
    try {
      await FlutterCallkitIncoming.endCall(requestId);
    } catch (e) {
      debugPrint('Ending the call screen failed: $e');
    }
  }

  @override
  Future<void> setConnected(String requestId) async {
    try {
      await FlutterCallkitIncoming.setCallConnected(requestId);
    } catch (_) {}
  }

  @override
  Future<List<String>> acceptedWhileAway() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      return [
        for (final call in calls)
          if (call.isAccepted) call.id,
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String?> currentVoipToken() async => null;

  @override
  Stream<String> get voipTokenChanges => const Stream.empty();

  @override
  Future<bool> isVoipSandbox() async => false;
}
