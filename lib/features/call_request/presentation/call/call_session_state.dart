import '../../domain/entities/call_request_entity.dart';

/// Where the call screen is in the life of the call.
enum CallPhase {
  /// Asking for permissions, getting credentials, joining the channel.
  starting,

  /// Driver: the requester's phone is ringing.
  ringing,

  /// The call is on. (Whether it is being counted depends on both people
  /// really being in the channel; see [CallSessionState.peerPresent].)
  live,

  /// Over. See [CallSessionState.endStatus].
  ended,

  /// Could not start. See [CallSessionState.failure].
  failed,
}

/// Why a call could not start.
enum CallFailureKind {
  microphoneDenied,
  microphoneBlocked,
  cameraDenied,
  cameraBlocked,

  /// The server refused (the request ran out, the ring was over, ...). The
  /// [CallFailure.message] is the server's plain-language reason.
  server,

  /// Another of this person's phones is on this call (answered it, or took it over).
  onAnotherDevice,

  /// The phone could not start the audio/video.
  media,

  /// No connection to the server.
  network,
}

class CallFailure {
  final CallFailureKind kind;
  final String message;
  final String? code;

  const CallFailure(this.kind, this.message, {this.code});

  bool get isPermission =>
      kind == CallFailureKind.microphoneDenied ||
      kind == CallFailureKind.microphoneBlocked ||
      kind == CallFailureKind.cameraDenied ||
      kind == CallFailureKind.cameraBlocked;

  /// The user has to switch the permission on in the phone's settings.
  bool get needsSettings =>
      kind == CallFailureKind.microphoneBlocked ||
      kind == CallFailureKind.cameraBlocked;
}

class CallChatMessage {
  final String text;
  final bool mine;
  final DateTime at;

  const CallChatMessage({
    required this.text,
    required this.mine,
    required this.at,
  });
}

class CallSessionState {
  final CallPhase phase;
  final CallRequestEntity? request;

  /// This phone is in the media channel, so the video views can be shown.
  final bool mediaReady;

  /// The other person is in the media channel right now.
  final bool peerPresent;

  /// They have been in the channel at some point on this call (so being absent
  /// now means they dropped out, rather than that they never arrived).
  final bool peerEverJoined;
  final int? peerUid;

  /// The other person's camera is showing.
  final bool peerVideo;

  /// This phone lost the connection to the call.
  final bool connectionLost;

  /// The server could not be reached for a while (heartbeats failing).
  final bool serverUnreachable;

  final int connectedSeconds;
  final int remainingSeconds;

  /// When [remainingSeconds] was true, so the screen can count down between
  /// heartbeats.
  final DateTime? remainingAsOf;
  final int thresholdSeconds;
  final DateTime? ringEndsAt;

  final bool micMuted;
  final bool cameraOff;
  final bool speakerOn;

  final List<CallChatMessage> chat;
  final int unreadChat;

  /// The server's final word on the call, once it is [CallPhase.ended]: a
  /// [CallStatus] (`awaiting_feedback`, `failed`, `accepted` = nobody answered,
  /// `cancelled` = declined, ...).
  final String? endStatus;

  /// The request as it stood when the call ended (amounts, connected time),
  /// if it could be loaded.
  final CallRequestEntity? endedRequest;

  /// We hung up but could not tell the server; it settles the call by itself
  /// once it stops hearing from this phone.
  final bool endUnconfirmed;

  final CallFailure? failure;

  const CallSessionState({
    this.phase = CallPhase.starting,
    this.request,
    this.mediaReady = false,
    this.peerPresent = false,
    this.peerEverJoined = false,
    this.peerUid,
    this.peerVideo = false,
    this.connectionLost = false,
    this.serverUnreachable = false,
    this.connectedSeconds = 0,
    this.remainingSeconds = 0,
    this.remainingAsOf,
    this.thresholdSeconds = 30,
    this.ringEndsAt,
    this.micMuted = false,
    this.cameraOff = false,
    this.speakerOn = true,
    this.chat = const [],
    this.unreadChat = 0,
    this.endStatus,
    this.endedRequest,
    this.endUnconfirmed = false,
    this.failure,
  });

  bool get isActive => phase == CallPhase.ringing || phase == CallPhase.live;
  bool get isOver => phase == CallPhase.ended || phase == CallPhase.failed;

  /// The call has really connected for long enough to count.
  bool get counted => connectedSeconds >= thresholdSeconds;

  CallSessionState copyWith({
    CallPhase? phase,
    CallRequestEntity? request,
    bool? mediaReady,
    bool? peerPresent,
    bool? peerEverJoined,
    int? peerUid,
    bool clearPeerUid = false,
    bool? peerVideo,
    bool? connectionLost,
    bool? serverUnreachable,
    int? connectedSeconds,
    int? remainingSeconds,
    DateTime? remainingAsOf,
    int? thresholdSeconds,
    DateTime? ringEndsAt,
    bool? micMuted,
    bool? cameraOff,
    bool? speakerOn,
    List<CallChatMessage>? chat,
    int? unreadChat,
    String? endStatus,
    CallRequestEntity? endedRequest,
    bool? endUnconfirmed,
    CallFailure? failure,
  }) => CallSessionState(
    phase: phase ?? this.phase,
    request: request ?? this.request,
    mediaReady: mediaReady ?? this.mediaReady,
    peerPresent: peerPresent ?? this.peerPresent,
    peerEverJoined: peerEverJoined ?? this.peerEverJoined,
    peerUid: clearPeerUid ? null : (peerUid ?? this.peerUid),
    peerVideo: peerVideo ?? this.peerVideo,
    connectionLost: connectionLost ?? this.connectionLost,
    serverUnreachable: serverUnreachable ?? this.serverUnreachable,
    connectedSeconds: connectedSeconds ?? this.connectedSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    remainingAsOf: remainingAsOf ?? this.remainingAsOf,
    thresholdSeconds: thresholdSeconds ?? this.thresholdSeconds,
    ringEndsAt: ringEndsAt ?? this.ringEndsAt,
    micMuted: micMuted ?? this.micMuted,
    cameraOff: cameraOff ?? this.cameraOff,
    speakerOn: speakerOn ?? this.speakerOn,
    chat: chat ?? this.chat,
    unreadChat: unreadChat ?? this.unreadChat,
    endStatus: endStatus ?? this.endStatus,
    endedRequest: endedRequest ?? this.endedRequest,
    endUnconfirmed: endUnconfirmed ?? this.endUnconfirmed,
    failure: failure ?? this.failure,
  );
}
