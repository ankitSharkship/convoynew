/// Paths of the 1:1 call screens.
class CallRoutes {
  static const prefix = '/video-call';

  /// The call itself. [mode] is `start` (driver rings), `answer` (requester
  /// picks up) or `rejoin` (back into a call that is still on).
  static String call(String requestId, {required String mode, bool? driver}) =>
      '$prefix/$requestId?mode=$mode${driver == null ? '' : '&driver=${driver ? 1 : 0}'}';

  /// The requester's "X is calling you" screen.
  static String incoming(String requestId) => '$prefix/$requestId/incoming';

  /// "You are still in a call. Rejoin?"
  static String rejoin(String requestId) => '$prefix/$requestId/rejoin';

  /// "Were you satisfied?"
  static String feedback(String requestId) => '$prefix/$requestId/feedback';

  static bool isCallPath(String path) => path.startsWith('$prefix/');

  /// The request a call path is about, if it is one.
  static String? requestIdOf(String path) {
    if (!isCallPath(path)) return null;
    final rest = path.substring(prefix.length + 1);
    final id = rest.split('/').first;
    return id.isEmpty ? null : id;
  }
}
