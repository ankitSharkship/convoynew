import '../../domain/entities/call_session_entities.dart';
import 'call_request_model.dart';

CallCredentialsEntity callCredentialsFromJson(Map<String, dynamic> json) =>
    CallCredentialsEntity(
      requestId: json['requestId'] as String,
      role: json['role'] as String,
      appId: json['appId'] as String,
      channelName: json['channelName'] as String,
      uid: (json['uid'] as num).toInt(),
      rtcToken: json['rtcToken'] as String,
      tokenExpiresAt: parseServerUtc(json['tokenExpiresAt'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      audioOnly: json['audioOnly'] as bool? ?? false,
      ringEndsAt: parseServerTime(json['ringEndsAt']),
    );

/// The body of `/start` and `/join`: the usual `request` plus a `call` object.
CallJoinResult callJoinResultFromJson(Map<String, dynamic> json) =>
    CallJoinResult(
      request: CallRequestModel.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
      credentials: callCredentialsFromJson(json['call'] as Map<String, dynamic>),
    );

CallHeartbeatEntity callHeartbeatFromJson(Map<String, dynamic> json) =>
    CallHeartbeatEntity(
      status: json['status'] as String,
      connectedSeconds: (json['connectedSeconds'] as num?)?.toInt() ?? 0,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      thresholdSeconds: (json['thresholdSeconds'] as num?)?.toInt() ?? 30,
      peerOnline: json['peerOnline'] as bool? ?? false,
    );

Map<String, Object?> callEventToJson(CallBehaviourEvent event) => {
  'type': event.type,
  'occurredAt': event.occurredAt.toUtc().toIso8601String(),
  if (event.details != null) 'details': event.details,
};

