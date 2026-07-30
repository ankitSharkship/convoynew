import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class DeviceLocalDataSource {
  /// Generated once on first launch and reused forever. Backed by the
  /// platform Keychain on iOS (persists across reinstall) and by
  /// SharedPreferences on Android, which is cleared on uninstall by
  /// design — a reinstall is meant to look like a new device there.
  Future<String> getOrCreateDeviceId();

  Future<String?> getLastSyncedFcmToken();

  Future<void> saveLastSyncedFcmToken(String token);
}

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  static const _deviceIdKey = 'device_id';
  static const _lastSyncedFcmTokenKey = 'last_synced_fcm_token';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;
  final Uuid _uuid;

  DeviceLocalDataSourceImpl(
    this._secureStorage,
    this._prefs, {
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  @override
  Future<String> getOrCreateDeviceId() async {
    final existing = await _secureStorage.read(key: _deviceIdKey);
    if (existing != null) return existing;

    final generated = _uuid.v4();
    await _secureStorage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  @override
  Future<String?> getLastSyncedFcmToken() =>
      Future.value(_prefs.getString(_lastSyncedFcmTokenKey));

  @override
  Future<void> saveLastSyncedFcmToken(String token) =>
      _prefs.setString(_lastSyncedFcmTokenKey, token);
}
