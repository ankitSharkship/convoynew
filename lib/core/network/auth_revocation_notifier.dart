import 'package:flutter/foundation.dart';

/// Notifies listeners when the server revokes the session (HTTP 401).
///
/// Wired into GoRouter's `refreshListenable` so that a 401 on any API
/// call triggers a redirect check, which bounces the user to the login
/// screen once it sees the token has been cleared.
class AuthRevocationNotifier extends ChangeNotifier {
  void revoke() => notifyListeners();
}
