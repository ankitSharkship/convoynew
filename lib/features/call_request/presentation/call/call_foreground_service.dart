import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Android "call in progress" foreground service (android/.../CallForegroundService.kt).
/// It is what lets a call's microphone and camera keep working when the person
/// switches to another app. Other platforms do nothing: iOS keeps a call alive
/// with its audio background mode.
abstract class CallForegroundService {
  /// [withCamera] for the driver, whose camera must keep running too.
  Future<void> start({
    required String title,
    required String text,
    required bool withCamera,
  });

  Future<void> stop();
}

class NoCallForegroundService implements CallForegroundService {
  const NoCallForegroundService();

  @override
  Future<void> start({
    required String title,
    required String text,
    required bool withCamera,
  }) async {}

  @override
  Future<void> stop() async {}
}

class AndroidCallForegroundService implements CallForegroundService {
  static const channelName = 'convoy/call_service';
  final MethodChannel _channel;

  AndroidCallForegroundService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  /// Never throws: a call must not fail because its notification could not be shown.
  @override
  Future<void> start({
    required String title,
    required String text,
    required bool withCamera,
  }) async {
    try {
      await _channel.invokeMethod<void>('start', {
        'title': title,
        'text': text,
        'video': withCamera,
      });
    } catch (e) {
      debugPrint('Starting the call service failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (e) {
      debugPrint('Stopping the call service failed: $e');
    }
  }
}

final callForegroundServiceProvider = Provider<CallForegroundService>((ref) {
  if (!kIsWeb && Platform.isAndroid) return AndroidCallForegroundService();
  return const NoCallForegroundService();
});
