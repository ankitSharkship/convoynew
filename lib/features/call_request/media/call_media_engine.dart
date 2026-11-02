import 'package:flutter/widgets.dart';

import '../domain/entities/call_session_entities.dart';

/// Something that happened in the call's media channel. The call controller
/// reacts to these; it never touches the Agora SDK itself, so its logic (who is
/// present, when to reconnect, what to report) is testable without a phone.
sealed class CallMediaEvent {
  const CallMediaEvent();
}

/// This phone is in the channel.
class MediaJoined extends CallMediaEvent {
  const MediaJoined();
}

/// The other person's media arrived in the channel / left it.
class MediaPeerJoined extends CallMediaEvent {
  final int uid;
  const MediaPeerJoined(this.uid);
}

class MediaPeerLeft extends CallMediaEvent {
  final int uid;
  const MediaPeerLeft(this.uid);
}

/// Whether the other person's camera is currently showing.
class MediaPeerVideo extends CallMediaEvent {
  final int uid;
  final bool showing;
  const MediaPeerVideo(this.uid, {required this.showing});
}

/// This phone lost the connection to Agora / got it back.
class MediaConnectionLost extends CallMediaEvent {
  const MediaConnectionLost();
}

class MediaConnectionRestored extends CallMediaEvent {
  const MediaConnectionRestored();
}

/// A chat message from the other person.
class MediaChatReceived extends CallMediaEvent {
  final String text;
  const MediaChatReceived(this.text);
}

/// The media layer gave up (for example the connection failed for good).
class MediaFailed extends CallMediaEvent {
  final String reason;
  const MediaFailed(this.reason);
}

/// A note on how the audio/video setup is going (a step finished, an SDK error
/// code ...). Only for logs and the call's diagnostics; the call never reacts to it.
class MediaDiag extends CallMediaEvent {
  final String message;
  const MediaDiag(this.message);
}

/// The live audio / video of one call and the chat that rides on its channel.
/// One instance per call; [dispose] it when the call screen goes away.
abstract class CallMediaEngine {
  Stream<CallMediaEvent> get events;

  /// Joins the channel. Publishes the microphone, plus the camera unless the
  /// credentials say [CallCredentialsEntity.audioOnly]. Throws if the SDK
  /// cannot start.
  Future<void> join(CallCredentialsEntity credentials);

  /// Leaves the channel and stops the camera and microphone. Safe to repeat.
  Future<void> leave();

  Future<void> setMicMuted(bool muted);

  /// Stops / resumes sending the camera (driver only; no-op for audio-only).
  Future<void> setCameraOff(bool off);

  Future<void> switchCamera();

  Future<void> setSpeakerOn(bool on);

  /// Sends a chat line to the other person. Returns false if it could not be
  /// sent (not connected yet, too long).
  Future<bool> sendChat(String text);

  /// This phone's own camera preview (driver).
  Widget localVideo();

  /// The other person's video.
  Widget remoteVideo(int uid);

  /// Releases everything. After this the engine cannot be used again.
  Future<void> dispose();
}
