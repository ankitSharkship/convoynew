import 'package:convoynew/core/services/fcm_token_service.dart';
import 'package:convoynew/core/services/voip_token_source.dart';
import 'package:convoynew/features/devices/data/datasources/device_local_datasource.dart';
import 'package:convoynew/features/devices/data/datasources/device_remote_datasource.dart';
import 'package:convoynew/features/devices/data/repositories/device_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FakeFcm implements FcmTokenService {
  String? token = 'fcm-1';

  @override
  Future<void> requestPermission() async {}

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

class FakeVoip implements VoipTokenSource {
  String? token;
  bool sandbox = true;
  bool failing = false;

  @override
  Future<String?> currentVoipToken() async {
    if (failing) throw StateError('native side down');
    return token;
  }

  @override
  Stream<String> get voipTokenChanges => const Stream.empty();

  @override
  Future<bool> isVoipSandbox() async {
    if (failing) throw StateError('native side down');
    return sandbox;
  }
}

class FakeRemote implements DeviceRemoteDataSource {
  final List<Map<String, Object?>> registered = [];

  @override
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String fcmToken,
    String? appVersion,
    String? deviceName,
    String? voipToken,
    bool? voipSandbox,
  }) async {
    registered.add({'fcm': fcmToken, 'voip': voipToken, 'sandbox': voipSandbox});
  }

  @override
  Future<void> logoutDevice({required String userId, required String deviceId}) async {}
}

class FakeLocal implements DeviceLocalDataSource {
  String? fcm;
  String? voip;

  @override
  Future<String> getOrCreateDeviceId() async => 'device-1';

  @override
  Future<String?> getLastSyncedFcmToken() async => fcm;

  @override
  Future<void> saveLastSyncedFcmToken(String token) async => fcm = token;

  @override
  Future<String?> getLastSyncedVoipToken() async => voip;

  @override
  Future<void> saveLastSyncedVoipToken(String token) async => voip = token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PackageInfo.setMockInitialValues(
    appName: 'Bonut',
    packageName: 'com.sharkship.bonut',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );

  late FakeFcm fcm;
  late FakeVoip voip;
  late FakeRemote remote;
  late FakeLocal local;
  late DeviceRepositoryImpl repo;

  setUp(() {
    fcm = FakeFcm();
    voip = FakeVoip();
    remote = FakeRemote();
    local = FakeLocal();
    repo = DeviceRepositoryImpl(remote, local, fcm, voip);
  });

  test('registering sends the VoIP token and which Apple server it belongs to', () async {
    voip.token = 'voip-1';
    voip.sandbox = true;
    await repo.registerDevice('u1');
    expect(remote.registered.single, {'fcm': 'fcm-1', 'voip': 'voip-1', 'sandbox': true});
    expect(local.voip, 'voip-1');
  });

  test('a phone with no VoIP token (Android) registers as before, saying nothing about VoIP', () async {
    await repo.registerDevice('u1');
    expect(remote.registered.single, {'fcm': 'fcm-1', 'voip': null, 'sandbox': null});
    expect(local.voip, isNull);
  });

  test('nothing changed: nothing is sent', () async {
    voip.token = 'voip-1';
    await repo.registerDevice('u1');
    remote.registered.clear();
    await repo.syncIfTokenChanged('u1');
    expect(remote.registered, isEmpty);
  });

  test('a new VoIP token alone (it arrives after the FCM one) is synced', () async {
    await repo.registerDevice('u1'); // no VoIP token yet
    remote.registered.clear();

    voip.token = 'voip-1'; // iOS hands it over a moment later
    await repo.syncIfTokenChanged('u1');
    expect(remote.registered.single['voip'], 'voip-1');

    remote.registered.clear();
    voip.token = 'voip-2'; // rotated
    await repo.syncIfTokenChanged('u1');
    expect(remote.registered.single['voip'], 'voip-2');
  });

  test('a new FCM token alone is still synced', () async {
    voip.token = 'voip-1';
    await repo.registerDevice('u1');
    remote.registered.clear();
    fcm.token = 'fcm-2';
    await repo.syncIfTokenChanged('u1');
    expect(remote.registered.single, {'fcm': 'fcm-2', 'voip': 'voip-1', 'sandbox': true});
  });

  test('a broken VoIP lookup never blocks ordinary push registration', () async {
    voip.failing = true;
    await repo.registerDevice('u1');
    expect(remote.registered.single, {'fcm': 'fcm-1', 'voip': null, 'sandbox': null});
    await repo.syncIfTokenChanged('u1'); // and the diff check does not throw either
  });

  test('without a VoIP source (calls switched off) behaviour is exactly as before', () async {
    final plain = DeviceRepositoryImpl(remote, local, fcm);
    await plain.registerDevice('u1');
    remote.registered.clear();
    await plain.syncIfTokenChanged('u1');
    expect(remote.registered, isEmpty);
  });
}
