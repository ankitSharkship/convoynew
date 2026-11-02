import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/entities/call_session_entities.dart';
import 'call_media_engine.dart';

/// Longest chat line we send. A data-stream packet is capped at 1 KB; this
/// leaves room for multi-byte (Hindi, Kannada ...) characters and the wrapper.
const maxChatLength = 240;

/// Agora RTC implementation of [CallMediaEngine]. Chat travels on a data stream
/// inside the same RTC channel (no second SDK, no separate token): it only
/// exists while both people are in the call, which is all in-call chat needs.
class AgoraCallMediaEngine implements CallMediaEngine {
  final _events = StreamController<CallMediaEvent>.broadcast();
  RtcEngine? _engine;
  RtcEngineEventHandler? _handler;
  String? _channelName;
  int? _streamId;
  bool _audioOnly = true;
  bool _connected = false;
  bool _disposed = false;

  @override
  Stream<CallMediaEvent> get events => _events.stream;

  void _emit(CallMediaEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  void _diag(String message) {
    debugPrint('[agora] $message');
    _emit(MediaDiag(message));
  }

  /// Runs one SDK call with a time limit, noting how it went. A native call that
  /// never returns (a camera that will not open, an engine stuck in setup) must
  /// show up as a named step instead of silently freezing the whole join.
  Future<T> _step<T>(
    String name,
    Future<T> Function() run, {
    Duration limit = const Duration(seconds: 8),
  }) async {
    final watch = Stopwatch()..start();
    try {
      final result = await run().timeout(limit);
      _diag('$name ok (${watch.elapsedMilliseconds} ms)');
      return result;
    } on TimeoutException {
      _diag('$name TIMED OUT after ${limit.inSeconds} s');
      throw TimeoutException('Agora step "$name" did not finish', limit);
    } catch (e) {
      _diag('$name FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<void> join(CallCredentialsEntity credentials) async {
    if (_engine != null) return; // one join per engine
    _audioOnly = credentials.audioOnly;
    _channelName = credentials.channelName;

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await _step(
      'initialize',
      () => engine.initialize(
        RtcEngineContext(
          appId: credentials.appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      ),
      limit: const Duration(seconds: 12),
    );

    _handler = RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _connected = true;
        _diag('joined the channel ($elapsed ms)');
        _emit(const MediaJoined());
        _openDataStream();
      },
      onRejoinChannelSuccess: (connection, elapsed) {
        _connected = true;
        _diag('rejoined the channel');
        _emit(const MediaConnectionRestored());
      },
      onLeaveChannel: (connection, stats) => _diag('left the channel'),
      onUserJoined: (connection, remoteUid, elapsed) {
        _diag('user $remoteUid joined');
        _emit(MediaPeerJoined(remoteUid));
      },
      onUserOffline: (connection, remoteUid, reason) {
        _diag('user $remoteUid left (${reason.name})');
        _emit(MediaPeerLeft(remoteUid));
      },
      onRemoteVideoStateChanged: (connection, uid, state, reason, elapsed) {
        _emit(
          MediaPeerVideo(
            uid,
            showing: state == RemoteVideoState.remoteVideoStateDecoding,
          ),
        );
      },
      onRemoteAudioStateChanged: (connection, uid, state, reason, elapsed) =>
          _diag('remote audio of $uid: ${state.name} (${reason.name})'),
      onLocalVideoStateChanged: (source, state, reason) =>
          _diag('camera: ${state.name} (${reason.name})'),
      onLocalAudioStateChanged: (connection, state, reason) =>
          _diag('microphone: ${state.name} (${reason.name})'),
      onTokenPrivilegeWillExpire: (connection, token) =>
          _diag('token about to expire'),
      onConnectionStateChanged: (connection, state, reason) {
        _diag('connection: ${state.name} (${reason.name})');
        switch (state) {
          case ConnectionStateType.connectionStateReconnecting:
            _connected = false;
            _emit(const MediaConnectionLost());
          case ConnectionStateType.connectionStateFailed:
            _connected = false;
            _emit(MediaFailed('connection failed: ${reason.name}'));
          default:
            break;
        }
      },
      onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
        final text = _decodeChat(data);
        if (text != null) _emit(MediaChatReceived(text));
      },
      onError: (code, message) {
        _diag('SDK error ${code.name} ($message)');
      },
    );
    engine.registerEventHandler(_handler!);

    // The requester hears the driver and sees their camera, so video is enabled
    // for both; only the driver actually opens a camera.
    await _step('enableVideo', () => engine.enableVideo());
    await _step(
      'speakerphone route',
      () => engine.setDefaultAudioRouteToSpeakerphone(true),
    );

    // Join first, preview after: a camera that is slow to open must never be
    // what keeps the person out of the call.
    await _step(
      'joinChannel',
      () => engine.joinChannel(
        token: credentials.rtcToken,
        channelId: credentials.channelName,
        uid: credentials.uid,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: !_audioOnly,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      ),
      limit: const Duration(seconds: 10),
    );
    if (!_audioOnly) unawaited(_startPreview(engine));
  }

  Future<void> _startPreview(RtcEngine engine) async {
    try {
      await _step('startPreview', () => engine.startPreview());
    } catch (_) {
      // Already noted by _step; the call can go on without a self-view.
    }
  }

  Future<void> _openDataStream() async {
    try {
      _streamId = await _engine?.createDataStream(
        const DataStreamConfig(syncWithAudio: false, ordered: true),
      );
    } catch (e) {
      debugPrint('Could not open the chat stream: $e');
    }
  }

  static String? _decodeChat(Uint8List data) {
    try {
      final json = jsonDecode(utf8.decode(data));
      if (json is Map && json['t'] == 'chat' && json['text'] is String) {
        final text = (json['text'] as String).trim();
        return text.isEmpty ? null : text;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> sendChat(String text) async {
    final engine = _engine;
    final streamId = _streamId;
    final trimmed = text.trim();
    if (engine == null ||
        streamId == null ||
        !_connected ||
        trimmed.isEmpty ||
        trimmed.length > maxChatLength) {
      return false;
    }
    try {
      final bytes = Uint8List.fromList(
        utf8.encode(jsonEncode({'t': 'chat', 'text': trimmed})),
      );
      await engine.sendStreamMessage(
        streamId: streamId,
        data: bytes,
        length: bytes.length,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setMicMuted(bool muted) async =>
      _engine?.muteLocalAudioStream(muted);

  @override
  Future<void> setCameraOff(bool off) async {
    if (_audioOnly) return;
    await _engine?.muteLocalVideoStream(off);
    await _engine?.enableLocalVideo(!off);
  }

  @override
  Future<void> switchCamera() async {
    if (_audioOnly) return;
    await _engine?.switchCamera();
  }

  @override
  Future<void> setSpeakerOn(bool on) async =>
      _engine?.setEnableSpeakerphone(on);

  @override
  Widget localVideo() {
    final engine = _engine;
    if (engine == null || _audioOnly) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  @override
  Widget remoteVideo(int uid) {
    final engine = _engine;
    final channel = _channelName;
    if (engine == null || channel == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: engine,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: channel),
      ),
    );
  }

  @override
  Future<void> leave() async {
    final engine = _engine;
    if (engine == null) return;
    _connected = false;
    try {
      if (!_audioOnly) {
        await engine.stopPreview().timeout(const Duration(seconds: 3));
      }
      await engine.leaveChannel().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Leaving the channel failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      try {
        if (_handler != null) engine.unregisterEventHandler(_handler!);
        await engine.leaveChannel().timeout(const Duration(seconds: 3));
        await engine.release().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Releasing the call engine failed: $e');
      }
    }
    // Not awaited: a broadcast controller's close() only completes once its
    // listeners have been told, and by now nobody may be listening.
    unawaited(_events.close());
  }
}
