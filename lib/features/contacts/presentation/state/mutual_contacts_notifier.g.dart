// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutual_contacts_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getMutualContactsUseCaseHash() =>
    r'008511b507e1da15d4c0ddb9aa31c7cc765615bb';

/// See also [getMutualContactsUseCase].
@ProviderFor(getMutualContactsUseCase)
final getMutualContactsUseCaseProvider =
    AutoDisposeProvider<GetMutualContactsUseCase>.internal(
      getMutualContactsUseCase,
      name: r'getMutualContactsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getMutualContactsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMutualContactsUseCaseRef =
    AutoDisposeProviderRef<GetMutualContactsUseCase>;
String _$mutualContactsHash() => r'08cbfd6f6a14d73c478d58a363fb6f42fd33ea95';

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

/// See also [mutualContacts].
@ProviderFor(mutualContacts)
const mutualContactsProvider = MutualContactsFamily();

/// See also [mutualContacts].
class MutualContactsFamily
    extends Family<AsyncValue<List<MutualContactEntity>>> {
  /// See also [mutualContacts].
  const MutualContactsFamily();

  /// See also [mutualContacts].
  MutualContactsProvider call({required String otherUserId}) {
    return MutualContactsProvider(otherUserId: otherUserId);
  }

  @override
  MutualContactsProvider getProviderOverride(
    covariant MutualContactsProvider provider,
  ) {
    return call(otherUserId: provider.otherUserId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mutualContactsProvider';
}

/// See also [mutualContacts].
class MutualContactsProvider
    extends AutoDisposeFutureProvider<List<MutualContactEntity>> {
  /// See also [mutualContacts].
  MutualContactsProvider({required String otherUserId})
    : this._internal(
        (ref) =>
            mutualContacts(ref as MutualContactsRef, otherUserId: otherUserId),
        from: mutualContactsProvider,
        name: r'mutualContactsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mutualContactsHash,
        dependencies: MutualContactsFamily._dependencies,
        allTransitiveDependencies:
            MutualContactsFamily._allTransitiveDependencies,
        otherUserId: otherUserId,
      );

  MutualContactsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.otherUserId,
  }) : super.internal();

  final String otherUserId;

  @override
  Override overrideWith(
    FutureOr<List<MutualContactEntity>> Function(MutualContactsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MutualContactsProvider._internal(
        (ref) => create(ref as MutualContactsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MutualContactEntity>> createElement() {
    return _MutualContactsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MutualContactsProvider && other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MutualContactsRef
    on AutoDisposeFutureProviderRef<List<MutualContactEntity>> {
  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _MutualContactsProviderElement
    extends AutoDisposeFutureProviderElement<List<MutualContactEntity>>
    with MutualContactsRef {
  _MutualContactsProviderElement(super.provider);

  @override
  String get otherUserId => (origin as MutualContactsProvider).otherUserId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
