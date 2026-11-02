/// Where a call request is in its life. Strings, exactly as the server sends
/// them (docs/ONE_TO_ONE_CALL_API.md "Status flow").
class CallStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const ringing = 'ringing';
  static const live = 'live';
  static const awaitingFeedback = 'awaiting_feedback';
  static const completed = 'completed';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';
  static const expired = 'expired';
  static const failed = 'failed';

  /// Statuses the requester can still withdraw the request from.
  static const cancellable = {pending, accepted};

  /// Statuses in which the request is still going, so a screen watching it
  /// should keep refreshing.
  static const inProgress = {pending, accepted, ringing, live};
}

class CallPartyEntity {
  final String id;
  final String? name;
  final String? photo;

  const CallPartyEntity({required this.id, this.name, this.photo});
}

class CallRequestEntity {
  final String id;

  /// The caller's side: 'requester' or 'provider'.
  final String role;
  final String status;
  final String topic;
  final int durationMinutes;

  /// Rupee amounts as the server's decimal strings ("150.00").
  final String amount;
  final String holdAmount;
  final CallPartyEntity requester;
  final CallPartyEntity provider;
  final String? truckRouteId;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? callStartedAt;

  /// While [CallStatus.ringing]: when the 45 s ring stops.
  final DateTime? ringEndsAt;
  final DateTime? callEndedAt;
  final int? connectedSeconds;
  final DateTime? feedbackDeadline;
  final bool? satisfied;
  final String? settledAmount;

  const CallRequestEntity({
    required this.id,
    required this.role,
    required this.status,
    required this.topic,
    required this.durationMinutes,
    required this.amount,
    required this.holdAmount,
    required this.requester,
    required this.provider,
    required this.expiresAt,
    required this.createdAt,
    this.truckRouteId,
    this.respondedAt,
    this.callStartedAt,
    this.ringEndsAt,
    this.callEndedAt,
    this.connectedSeconds,
    this.feedbackDeadline,
    this.satisfied,
    this.settledAmount,
  });

  bool get isRequester => role == 'requester';
  bool get isProvider => !isRequester;
  bool get isInProgress => CallStatus.inProgress.contains(status);
  bool get canCancel => isRequester && CallStatus.cancellable.contains(status);

  /// The person on the other end, from the caller's point of view.
  CallPartyEntity get otherParty => isRequester ? provider : requester;

  /// The same request in another [status] (used when the server no longer lists
  /// it as open and the screen needs to say what became of it).
  CallRequestEntity copyWithStatus(String status) => CallRequestEntity(
    id: id,
    role: role,
    status: status,
    topic: topic,
    durationMinutes: durationMinutes,
    amount: amount,
    holdAmount: holdAmount,
    requester: requester,
    provider: provider,
    expiresAt: expiresAt,
    createdAt: createdAt,
    truckRouteId: truckRouteId,
    respondedAt: respondedAt,
    callStartedAt: callStartedAt,
    ringEndsAt: ringEndsAt,
    callEndedAt: callEndedAt,
    connectedSeconds: connectedSeconds,
    feedbackDeadline: feedbackDeadline,
    satisfied: satisfied,
    settledAmount: settledAmount,
  );
}
