import 'call_request_entity.dart';

/// What the app needs to join a call's Agora channel (the `call` object of
/// `/start` and `/join`, docs/ONE_TO_ONE_CALL_API.md). Minted per request by the
/// server; the app never stores it.
class CallCredentialsEntity {
  final String requestId;

  /// The caller's side: 'requester' or 'provider'.
  final String role;
  final String appId;
  final String channelName;
  final int uid;
  final String rtcToken;
  final DateTime tokenExpiresAt;

  /// The chosen call length. The token itself stops working at the end of it.
  final int durationSeconds;

  /// True for the requester: publish the microphone only, never a camera.
  final bool audioOnly;

  /// While ringing: when the ring stops.
  final DateTime? ringEndsAt;

  const CallCredentialsEntity({
    required this.requestId,
    required this.role,
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.rtcToken,
    required this.tokenExpiresAt,
    required this.durationSeconds,
    required this.audioOnly,
    this.ringEndsAt,
  });
}

/// A request together with the credentials that came with `/start` or `/join`.
class CallJoinResult {
  final CallRequestEntity request;
  final CallCredentialsEntity credentials;

  const CallJoinResult({required this.request, required this.credentials});
}

/// The server's answer to a heartbeat: the state the call screen should show.
/// [status] is a [CallStatus]; when it is no longer `live` the call is over.
class CallHeartbeatEntity {
  final String status;
  final int connectedSeconds;
  final int remainingSeconds;

  /// How long the call must have really connected before it counts (30 s).
  final int thresholdSeconds;

  /// Whether the server has heard from the other side recently.
  final bool peerOnline;

  const CallHeartbeatEntity({
    required this.status,
    required this.connectedSeconds,
    required this.remainingSeconds,
    required this.thresholdSeconds,
    this.peerOnline = false,
  });
}

/// One thing a person did on the call screen, reported for the behaviour log.
/// Never carries chat text.
class CallBehaviourEvent {
  final String type;
  final DateTime occurredAt;
  final Map<String, Object?>? details;

  const CallBehaviourEvent({
    required this.type,
    required this.occurredAt,
    this.details,
  });
}

/// The event types the server accepts (the allowed list in
/// docs/ONE_TO_ONE_CALL_API.md). Anything else is refused by the server.
class CallEventType {
  static const requestViewed = 'request_viewed';
  static const callScreenOpened = 'call_screen_opened';
  static const ringAnswered = 'ring_answered';
  static const ringDeclined = 'ring_declined';
  static const callJoined = 'call_joined';
  static const callLeft = 'call_left';
  static const callCut = 'call_cut';
  static const micOn = 'mic_on';
  static const micOff = 'mic_off';
  static const cameraOn = 'camera_on';
  static const cameraOff = 'camera_off';
  static const cameraSwitched = 'camera_switched';
  static const speakerOn = 'speaker_on';
  static const speakerOff = 'speaker_off';
  static const chatOpened = 'chat_opened';
  static const chatClosed = 'chat_closed';
  static const chatMessageSent = 'chat_message_sent';
  static const reconnectOffered = 'reconnect_offered';
  static const reconnectAccepted = 'reconnect_accepted';
  static const reconnectDeclined = 'reconnect_declined';
  static const networkLost = 'network_lost';
  static const networkRestored = 'network_restored';
  static const appBackgrounded = 'app_backgrounded';
  static const appForegrounded = 'app_foregrounded';
  static const mediaDiagnostic = 'media_diagnostic';

  /// The ones that tell the story of a call (when it began and ended). They are
  /// always sent; the many small toggles (mic, camera, chat ...) stop being
  /// recorded once the per-call limit is nearly reached.
  static const essential = {
    callScreenOpened,
    ringAnswered,
    ringDeclined,
    callJoined,
    callLeft,
    callCut,
    reconnectOffered,
    reconnectAccepted,
    reconnectDeclined,
    mediaDiagnostic,
  };
}
