// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heatmapRemoteDataSourceHash() => r'4ec1c93b1b808ed8d860990d479d9b0de4d6e86e';

/// See also [heatmapRemoteDataSource].
@ProviderFor(heatmapRemoteDataSource)
final heatmapRemoteDataSourceProvider = AutoDisposeProvider<HeatmapRemoteDataSource>.internal(
  heatmapRemoteDataSource,
  name: r'heatmapRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heatmapRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeatmapRemoteDataSourceRef = AutoDisposeProviderRef<HeatmapRemoteDataSource>;
String _$heatmapRepositoryHash() => r'3ea7f94caeab66875e1c78824ae0eb4653506a97';

/// See also [heatmapRepository].
@ProviderFor(heatmapRepository)
final heatmapRepositoryProvider = AutoDisposeProvider<HeatmapRepositoryImpl>.internal(
  heatmapRepository,
  name: r'heatmapRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$heatmapRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HeatmapRepositoryRef = AutoDisposeProviderRef<HeatmapRepositoryImpl>;
String _$getHeatmapUseCaseHash() => r'c872e6a8b23690629844416f11eabcd00fd55b4b';

/// See also [getHeatmapUseCase].
@ProviderFor(getHeatmapUseCase)
final getHeatmapUseCaseProvider = AutoDisposeProvider<GetHeatmapUseCase>.internal(
  getHeatmapUseCase,
  name: r'getHeatmapUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getHeatmapUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetHeatmapUseCaseRef = AutoDisposeProviderRef<GetHeatmapUseCase>;

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String _$heatmapNotifierHash() => r'f62c1a95f6c833de2db4d417f17699f0f84f08a4';

abstract class _$HeatmapNotifier extends BuildlessNotifier<HeatmapLayerState> {
  late final HeatmapKind kind;

  HeatmapLayerState build(HeatmapKind kind);
}

/// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
/// the screen) doesn't throw the fetched resolutions away.
///
/// Copied from [HeatmapNotifier].
@ProviderFor(HeatmapNotifier)
const heatmapNotifierProvider = HeatmapNotifierFamily();

/// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
/// the screen) doesn't throw the fetched resolutions away.
///
/// Copied from [HeatmapNotifier].
class HeatmapNotifierFamily extends Family<HeatmapLayerState> {
  /// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
  /// the screen) doesn't throw the fetched resolutions away.
  ///
  /// Copied from [HeatmapNotifier].
  const HeatmapNotifierFamily();

  /// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
  /// the screen) doesn't throw the fetched resolutions away.
  ///
  /// Copied from [HeatmapNotifier].
  HeatmapNotifierProvider call(HeatmapKind kind) {
    return HeatmapNotifierProvider(kind);
  }

  @override
  HeatmapNotifierProvider getProviderOverride(covariant HeatmapNotifierProvider provider) {
    return call(provider.kind);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'heatmapNotifierProvider';
}

/// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
/// the screen) doesn't throw the fetched resolutions away.
///
/// Copied from [HeatmapNotifier].
class HeatmapNotifierProvider extends NotifierProviderImpl<HeatmapNotifier, HeatmapLayerState> {
  /// One instance per [HeatmapKind], kept alive so switching tabs (or leaving
  /// the screen) doesn't throw the fetched resolutions away.
  ///
  /// Copied from [HeatmapNotifier].
  HeatmapNotifierProvider(HeatmapKind kind)
    : this._internal(
        () => HeatmapNotifier()..kind = kind,
        from: heatmapNotifierProvider,
        name: r'heatmapNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$heatmapNotifierHash,
        dependencies: HeatmapNotifierFamily._dependencies,
        allTransitiveDependencies: HeatmapNotifierFamily._allTransitiveDependencies,
        kind: kind,
      );

  HeatmapNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.kind,
  }) : super.internal();

  final HeatmapKind kind;

  @override
  HeatmapLayerState runNotifierBuild(covariant HeatmapNotifier notifier) {
    return notifier.build(kind);
  }

  @override
  Override overrideWith(HeatmapNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: HeatmapNotifierProvider._internal(
        () => create()..kind = kind,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        kind: kind,
      ),
    );
  }

  @override
  NotifierProviderElement<HeatmapNotifier, HeatmapLayerState> createElement() {
    return _HeatmapNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HeatmapNotifierProvider && other.kind == kind;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, kind.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HeatmapNotifierRef on NotifierProviderRef<HeatmapLayerState> {
  /// The parameter `kind` of this provider.
  HeatmapKind get kind;
}

class _HeatmapNotifierProviderElement
    extends NotifierProviderElement<HeatmapNotifier, HeatmapLayerState>
    with HeatmapNotifierRef {
  _HeatmapNotifierProviderElement(super.provider);

  @override
  HeatmapKind get kind => (origin as HeatmapNotifierProvider).kind;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
