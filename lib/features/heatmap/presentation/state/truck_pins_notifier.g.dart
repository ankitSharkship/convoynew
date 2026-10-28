// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'truck_pins_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$truckPinsRemoteDataSourceHash() => r'a75e5a10e79456f5a5bcf1a6f3b7d7d074cafdfa';

/// See also [truckPinsRemoteDataSource].
@ProviderFor(truckPinsRemoteDataSource)
final truckPinsRemoteDataSourceProvider = AutoDisposeProvider<TruckPinsRemoteDataSource>.internal(
  truckPinsRemoteDataSource,
  name: r'truckPinsRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$truckPinsRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TruckPinsRemoteDataSourceRef = AutoDisposeProviderRef<TruckPinsRemoteDataSource>;
String _$truckPinsRepositoryHash() => r'4c8bd968315f92cbe56fd9f7dd03e2bf53f132f2';

/// See also [truckPinsRepository].
@ProviderFor(truckPinsRepository)
final truckPinsRepositoryProvider = AutoDisposeProvider<TruckPinsRepositoryImpl>.internal(
  truckPinsRepository,
  name: r'truckPinsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$truckPinsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TruckPinsRepositoryRef = AutoDisposeProviderRef<TruckPinsRepositoryImpl>;
String _$getTruckPinsUseCaseHash() => r'41eebd9146e63cf6b2b26dfdb0b4f6f8d1aa936a';

/// See also [getTruckPinsUseCase].
@ProviderFor(getTruckPinsUseCase)
final getTruckPinsUseCaseProvider = AutoDisposeProvider<GetTruckPinsUseCase>.internal(
  getTruckPinsUseCase,
  name: r'getTruckPinsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTruckPinsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetTruckPinsUseCaseRef = AutoDisposeProviderRef<GetTruckPinsUseCase>;
String _$getTruckPostDetailUseCaseHash() => r'9f8d136855c8c76839264a4aa9b80decd078e7e6';

/// See also [getTruckPostDetailUseCase].
@ProviderFor(getTruckPostDetailUseCase)
final getTruckPostDetailUseCaseProvider = AutoDisposeProvider<GetTruckPostDetailUseCase>.internal(
  getTruckPostDetailUseCase,
  name: r'getTruckPostDetailUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTruckPostDetailUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetTruckPostDetailUseCaseRef = AutoDisposeProviderRef<GetTruckPostDetailUseCase>;
String _$truckPinsNotifierHash() => r'd05e0b6a8de6fa78330011be3e77d4a988a3b52e';

/// Live truck pins for the part of the map on screen. Kept alive so leaving the
/// tab and coming back doesn't throw the pins away.
///
/// Copied from [TruckPinsNotifier].
@ProviderFor(TruckPinsNotifier)
final truckPinsNotifierProvider =
    NotifierProvider<TruckPinsNotifier, TruckPinsState>.internal(
      TruckPinsNotifier.new,
      name: r'truckPinsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$truckPinsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TruckPinsNotifier = Notifier<TruckPinsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
