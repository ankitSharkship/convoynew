// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeLocalDataSourceHash() =>
    r'c644a6e5545386de53b80ea935409c2b7406adaa';

/// See also [homeLocalDataSource].
@ProviderFor(homeLocalDataSource)
final homeLocalDataSourceProvider =
    AutoDisposeProvider<HomeLocalDataSource>.internal(
      homeLocalDataSource,
      name: r'homeLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeLocalDataSourceRef = AutoDisposeProviderRef<HomeLocalDataSource>;
String _$homeRepositoryHash() => r'c534e13ba4ebd3fa35e594ff4bab8fb48955723b';

/// See also [homeRepository].
@ProviderFor(homeRepository)
final homeRepositoryProvider = AutoDisposeProvider<HomeRepositoryImpl>.internal(
  homeRepository,
  name: r'homeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeRepositoryRef = AutoDisposeProviderRef<HomeRepositoryImpl>;
String _$getHomeDataUseCaseHash() =>
    r'442357ea88736bf83e82372299db75a1c1ea435d';

/// See also [getHomeDataUseCase].
@ProviderFor(getHomeDataUseCase)
final getHomeDataUseCaseProvider =
    AutoDisposeProvider<GetHomeDataUseCase>.internal(
      getHomeDataUseCase,
      name: r'getHomeDataUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getHomeDataUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetHomeDataUseCaseRef = AutoDisposeProviderRef<GetHomeDataUseCase>;
String _$homeNotifierHash() => r'cdfc92beb5b877dbcf5fa7dbbd106ec57baadf40';

/// See also [HomeNotifier].
@ProviderFor(HomeNotifier)
final homeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HomeNotifier, HomeDataEntity>.internal(
      HomeNotifier.new,
      name: r'homeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeNotifier = AutoDisposeAsyncNotifier<HomeDataEntity>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
