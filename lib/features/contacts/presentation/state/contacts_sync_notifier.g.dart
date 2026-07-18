// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_sync_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsDeviceDataSourceHash() =>
    r'e25507a08dccda49f7cbdec70a4afd2488759ae8';

/// See also [contactsDeviceDataSource].
@ProviderFor(contactsDeviceDataSource)
final contactsDeviceDataSourceProvider =
    AutoDisposeProvider<ContactsDeviceDataSource>.internal(
      contactsDeviceDataSource,
      name: r'contactsDeviceDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsDeviceDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsDeviceDataSourceRef =
    AutoDisposeProviderRef<ContactsDeviceDataSource>;
String _$contactsLocalDataSourceHash() =>
    r'2dc2621ad2268124f435bc90bf5e1f9abc6368eb';

/// See also [contactsLocalDataSource].
@ProviderFor(contactsLocalDataSource)
final contactsLocalDataSourceProvider =
    AutoDisposeProvider<ContactsLocalDataSource>.internal(
      contactsLocalDataSource,
      name: r'contactsLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsLocalDataSourceRef =
    AutoDisposeProviderRef<ContactsLocalDataSource>;
String _$contactsRemoteDataSourceHash() =>
    r'7a0d04dd17d687015ee5754d305d00800a675954';

/// See also [contactsRemoteDataSource].
@ProviderFor(contactsRemoteDataSource)
final contactsRemoteDataSourceProvider =
    AutoDisposeProvider<ContactsRemoteDataSource>.internal(
      contactsRemoteDataSource,
      name: r'contactsRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsRemoteDataSourceRef =
    AutoDisposeProviderRef<ContactsRemoteDataSource>;
String _$contactsRepositoryHash() =>
    r'6fc6d3f059772abd7be5deed1b99ca41b92678a7';

/// See also [contactsRepository].
@ProviderFor(contactsRepository)
final contactsRepositoryProvider =
    AutoDisposeProvider<ContactsRepository>.internal(
      contactsRepository,
      name: r'contactsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsRepositoryRef = AutoDisposeProviderRef<ContactsRepository>;
String _$syncContactsUseCaseHash() =>
    r'5f72437d74ab075087cccb10ae429554bf64b32c';

/// See also [syncContactsUseCase].
@ProviderFor(syncContactsUseCase)
final syncContactsUseCaseProvider =
    AutoDisposeProvider<SyncContactsUseCase>.internal(
      syncContactsUseCase,
      name: r'syncContactsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncContactsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncContactsUseCaseRef = AutoDisposeProviderRef<SyncContactsUseCase>;
String _$hasContactsPermissionHash() =>
    r'3d48d99d0f1ab91617353265c1ab8caf4824d6de';

/// Whether contacts permission is currently granted — used to decide
/// whether the mutual-connections UI has any way to resolve a match, since
/// a granted-then-later-revoked permission leaves no path to show it.
///
/// Copied from [hasContactsPermission].
@ProviderFor(hasContactsPermission)
final hasContactsPermissionProvider = AutoDisposeFutureProvider<bool>.internal(
  hasContactsPermission,
  name: r'hasContactsPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasContactsPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasContactsPermissionRef = AutoDisposeFutureProviderRef<bool>;
String _$contactsSyncNotifierHash() =>
    r'a337ac6c7de20b59cc20a55b0effac900be9320b';

/// See also [ContactsSyncNotifier].
@ProviderFor(ContactsSyncNotifier)
final contactsSyncNotifierProvider =
    AutoDisposeNotifierProvider<
      ContactsSyncNotifier,
      ContactsSyncState
    >.internal(
      ContactsSyncNotifier.new,
      name: r'contactsSyncNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactsSyncNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactsSyncNotifier = AutoDisposeNotifier<ContactsSyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
