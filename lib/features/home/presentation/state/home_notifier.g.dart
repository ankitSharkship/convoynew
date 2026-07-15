// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyRemoteDataSourceHash() =>
    r'e50b327454821f6573e4d6849761be5478afd1cf';

/// See also [historyRemoteDataSource].
@ProviderFor(historyRemoteDataSource)
final historyRemoteDataSourceProvider =
    AutoDisposeProvider<HistoryRemoteDataSource>.internal(
      historyRemoteDataSource,
      name: r'historyRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryRemoteDataSourceRef =
    AutoDisposeProviderRef<HistoryRemoteDataSource>;
String _$historyRepositoryHash() => r'e19a24a5e8d91622c204493e451a5b10652858e7';

/// See also [historyRepository].
@ProviderFor(historyRepository)
final historyRepositoryProvider =
    AutoDisposeProvider<HistoryRepositoryImpl>.internal(
      historyRepository,
      name: r'historyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryRepositoryRef = AutoDisposeProviderRef<HistoryRepositoryImpl>;
String _$getPostHistoryUseCaseHash() =>
    r'3c3ddf9be220bc8233a08511c1200e1a0033e4db';

/// See also [getPostHistoryUseCase].
@ProviderFor(getPostHistoryUseCase)
final getPostHistoryUseCaseProvider =
    AutoDisposeProvider<GetPostHistoryUseCase>.internal(
      getPostHistoryUseCase,
      name: r'getPostHistoryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getPostHistoryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPostHistoryUseCaseRef =
    AutoDisposeProviderRef<GetPostHistoryUseCase>;
String _$getSearchHistoryUseCaseHash() =>
    r'b5bc7469cf23024835dbf9783b53afad3f8fa2d2';

/// See also [getSearchHistoryUseCase].
@ProviderFor(getSearchHistoryUseCase)
final getSearchHistoryUseCaseProvider =
    AutoDisposeProvider<GetSearchHistoryUseCase>.internal(
      getSearchHistoryUseCase,
      name: r'getSearchHistoryUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getSearchHistoryUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSearchHistoryUseCaseRef =
    AutoDisposeProviderRef<GetSearchHistoryUseCase>;
String _$postHistoryNotifierHash() =>
    r'b6b72e27ec2e1bd83d504b37191a99bab1160090';

/// See also [PostHistoryNotifier].
@ProviderFor(PostHistoryNotifier)
final postHistoryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      PostHistoryNotifier,
      List<TripEntity>
    >.internal(
      PostHistoryNotifier.new,
      name: r'postHistoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postHistoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostHistoryNotifier = AutoDisposeAsyncNotifier<List<TripEntity>>;
String _$searchHistoryNotifierHash() =>
    r'b388c354325d5c8e1970422883c1cc709f818b24';

/// See also [SearchHistoryNotifier].
@ProviderFor(SearchHistoryNotifier)
final searchHistoryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SearchHistoryNotifier,
      List<SearchHistoryEntity>
    >.internal(
      SearchHistoryNotifier.new,
      name: r'searchHistoryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchHistoryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchHistoryNotifier =
    AutoDisposeAsyncNotifier<List<SearchHistoryEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
