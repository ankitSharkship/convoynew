import '../../domain/entities/call_request_entity.dart';

DateTime? parseServerTime(Object? value) =>
    value == null ? null : parseServerUtc(value as String);

/// The server sends UTC timestamps, some without a trailing "Z". Always read
/// them as UTC so countdowns are right whatever the phone's time zone is.
DateTime parseServerUtc(String value) {
  final hasZone =
      value.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(value);
  return DateTime.parse(hasZone ? value : '${value}Z');
}

CallPartyEntity _party(Map<String, dynamic> json) => CallPartyEntity(
  id: json['id'] as String,
  name: json['name'] as String?,
  photo: json['photo'] as String?,
);

class CallRequestModel extends CallRequestEntity {
  const CallRequestModel({
    required super.id,
    required super.role,
    required super.status,
    required super.topic,
    required super.durationMinutes,
    required super.amount,
    required super.holdAmount,
    required super.requester,
    required super.provider,
    required super.expiresAt,
    required super.createdAt,
    super.truckRouteId,
    super.respondedAt,
    super.callStartedAt,
    super.ringEndsAt,
    super.callEndedAt,
    super.connectedSeconds,
    super.feedbackDeadline,
    super.satisfied,
    super.settledAmount,
  });

  factory CallRequestModel.fromJson(Map<String, dynamic> json) =>
      CallRequestModel(
        id: json['id'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
        topic: json['topic'] as String,
        durationMinutes: json['durationMinutes'] as int,
        amount: json['amount'] as String,
        holdAmount: json['holdAmount'] as String,
        requester: _party(json['requester'] as Map<String, dynamic>),
        provider: _party(json['provider'] as Map<String, dynamic>),
        truckRouteId: json['truckRouteId'] as String?,
        expiresAt: parseServerUtc(json['expiresAt'] as String),
        createdAt: parseServerUtc(json['createdAt'] as String),
        respondedAt: parseServerTime(json['respondedAt']),
        callStartedAt: parseServerTime(json['callStartedAt']),
        ringEndsAt: parseServerTime(json['ringEndsAt']),
        callEndedAt: parseServerTime(json['callEndedAt']),
        connectedSeconds: json['connectedSeconds'] as int?,
        feedbackDeadline: parseServerTime(json['feedbackDeadline']),
        satisfied: json['satisfied'] as bool?,
        settledAmount: json['settledAmount'] as String?,
      );
}
