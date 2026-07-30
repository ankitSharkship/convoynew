import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  final FirebaseMessaging _messaging;

  FcmTokenService(this._messaging);

  Future<void> requestPermission() =>
      _messaging.requestPermission(alert: true, badge: true, sound: true);

  Future<String?> getToken() => _messaging.getToken();

  /// Fires whenever FCM rotates the token server-side — the one case a
  /// launch-time diff against the last-synced token can't catch, since it
  /// can happen while the app is already running.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
