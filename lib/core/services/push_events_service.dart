import 'package:firebase_messaging/firebase_messaging.dart';

/// What a push about a 1:1 call is about. The backend sends these as FCM
/// `data` next to the visible notification (docs/ONE_TO_ONE_CALL_API.md).
class PushEvent {
  /// e.g. `call_request` (a new request for the driver), `call_request_accepted`,
  /// `call_incoming`, `call_payment`.
  final String type;

  /// The call request it is about.
  final String? requestId;

  const PushEvent({required this.type, this.requestId});

  /// A new request waiting for this user, as the driver.
  bool get isNewIncomingRequest => type == 'call_request';
}

/// The push `type`s that belong to the 1:1 call feature. Anything else (a
/// campaign message, a KYC update, ...) is not this feature's business.
const callPushTypes = {
  'call_request',
  'call_request_accepted',
  'call_request_rejected',
  'call_request_expired',
  'call_incoming',
  'call_cancelled',
  'call_missed',
  'call_feedback_needed',
  'call_payment',
};

/// Reads a push's `data` map, or null if it is not a 1:1 call push.
PushEvent? pushEventFromData(Map<String, dynamic> data) {
  final type = data['type'];
  if (type is! String || !callPushTypes.contains(type)) return null;
  final id = data['requestId'];
  return PushEvent(type: type, requestId: id is String && id.isNotEmpty ? id : null);
}

/// Where call pushes come from. A seam so tests can feed events in without
/// Firebase.
abstract class PushEventsSource {
  /// A push that arrived while the app is open.
  Stream<PushEvent> get whileOpen;

  /// The user tapped a push while the app was in the background.
  Stream<PushEvent> get tapped;

  /// The push the user tapped to launch the app from closed, if any.
  Future<PushEvent?> launchedFrom();
}

class FirebasePushEventsSource implements PushEventsSource {
  final FirebaseMessaging _messaging;

  FirebasePushEventsSource(this._messaging);

  @override
  Stream<PushEvent> get whileOpen => FirebaseMessaging.onMessage
      .map((message) => pushEventFromData(message.data))
      .where((event) => event != null)
      .cast<PushEvent>();

  @override
  Stream<PushEvent> get tapped => FirebaseMessaging.onMessageOpenedApp
      .map((message) => pushEventFromData(message.data))
      .where((event) => event != null)
      .cast<PushEvent>();

  @override
  Future<PushEvent?> launchedFrom() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : pushEventFromData(message.data);
  }
}
