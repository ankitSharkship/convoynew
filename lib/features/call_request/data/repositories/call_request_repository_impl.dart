import '../../domain/entities/call_request_entity.dart';
import '../../domain/entities/call_session_entities.dart';
import '../../domain/repositories/call_request_repository.dart';
import '../datasources/call_request_remote_datasource.dart';

class CallRequestRepositoryImpl implements CallRequestRepository {
  final CallRequestRemoteDataSource _remote;

  CallRequestRepositoryImpl(this._remote);

  @override
  Future<CallRequestEntity> create({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) => _remote.create(
    providerId: providerId,
    truckRouteId: truckRouteId,
    topic: topic,
    durationMinutes: durationMinutes,
    amountRupees: amountRupees,
  );

  @override
  Future<CallRequestEntity> get(String requestId) => _remote.get(requestId);

  @override
  Future<CallRequestEntity> cancel(String requestId) =>
      _remote.cancel(requestId);

  @override
  Future<List<CallRequestEntity>> getIncoming() => _remote.getIncoming();

  @override
  Future<CallRequestEntity> accept(String requestId) =>
      _remote.accept(requestId);

  @override
  Future<CallRequestEntity> reject(String requestId) =>
      _remote.reject(requestId);

  @override
  Future<List<CallRequestEntity>> getOutgoingActive() =>
      _remote.getOutgoingActive();

  @override
  Future<CallJoinResult> start(String requestId) => _remote.start(requestId);

  @override
  Future<CallJoinResult> join(String requestId) => _remote.join(requestId);

  @override
  Future<CallHeartbeatEntity> heartbeat(String requestId, bool peerPresent) =>
      _remote.heartbeat(requestId, peerPresent);

  @override
  Future<CallRequestEntity> end(String requestId) => _remote.end(requestId);

  @override
  Future<CallRequestEntity> submitFeedback(String requestId, bool satisfied) =>
      _remote.submitFeedback(requestId, satisfied);

  @override
  Future<void> sendEvents(String requestId, List<CallBehaviourEvent> events) =>
      _remote.sendEvents(requestId, events);
}
