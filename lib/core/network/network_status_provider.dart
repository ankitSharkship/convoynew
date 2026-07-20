import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_status_provider.g.dart';

enum NetworkStatus { unknown, online, offline }

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
@Riverpod(keepAlive: true)
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  @override
  NetworkStatus build() => NetworkStatus.unknown;

  void markOnline() {
    if (state != NetworkStatus.online) state = NetworkStatus.online;
  }

  void markOffline() {
    if (state != NetworkStatus.offline) state = NetworkStatus.offline;
  }
}
