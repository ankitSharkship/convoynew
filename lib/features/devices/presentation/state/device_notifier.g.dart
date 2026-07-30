// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceLocalDataSourceHash() =>
    r'4eeef280c1c91e59596393ef861f15510f4d387e';

/// See also [deviceLocalDataSource].
@ProviderFor(deviceLocalDataSource)
final deviceLocalDataSourceProvider =
    AutoDisposeProvider<DeviceLocalDataSource>.internal(
      deviceLocalDataSource,
      name: r'deviceLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deviceLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceLocalDataSourceRef =
    AutoDisposeProviderRef<DeviceLocalDataSource>;
String _$deviceRemoteDataSourceHash() =>
    r'614b51062828afa3b0e68398b20f73b547fe93c0';

/// See also [deviceRemoteDataSource].
@ProviderFor(deviceRemoteDataSource)
final deviceRemoteDataSourceProvider =
    AutoDisposeProvider<DeviceRemoteDataSource>.internal(
      deviceRemoteDataSource,
      name: r'deviceRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deviceRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceRemoteDataSourceRef =
    AutoDisposeProviderRef<DeviceRemoteDataSource>;
String _$fcmTokenServiceHash() => r'98bc3892203574cbcbcbc31a62ff5fa863c3336e';

/// See also [fcmTokenService].
@ProviderFor(fcmTokenService)
final fcmTokenServiceProvider = AutoDisposeProvider<FcmTokenService>.internal(
  fcmTokenService,
  name: r'fcmTokenServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenServiceRef = AutoDisposeProviderRef<FcmTokenService>;
String _$deviceRepositoryHash() => r'106c679ff998908cff543ccfcdd087722fa7c040';

/// See also [deviceRepository].
@ProviderFor(deviceRepository)
final deviceRepositoryProvider =
    AutoDisposeProvider<DeviceRepositoryImpl>.internal(
      deviceRepository,
      name: r'deviceRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deviceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceRepositoryRef = AutoDisposeProviderRef<DeviceRepositoryImpl>;
String _$registerDeviceUseCaseHash() =>
    r'23e23fd13708cd81bb005e8f7acce054d7592eff';

/// See also [registerDeviceUseCase].
@ProviderFor(registerDeviceUseCase)
final registerDeviceUseCaseProvider =
    AutoDisposeProvider<RegisterDeviceUseCase>.internal(
      registerDeviceUseCase,
      name: r'registerDeviceUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$registerDeviceUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RegisterDeviceUseCaseRef =
    AutoDisposeProviderRef<RegisterDeviceUseCase>;
String _$syncDeviceTokenIfChangedUseCaseHash() =>
    r'0b0c3660023fac9fc18d833389078a829542c069';

/// See also [syncDeviceTokenIfChangedUseCase].
@ProviderFor(syncDeviceTokenIfChangedUseCase)
final syncDeviceTokenIfChangedUseCaseProvider =
    AutoDisposeProvider<SyncDeviceTokenIfChangedUseCase>.internal(
      syncDeviceTokenIfChangedUseCase,
      name: r'syncDeviceTokenIfChangedUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncDeviceTokenIfChangedUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncDeviceTokenIfChangedUseCaseRef =
    AutoDisposeProviderRef<SyncDeviceTokenIfChangedUseCase>;
String _$logoutDeviceUseCaseHash() =>
    r'621a0395b0bcae422b2a5fe54875b3639e37d8ea';

/// See also [logoutDeviceUseCase].
@ProviderFor(logoutDeviceUseCase)
final logoutDeviceUseCaseProvider =
    AutoDisposeProvider<LogoutDeviceUseCase>.internal(
      logoutDeviceUseCase,
      name: r'logoutDeviceUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$logoutDeviceUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogoutDeviceUseCaseRef = AutoDisposeProviderRef<LogoutDeviceUseCase>;
String _$deviceTokenRefreshListenerHash() =>
    r'752381ae9ea943b987c604b0015bc3d88945858b';

/// Kept alive for the app's whole lifetime (watched once from [App]'s
/// build method) so FCM's token-rotation callback is always listened to —
/// that's the one case a launch-time/login-time token diff can't catch,
/// since it can fire at any point while the app is already running.
///
/// Copied from [DeviceTokenRefreshListener].
@ProviderFor(DeviceTokenRefreshListener)
final deviceTokenRefreshListenerProvider =
    NotifierProvider<DeviceTokenRefreshListener, void>.internal(
      DeviceTokenRefreshListener.new,
      name: r'deviceTokenRefreshListenerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deviceTokenRefreshListenerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeviceTokenRefreshListener = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
