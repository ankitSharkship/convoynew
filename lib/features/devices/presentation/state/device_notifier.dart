import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/feature_flags.dart';
import '../../../../core/services/fcm_token_service.dart';
import '../../../../core/services/voip_token_source.dart';
import '../../../call_request/incoming_call/incoming_call_controller.dart';
import '../../../../core/storage/shared_preferences_provider.dart';
import '../../data/datasources/device_local_datasource.dart';
import '../../data/datasources/device_remote_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/usecases/logout_device_usecase.dart';
import '../../domain/usecases/register_device_usecase.dart';
import '../../domain/usecases/sync_device_token_if_changed_usecase.dart';

part 'device_notifier.g.dart';

@riverpod
DeviceLocalDataSource deviceLocalDataSource(DeviceLocalDataSourceRef ref) {
  return DeviceLocalDataSourceImpl(
    const FlutterSecureStorage(),
    ref.watch(sharedPreferencesProvider),
  );
}

@riverpod
DeviceRemoteDataSource deviceRemoteDataSource(DeviceRemoteDataSourceRef ref) {
  return DeviceRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
FcmTokenService fcmTokenService(FcmTokenServiceRef ref) {
  return FcmTokenService(FirebaseMessaging.instance);
}

@riverpod
DeviceRepositoryImpl deviceRepository(DeviceRepositoryRef ref) {
  return DeviceRepositoryImpl(
    ref.watch(deviceRemoteDataSourceProvider),
    ref.watch(deviceLocalDataSourceProvider),
    ref.watch(fcmTokenServiceProvider),
    // Only with 1:1 calls on does the phone hand its VoIP token to the server.
    FeatureFlags.oneToOneEnabled
        ? ref.watch(voipTokenSourceProvider)
        : const NoVoipTokenSource(),
  );
}

@riverpod
RegisterDeviceUseCase registerDeviceUseCase(RegisterDeviceUseCaseRef ref) {
  return RegisterDeviceUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
SyncDeviceTokenIfChangedUseCase syncDeviceTokenIfChangedUseCase(
  SyncDeviceTokenIfChangedUseCaseRef ref,
) {
  return SyncDeviceTokenIfChangedUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
LogoutDeviceUseCase logoutDeviceUseCase(LogoutDeviceUseCaseRef ref) {
  return LogoutDeviceUseCase(ref.watch(deviceRepositoryProvider));
}

/// Kept alive for the app's whole lifetime (watched once from [App]'s
/// build method) so FCM's token-rotation callback is always listened to —
/// that's the one case a launch-time/login-time token diff can't catch,
/// since it can fire at any point while the app is already running.
@Riverpod(keepAlive: true)
class DeviceTokenRefreshListener extends _$DeviceTokenRefreshListener {
  final List<StreamSubscription<String>> _subscriptions = [];

  @override
  void build() {
    final fcm = ref.watch(fcmTokenServiceProvider);

    Future<void> sync(String _) async {
      final userId = await ref.read(tokenStorageProvider).getUserId();
      if (userId == null) return;
      try {
        await ref.read(syncDeviceTokenIfChangedUseCaseProvider).execute(userId);
      } catch (_) {
        // Best-effort — a rotated token will simply be retried on the next
        // app start's diff-check if this particular sync call fails.
      }
    }

    _subscriptions.add(fcm.onTokenRefresh.listen(sync));
    // The iPhone's VoIP token can change at any time too (and the first one
    // arrives some moments after launch).
    if (FeatureFlags.oneToOneEnabled) {
      _subscriptions.add(
        ref.watch(voipTokenSourceProvider).voipTokenChanges.listen(sync),
      );
    }
    ref.onDispose(() {
      for (final subscription in _subscriptions) {
        subscription.cancel();
      }
      _subscriptions.clear();
    });
  }
}
