import '../entities/call_request_entity.dart';
import '../entities/call_session_entities.dart';

abstract class CallRequestRepository {
  /// Throws [CallRequestException] for rule violations (not enough balance, an
  /// open request already exists, ...) and [ApiException] for anything else.
  Future<CallRequestEntity> create({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  });

  Future<CallRequestEntity> get(String requestId);

  Future<CallRequestEntity> cancel(String requestId);

  /// The driver's queue, oldest first: requests waiting for their answer plus
  /// accepted ones. Requests past their 30-minute window are left out.
  Future<List<CallRequestEntity>> getIncoming();

  /// Driver says yes. Throws [CallRequestException] (e.g. REQUEST_EXPIRED,
  /// INVALID_STATE when the requester already cancelled).
  Future<CallRequestEntity> accept(String requestId);

  /// Driver says no: the requester's frozen money is released.
  Future<CallRequestEntity> reject(String requestId);

  /// The requester's own requests that are still open or waiting for their
  /// "were you satisfied?" answer, newest first.
  Future<List<CallRequestEntity>> getOutgoingActive();

  /// Driver starts the call: the requester's phone rings. Returns the driver's
  /// credentials. Asking again while still ringing returns the same ones.
  Future<CallJoinResult> start(String requestId);

  /// Requester answers the ring, or either side rejoins a live call after a
  /// drop. Throws [CallRequestException] with `RING_OVER` when too late.
  Future<CallJoinResult> join(String requestId);

  /// "I can / can't currently see the other person in the channel." The answer
  /// says what state the call is in; when it is no longer live, the call is over.
  Future<CallHeartbeatEntity> heartbeat(String requestId, bool peerPresent);

  /// Hang up (or, while ringing, cancel the ring / decline it).
  Future<CallRequestEntity> end(String requestId);

  /// The requester's "were you satisfied?" answer.
  Future<CallRequestEntity> submitFeedback(String requestId, bool satisfied);

  /// Reports behaviour events (never chat text) for the call.
  Future<void> sendEvents(String requestId, List<CallBehaviourEvent> events);
}
