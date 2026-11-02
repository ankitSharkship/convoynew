import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'incoming_call_ui.dart';

/// The iPhone's CallKit screen, through our own small native layer
/// (ios/Runner/CallKitBridge.swift). It is ours rather than a plugin's because
/// iOS requires a VoIP push to be reported to CallKit *immediately*, even when
/// the phone launched the app in the background and Flutter is not running: the
/// native layer does that on its own, queues what the person does with the
/// call, and hands it over once this side attaches.
class IosCallKitUi implements IncomingCallUi {
  static const channelName = 'convoy/callkit';

  final MethodChannel _channel;
  final StreamController<IncomingCallEvent> _events =
      StreamController<IncomingCallEvent>.broadcast();
  final StreamController<String> _tokens = StreamController<String>.broadcast();
  bool _attached = false;

  IosCallKitUi({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// Starts listening to the native side. Anything that happened before this
  /// (an answer while the app was closed) is replayed right away.
  Future<void> attach() async {
    if (_attached) return;
    _attached = true;
    _channel.setMethodCallHandler(_fromNative);
    try {
      await _channel.invokeMethod<void>('attach');
    } on MissingPluginException {
      // Not running inside the real app (a test, say).
    } on PlatformException catch (e) {
      debugPrint('CallKit attach failed: $e');
    }
  }

  Future<dynamic> _fromNative(MethodCall call) async {
    switch (call.method) {
      case 'event':
        final args = call.arguments;
        if (args is! Map) return null;
        final type = _type(args['type']);
        final id = args['requestId'];
        if (type != null && id is String && id.isNotEmpty) {
          _events.add(IncomingCallEvent(type, id));
        }
      case 'voipToken':
        final token = call.arguments;
        if (token is String && token.isNotEmpty) _tokens.add(token);
    }
    return null;
  }

  static IncomingCallEventType? _type(Object? name) => switch (name) {
    'shown' => IncomingCallEventType.shown,
    'accepted' => IncomingCallEventType.accepted,
    'declined' => IncomingCallEventType.declined,
    'ended' => IncomingCallEventType.ended,
    'timedOut' => IncomingCallEventType.timedOut,
    _ => null,
  };

  @override
  Stream<IncomingCallEvent> get events {
    unawaited(attach());
    return _events.stream;
  }

  @override
  bool get showsWhileAppIsOpen => true;

  @override
  Future<void> prepare() => attach();

  @override
  Future<void> requestPermissions() async {} // CallKit needs none

  Future<void> _invoke(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // Not inside the real app.
    } on PlatformException catch (e) {
      debugPrint('CallKit $method failed: $e');
    }
  }

  @override
  Future<void> show(IncomingCallInfo info) => _invoke('show', {
    'requestId': info.requestId,
    'callerName': info.callerName,
    'topic': info.topic,
    'ringEndsAtMs': info.ringEndsAt.millisecondsSinceEpoch,
  });

  @override
  Future<void> end(String requestId) =>
      _invoke('end', {'requestId': requestId});

  @override
  Future<void> setConnected(String requestId) =>
      _invoke('connected', {'requestId': requestId});

  @override
  Future<List<String>> acceptedWhileAway() async => const [];

  @override
  Future<String?> currentVoipToken() async {
    try {
      final token = await _channel.invokeMethod<String>('voipToken');
      return token == null || token.isEmpty ? null : token;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Stream<String> get voipTokenChanges {
    unawaited(attach());
    return _tokens.stream;
  }

  /// Asks the native side, which reads the app's provisioning profile (App
  /// Store and TestFlight builds have none: production). If it cannot say, a
  /// release build is taken as production and anything else as sandbox.
  @override
  Future<bool> isVoipSandbox() async {
    try {
      final environment = await _channel.invokeMethod<String>('pushEnvironment');
      if (environment == 'sandbox') return true;
      if (environment == 'production') return false;
    } on MissingPluginException {
      // fall through
    } on PlatformException {
      // fall through
    }
    return !kReleaseMode;
  }
}
