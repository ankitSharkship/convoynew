import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/push_events_service.dart';
import '../../data/datasources/call_request_remote_datasource.dart';
import '../../data/repositories/call_request_repository_impl.dart';
import '../../domain/entities/call_request_entity.dart';
import '../../domain/usecases/call_request_usecases.dart';
import 'outgoing_requests_notifier.dart';

part 'call_request_notifier.g.dart';

/// How often a screen watching a request asks the server how it is doing, while
/// the request is still going (the driver may accept at any moment).
const callRequestPollInterval = Duration(seconds: 5);

@riverpod
CallRequestRemoteDataSource callRequestRemoteDataSource(
  CallRequestRemoteDataSourceRef ref,
) {
  return CallRequestRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
CallRequestRepositoryImpl callRequestRepository(CallRequestRepositoryRef ref) {
  return CallRequestRepositoryImpl(
    ref.watch(callRequestRemoteDataSourceProvider),
  );
}

@riverpod
CreateCallRequestUseCase createCallRequestUseCase(
  CreateCallRequestUseCaseRef ref,
) {
  return CreateCallRequestUseCase(ref.watch(callRequestRepositoryProvider));
}

@riverpod
GetCallRequestUseCase getCallRequestUseCase(GetCallRequestUseCaseRef ref) {
  return GetCallRequestUseCase(ref.watch(callRequestRepositoryProvider));
}

@riverpod
CancelCallRequestUseCase cancelCallRequestUseCase(
  CancelCallRequestUseCaseRef ref,
) {
  return CancelCallRequestUseCase(ref.watch(callRequestRepositoryProvider));
}

@riverpod
GetIncomingCallRequestsUseCase getIncomingCallRequestsUseCase(
  GetIncomingCallRequestsUseCaseRef ref,
) {
  return GetIncomingCallRequestsUseCase(
    ref.watch(callRequestRepositoryProvider),
  );
}

@riverpod
AcceptCallRequestUseCase acceptCallRequestUseCase(
  AcceptCallRequestUseCaseRef ref,
) {
  return AcceptCallRequestUseCase(ref.watch(callRequestRepositoryProvider));
}

@riverpod
RejectCallRequestUseCase rejectCallRequestUseCase(
  RejectCallRequestUseCaseRef ref,
) {
  return RejectCallRequestUseCase(ref.watch(callRequestRepositoryProvider));
}

@riverpod
PushEventsSource pushEventsSource(PushEventsSourceRef ref) {
  return FirebasePushEventsSource(FirebaseMessaging.instance);
}

/// The signed-in user's id (null when signed out).
@riverpod
Future<String?> currentUserId(CurrentUserIdRef ref) {
  return ref.read(tokenStorageProvider).getUserId();
}

/// Sends a new 1:1 request. Holds no state: [submit] throws on failure
/// ([CallRequestException] for a rule the server refused, [ApiException]
/// otherwise) and the form sheet shows the message, like the wallet's redeem.
@riverpod
class CallRequestComposer extends _$CallRequestComposer {
  @override
  void build() {}

  Future<CallRequestEntity> submit({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) {
    return ref
        .read(createCallRequestUseCaseProvider)
        .execute(
          providerId: providerId,
          truckRouteId: truckRouteId,
          topic: topic,
          durationMinutes: durationMinutes,
          amountRupees: amountRupees,
        );
  }
}

/// One request, kept fresh while it is still going. The first load failing
/// shows as an error state; a failed refresh later just keeps the last known
/// state and tries again, so a brief network blip doesn't blank the sheet.
@riverpod
class CallRequestNotifier extends _$CallRequestNotifier {
  Timer? _timer;
  bool _disposed = false;

  @override
  Future<CallRequestEntity> build(String requestId) async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    final request = await ref
        .watch(getCallRequestUseCaseProvider)
        .execute(requestId);
    _scheduleNextPoll(request);
    return request;
  }

  void _scheduleNextPoll(CallRequestEntity request) {
    _timer?.cancel();
    if (_disposed || !request.isInProgress) return;
    _timer = Timer(callRequestPollInterval, _poll);
  }

  Future<void> _poll() async {
    try {
      final request = await ref
          .read(getCallRequestUseCaseProvider)
          .execute(requestId);
      if (_disposed) return;
      state = AsyncData(request);
      _scheduleNextPoll(request);
    } catch (_) {
      if (_disposed) return;
      final last = state.valueOrNull;
      if (last != null) _scheduleNextPoll(last);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Withdraws the request (only while pending or accepted). Throws
  /// [CallRequestException] / [ApiException]; the sheet shows the message.
  Future<void> cancel() async {
    final request = await ref
        .read(cancelCallRequestUseCaseProvider)
        .execute(requestId);
    if (_disposed) return;
    state = AsyncData(request);
    _scheduleNextPoll(request);
  }

  /// Driver says yes. Throws [CallRequestException] / [ApiException]; the
  /// sheet shows the message. Also refreshes the driver's queue.
  Future<void> accept() async {
    final request = await ref
        .read(acceptCallRequestUseCaseProvider)
        .execute(requestId);
    if (_disposed) return;
    state = AsyncData(request);
    _scheduleNextPoll(request);
    ref.invalidate(incomingCallRequestsNotifierProvider);
  }

  /// Driver says no (the requester's money is released). Same error handling
  /// as [accept].
  Future<void> reject() async {
    final request = await ref
        .read(rejectCallRequestUseCaseProvider)
        .execute(requestId);
    if (_disposed) return;
    state = AsyncData(request);
    _scheduleNextPoll(request);
    ref.invalidate(incomingCallRequestsNotifierProvider);
  }
}

/// How often the driver's queue is refreshed while Home is on screen (a push
/// refreshes it immediately; this is the safety net when a push doesn't arrive).
const incomingPollInterval = Duration(seconds: 20);

/// The driver's queue of 1:1 requests, oldest first. Kept fresh while something
/// is watching it; stops asking as soon as nothing is (the Home banner only
/// watches while the Home tab is visible).
@riverpod
class IncomingCallRequestsNotifier extends _$IncomingCallRequestsNotifier {
  Timer? _timer;
  bool _disposed = false;

  @override
  Future<List<CallRequestEntity>> build() async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    try {
      return await ref.watch(getIncomingCallRequestsUseCaseProvider).execute();
    } finally {
      _scheduleNextPoll();
    }
  }

  void _scheduleNextPoll() {
    _timer?.cancel();
    if (_disposed) return;
    _timer = Timer(incomingPollInterval, _poll);
  }

  Future<void> _poll() async {
    try {
      final list = await ref
          .read(getIncomingCallRequestsUseCaseProvider)
          .execute();
      if (_disposed) return;
      state = AsyncData(list);
    } catch (_) {
      // A failed refresh keeps the last queue; the next tick tries again.
    }
    _scheduleNextPoll();
  }
}

/// "Open this request's review sheet": set by a tapped push, consumed (and
/// cleared) by the Home banner once Home is on screen.
@Riverpod(keepAlive: true)
class PendingReviewRequest extends _$PendingReviewRequest {
  @override
  String? build() => null;

  void open(String requestId) => state = requestId;

  void clear() => state = null;
}

/// Kept alive for the app's whole lifetime (watched once from [App]) so a push
/// about a call is never missed: while the app is open it refreshes what is on
/// screen; a tapped "new request" push opens that request for review.
@Riverpod(keepAlive: true)
class CallPushListener extends _$CallPushListener {
  bool _disposed = false;

  @override
  void build() {
    _disposed = false;
    final source = ref.watch(pushEventsSourceProvider);
    final subscriptions = [
      source.whileOpen.listen(_refreshFor),
      source.tapped.listen(_onTapped),
    ];
    source.launchedFrom().then((event) {
      if (event != null && !_disposed) _onTapped(event);
    });
    ref.onDispose(() {
      _disposed = true;
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
  }

  void _refreshFor(PushEvent event) {
    ref.invalidate(incomingCallRequestsNotifierProvider);
    // The requester's own requests: a ring or a "how was it?" may be waiting.
    ref.invalidate(outgoingActiveRequestsProvider);
    final id = event.requestId;
    if (id != null) ref.invalidate(callRequestNotifierProvider(id));
  }

  void _onTapped(PushEvent event) {
    _refreshFor(event);
    final id = event.requestId;
    if (event.isNewIncomingRequest && id != null) {
      ref.read(pendingReviewRequestProvider.notifier).open(id);
    }
  }
}
