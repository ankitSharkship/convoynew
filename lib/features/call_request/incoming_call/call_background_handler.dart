import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'android_callkit_ui.dart';
import 'incoming_call_ui.dart';

/// Runs when a data-only push arrives while the Android app is in the
/// background or closed (registered in main.dart). It has no app around it: no
/// router, no providers, only what is needed to put the call screen up (or take
/// it down). iPhones never come here: a VoIP push is handled natively.
@pragma('vm:entry-point')
Future<void> callBackgroundMessageHandler(RemoteMessage message) async {
  if (!Platform.isAndroid) return;
  final data = message.data;
  const ui = AndroidCallkitUi();
  switch (data['type']) {
    case 'call_incoming':
      final info = IncomingCallInfo.fromPushData(Map<String, dynamic>.from(data));
      if (info != null) await ui.show(info);
    case 'call_cancelled':
      final id = data['requestId'];
      if (id is String && id.isNotEmpty) await ui.end(id);
  }
}
