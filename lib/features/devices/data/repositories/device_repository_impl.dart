import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/services/fcm_token_service.dart';
import '../../../../core/services/voip_token_source.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remote;
  final DeviceLocalDataSource _local;
  final FcmTokenService _fcm;
  final VoipTokenSource _voip;

  DeviceRepositoryImpl(
    this._remote,
    this._local,
    this._fcm, [
    this._voip = const NoVoipTokenSource(),
  ]);

  @override
  Future<void> registerDevice(String userId) async {
    final token = await _currentFcmToken();
    if (token == null) return;
    await _sendRegister(userId, token);
  }

  @override
  Future<void> syncIfTokenChanged(String userId) async {
    final token = await _currentFcmToken();
    if (token == null) return;

    final lastSynced = await _local.getLastSyncedFcmToken();
    // The iPhone's VoIP token arrives separately (and later) than the FCM one:
    // a new one on its own is reason enough to tell the server.
    final voip = await _safeVoipToken();
    final voipChanged =
        voip != null && voip != await _local.getLastSyncedVoipToken();
    if (token == lastSynced && !voipChanged) return;

    await _sendRegister(userId, token);
  }

  @override
  Future<void> logoutDevice(String userId) async {
    final deviceId = await _local.getOrCreateDeviceId();
    await _remote.logoutDevice(userId: userId, deviceId: deviceId);
  }

  Future<String?> _currentFcmToken() async {
    await _fcm.requestPermission();
    return _fcm.getToken();
  }

  Future<void> _sendRegister(String userId, String token) async {
    final deviceId = await _local.getOrCreateDeviceId();
    final packageInfo = await PackageInfo.fromPlatform();
    final voip = await _safeVoipToken();
    await _remote.registerDevice(
      userId: userId,
      deviceId: deviceId,
      platform: _platform,
      fcmToken: token,
      appVersion: packageInfo.version,
      deviceName: await _deviceName(),
      voipToken: voip,
      voipSandbox: voip == null ? null : await _safeSandbox(),
    );
    await _local.saveLastSyncedFcmToken(token);
    if (voip != null) await _local.saveLastSyncedVoipToken(voip);
  }

  /// Never lets a VoIP lookup problem block the ordinary push registration.
  Future<String?> _safeVoipToken() async {
    try {
      return await _voip.currentVoipToken();
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _safeSandbox() async {
    try {
      return await _voip.isVoipSandbox();
    } catch (_) {
      return null;
    }
  }

  String get _platform {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  Future<String?> _deviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) return null;
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.utsname.machine;
      }
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}';
      }
    } catch (_) {
      // Best-effort metadata only — never let a device-info lookup failure
      // block registration.
    }
    return null;
  }
}
