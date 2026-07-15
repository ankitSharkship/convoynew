// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripRemoteDataSourceHash() =>
    r'63b9357369662abf3d5488416fd60b6105fcd443';

/// See also [tripRemoteDataSource].
@ProviderFor(tripRemoteDataSource)
final tripRemoteDataSourceProvider =
    AutoDisposeProvider<TripRemoteDataSource>.internal(
      tripRemoteDataSource,
      name: r'tripRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripRemoteDataSourceRef = AutoDisposeProviderRef<TripRemoteDataSource>;
String _$tripRepositoryHash() => r'bd9f8a2c81508522e71bdafea0f75cb36183f933';

/// See also [tripRepository].
@ProviderFor(tripRepository)
final tripRepositoryProvider = AutoDisposeProvider<TripRepositoryImpl>.internal(
  tripRepository,
  name: r'tripRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripRepositoryRef = AutoDisposeProviderRef<TripRepositoryImpl>;
String _$getMyTripsUseCaseHash() => r'25d7ea3e047c049126dca169d8611d734ad3b589';

/// See also [getMyTripsUseCase].
@ProviderFor(getMyTripsUseCase)
final getMyTripsUseCaseProvider =
    AutoDisposeProvider<GetMyTripsUseCase>.internal(
      getMyTripsUseCase,
      name: r'getMyTripsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getMyTripsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMyTripsUseCaseRef = AutoDisposeProviderRef<GetMyTripsUseCase>;
String _$reactivateTripUseCaseHash() =>
    r'cf5108ebcebcc968deacfb8a93026faaea5a1eae';

/// See also [reactivateTripUseCase].
@ProviderFor(reactivateTripUseCase)
final reactivateTripUseCaseProvider =
    AutoDisposeProvider<ReactivateTripUseCase>.internal(
      reactivateTripUseCase,
      name: r'reactivateTripUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reactivateTripUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReactivateTripUseCaseRef =
    AutoDisposeProviderRef<ReactivateTripUseCase>;
String _$deleteTripUseCaseHash() => r'7080d5dac9cb7ba9b6ccf0feb033d93c9f1d00ba';

/// See also [deleteTripUseCase].
@ProviderFor(deleteTripUseCase)
final deleteTripUseCaseProvider =
    AutoDisposeProvider<DeleteTripUseCase>.internal(
      deleteTripUseCase,
      name: r'deleteTripUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deleteTripUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteTripUseCaseRef = AutoDisposeProviderRef<DeleteTripUseCase>;
String _$tripsNotifierHash() => r'a3516e4a1d97aaec5d458ab7841af337eebab256';

/// See also [TripsNotifier].
@ProviderFor(TripsNotifier)
final tripsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TripsNotifier, List<TripEntity>>.internal(
      TripsNotifier.new,
      name: r'tripsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TripsNotifier = AutoDisposeAsyncNotifier<List<TripEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
