// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$networkStatusNotifierHash() =>
    r'63ae18264480e7c759857211cfb11c31e4b6e8ba';

/// Tracks whether the app's most recent API traffic actually reached the
/// network. This is a *reactive* signal — it's flipped to [NetworkStatus
/// .offline]/[NetworkStatus.online] directly by the shared Dio client's
/// interceptor (see `dio_client.dart`) every time a request fails or
/// succeeds, using the same connectivity classification as
/// [ApiException.isConnectivityError]. It does not poll the OS for
/// connectivity state.
///
/// Marked `keepAlive` — unlike every other provider in this app — because
/// it must persist for the whole app session so a global "offline" banner
/// (see `shared/widgets/offline_banner.dart`) always reflects the true
/// current state, even when no screen happens to be watching it at the
/// moment a request fails.
///
/// Copied from [NetworkStatusNotifier].
@ProviderFor(NetworkStatusNotifier)
final networkStatusNotifierProvider =
    NotifierProvider<NetworkStatusNotifier, NetworkStatus>.internal(
      NetworkStatusNotifier.new,
      name: r'networkStatusNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkStatusNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NetworkStatusNotifier = Notifier<NetworkStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
