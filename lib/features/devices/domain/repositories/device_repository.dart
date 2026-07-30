abstract class DeviceRepository {
  /// Always registers this device against [userId], regardless of whether
  /// the FCM token changed — used right after a login, since that's also
  /// how a device handed off to a different user gets reassigned
  /// server-side (same deviceId, new userId).
  Future<void> registerDevice(String userId);

  /// Registers only if the current FCM token differs from the last one
  /// synced for this device — used on app start and on FCM token refresh,
  /// so a healthy session doesn't re-hit the register endpoint every time.
  Future<void> syncIfTokenChanged(String userId);

  Future<void> logoutDevice(String userId);
}
