// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reel_comments_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getReelCommentsUseCaseHash() => r'2b16a8ad983fb6451d98dfa797977467e4e08341';

/// See also [getReelCommentsUseCase].
@ProviderFor(getReelCommentsUseCase)
final getReelCommentsUseCaseProvider = AutoDisposeProvider<GetReelCommentsUseCase>.internal(
  getReelCommentsUseCase,
  name: r'getReelCommentsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getReelCommentsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetReelCommentsUseCaseRef = AutoDisposeProviderRef<GetReelCommentsUseCase>;
String _$addReelCommentUseCaseHash() => r'36618861eab2af36202b7aa47d8d58f2c6aae50e';

/// See also [addReelCommentUseCase].
@ProviderFor(addReelCommentUseCase)
final addReelCommentUseCaseProvider = AutoDisposeProvider<AddReelCommentUseCase>.internal(
  addReelCommentUseCase,
  name: r'addReelCommentUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addReelCommentUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddReelCommentUseCaseRef = AutoDisposeProviderRef<AddReelCommentUseCase>;
String _$deleteReelCommentUseCaseHash() => r'e3e7e1bea04271f7897b9d5eef07e28c573028fc';

/// See also [deleteReelCommentUseCase].
@ProviderFor(deleteReelCommentUseCase)
final deleteReelCommentUseCaseProvider = AutoDisposeProvider<DeleteReelCommentUseCase>.internal(
  deleteReelCommentUseCase,
  name: r'deleteReelCommentUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteReelCommentUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteReelCommentUseCaseRef = AutoDisposeProviderRef<DeleteReelCommentUseCase>;

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

String _$reelCommentsNotifierHash() => r'eb3ccc113f66ae883f2600855f8637a7db8f5792';

abstract class _$ReelCommentsNotifier extends BuildlessAutoDisposeNotifier<ReelCommentsState> {
  late final String reelId;

  ReelCommentsState build(String reelId);
}

/// See also [ReelCommentsNotifier].
@ProviderFor(ReelCommentsNotifier)
const reelCommentsNotifierProvider = ReelCommentsNotifierFamily();

/// See also [ReelCommentsNotifier].
class ReelCommentsNotifierFamily extends Family<ReelCommentsState> {
  /// See also [ReelCommentsNotifier].
  const ReelCommentsNotifierFamily();

  /// See also [ReelCommentsNotifier].
  ReelCommentsNotifierProvider call(String reelId) {
    return ReelCommentsNotifierProvider(reelId);
  }

  @override
  ReelCommentsNotifierProvider getProviderOverride(covariant ReelCommentsNotifierProvider provider) {
    return call(provider.reelId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reelCommentsNotifierProvider';
}

/// See also [ReelCommentsNotifier].
class ReelCommentsNotifierProvider
    extends AutoDisposeNotifierProviderImpl<ReelCommentsNotifier, ReelCommentsState> {
  /// See also [ReelCommentsNotifier].
  ReelCommentsNotifierProvider(String reelId)
    : this._internal(
        () => ReelCommentsNotifier()..reelId = reelId,
        from: reelCommentsNotifierProvider,
        name: r'reelCommentsNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reelCommentsNotifierHash,
        dependencies: ReelCommentsNotifierFamily._dependencies,
        allTransitiveDependencies: ReelCommentsNotifierFamily._allTransitiveDependencies,
        reelId: reelId,
      );

  ReelCommentsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reelId,
  }) : super.internal();

  final String reelId;

  @override
  ReelCommentsState runNotifierBuild(covariant ReelCommentsNotifier notifier) {
    return notifier.build(reelId);
  }

  @override
  Override overrideWith(ReelCommentsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReelCommentsNotifierProvider._internal(
        () => create()..reelId = reelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reelId: reelId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ReelCommentsNotifier, ReelCommentsState> createElement() {
    return _ReelCommentsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReelCommentsNotifierProvider && other.reelId == reelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReelCommentsNotifierRef on AutoDisposeNotifierProviderRef<ReelCommentsState> {
  /// The parameter `reelId` of this provider.
  String get reelId;
}

class _ReelCommentsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ReelCommentsNotifier, ReelCommentsState>
    with ReelCommentsNotifierRef {
  _ReelCommentsNotifierProviderElement(super.provider);

  @override
  String get reelId => (origin as ReelCommentsNotifierProvider).reelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
