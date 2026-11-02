import 'dart:convert';
import 'dart:typed_data';

import 'package:convoynew/features/call_request/data/datasources/call_request_remote_datasource.dart';
import 'package:convoynew/features/call_request/data/models/call_request_model.dart';
import 'package:convoynew/features/call_request/data/models/call_session_models.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/entities/call_session_entities.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> requestJson({
  String status = 'ringing',
  String? ringEndsAt = '2026-10-30T10:30:45',
}) => {
  'id': 'r1',
  'role': 'provider',
  'status': status,
  'topic': 'Route status',
  'durationMinutes': 15,
  'amount': '150.00',
  'holdAmount': '37.50',
  'requester': {'id': 'a', 'name': 'Asha', 'photo': null},
  'provider': {'id': 'p', 'name': 'Vikram', 'photo': null},
  'truckRouteId': 't1',
  'expiresAt': '2026-10-30T10:45:00',
  'createdAt': '2026-10-30T10:15:00',
  'respondedAt': null,
  'callStartedAt': null,
  'ringEndsAt': ringEndsAt,
  'callEndedAt': null,
  'connectedSeconds': null,
  'feedbackDeadline': null,
  'satisfied': null,
  'settledAmount': null,
};

/// The `call` object exactly as docs/ONE_TO_ONE_CALL_API.md shows it.
Map<String, dynamic> callJson({bool audioOnly = false, String? ringEndsAt}) => {
  'requestId': 'r1',
  'role': audioOnly ? 'requester' : 'provider',
  'appId': 'app-id',
  'channelName': 'call-r1',
  'uid': 123456789,
  'rtcToken': 'tok',
  'tokenExpiresAt': '2026-10-30T10:30:00+00:00',
  'durationSeconds': 900,
  'audioOnly': audioOnly,
  'ringEndsAt': ringEndsAt,
  'chatAvailable': false,
  'rtmUserId': 'u',
  'rtmToken': null,
};

class _Reply implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;

  _Reply(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CallRequestRemoteDataSourceImpl _source(_Reply reply) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = reply;
  return CallRequestRemoteDataSourceImpl(dio);
}

void main() {
  group('models', () {
    test('a request carries its ring deadline while it rings', () {
      final r = CallRequestModel.fromJson(requestJson());
      expect(r.ringEndsAt, DateTime.utc(2026, 10, 30, 10, 30, 45));
      expect(r.isProvider, isTrue);
    });

    test('no ring deadline when it is not ringing', () {
      final r = CallRequestModel.fromJson(
        requestJson(status: 'live', ringEndsAt: null),
      );
      expect(r.ringEndsAt, isNull);
    });

    test('credentials are read as the docs show them', () {
      final c = callCredentialsFromJson(callJson());
      expect(c.requestId, 'r1');
      expect(c.appId, 'app-id');
      expect(c.channelName, 'call-r1');
      expect(c.uid, 123456789);
      expect(c.rtcToken, 'tok');
      expect(c.durationSeconds, 900);
      expect(c.audioOnly, isFalse);
      expect(c.ringEndsAt, isNull);
      expect(c.tokenExpiresAt, DateTime.utc(2026, 10, 30, 10, 30));
    });

    test('the requester\'s credentials are audio-only', () {
      expect(callCredentialsFromJson(callJson(audioOnly: true)).audioOnly, isTrue);
    });

    test('a heartbeat answer is read, with and without peerOnline', () {
      final a = callHeartbeatFromJson({
        'success': true,
        'status': 'live',
        'connectedSeconds': 35,
        'remainingSeconds': 860,
        'thresholdSeconds': 30,
        'peerOnline': true,
      });
      expect(a.status, 'live');
      expect(a.connectedSeconds, 35);
      expect(a.remainingSeconds, 860);
      expect(a.thresholdSeconds, 30);
      expect(a.peerOnline, isTrue);

      final b = callHeartbeatFromJson({
        'success': true,
        'status': 'awaiting_feedback',
        'connectedSeconds': 41,
        'remainingSeconds': 0,
        'thresholdSeconds': 30,
      });
      expect(b.status, 'awaiting_feedback');
      expect(b.peerOnline, isFalse);
    });

    test('an event is sent in UTC, and without details when it has none', () {
      final json = callEventToJson(
        CallBehaviourEvent(
          type: 'mic_off',
          occurredAt: DateTime.parse('2026-10-30T15:45:00+05:30'),
        ),
      );
      expect(json, {'type': 'mic_off', 'occurredAt': '2026-10-30T10:15:00.000Z'});
      expect(
        callEventToJson(
          CallBehaviourEvent(
            type: 'chat_message_sent',
            occurredAt: DateTime.utc(2026),
            details: const {'length': 12},
          ),
        )['details'],
        {'length': 12},
      );
    });
  });

  group('datasource', () {
    test('start posts to /start and returns the request with credentials', () async {
      final reply = _Reply(200, {
        'success': true,
        'request': requestJson(),
        'call': callJson(ringEndsAt: '2026-10-30T10:30:45+00:00'),
      });
      final result = await _source(reply).start('r1');
      expect(reply.last!.method, 'POST');
      expect(reply.last!.uri.path, '/api/call-requests/r1/start');
      expect(result.request.status, CallStatus.ringing);
      expect(result.credentials.ringEndsAt, DateTime.utc(2026, 10, 30, 10, 30, 45));
    });

    test('join posts to /join', () async {
      final reply = _Reply(200, {
        'success': true,
        'request': requestJson(status: 'live', ringEndsAt: null),
        'call': callJson(audioOnly: true),
      });
      final result = await _source(reply).join('r1');
      expect(reply.last!.uri.path, '/api/call-requests/r1/join');
      expect(result.credentials.audioOnly, isTrue);
    });

    test('answering too late is a CallRequestException the screen can show', () async {
      final reply = _Reply(409, {
        'detail': 'This call wasn\'t answered in time',
        'code': 'RING_OVER',
      });
      await expectLater(
        _source(reply).join('r1'),
        throwsA(
          isA<CallRequestException>().having((e) => e.code, 'code', 'RING_OVER'),
        ),
      );
    });

    test('heartbeat says whether the other person is in the channel', () async {
      final reply = _Reply(200, {
        'success': true,
        'status': 'live',
        'connectedSeconds': 5,
        'remainingSeconds': 890,
        'thresholdSeconds': 30,
      });
      final beat = await _source(reply).heartbeat('r1', true);
      expect(reply.last!.uri.path, '/api/call-requests/r1/heartbeat');
      expect(reply.last!.data, {'peerPresent': true});
      expect(beat.connectedSeconds, 5);
    });

    test('end posts to /end and returns the request', () async {
      final reply = _Reply(200, {
        'success': true,
        'request': requestJson(status: 'awaiting_feedback', ringEndsAt: null),
      });
      final r = await _source(reply).end('r1');
      expect(reply.last!.uri.path, '/api/call-requests/r1/end');
      expect(r.status, CallStatus.awaitingFeedback);
    });

    test('feedback sends the yes/no answer', () async {
      final reply = _Reply(200, {
        'success': true,
        'request': requestJson(status: 'completed', ringEndsAt: null),
      });
      await _source(reply).submitFeedback('r1', false);
      expect(reply.last!.uri.path, '/api/call-requests/r1/feedback');
      expect(reply.last!.data, {'satisfied': false});
    });

    test('events go out as a batch', () async {
      final reply = _Reply(200, {'success': true, 'recorded': 2});
      await _source(reply).sendEvents('r1', [
        CallBehaviourEvent(type: 'call_joined', occurredAt: DateTime.utc(2026)),
        CallBehaviourEvent(type: 'mic_on', occurredAt: DateTime.utc(2026)),
      ]);
      expect(reply.last!.uri.path, '/api/call-requests/r1/events');
      final events = (reply.last!.data as Map)['events'] as List;
      expect(events.map((e) => (e as Map)['type']), ['call_joined', 'mic_on']);
    });

    test('the requester\'s open requests are asked for with activeOnly', () async {
      final reply = _Reply(200, {
        'success': true,
        'requests': [requestJson(status: 'awaiting_feedback', ringEndsAt: null)],
      });
      final list = await _source(reply).getOutgoingActive();
      expect(reply.last!.uri.path, '/api/call-requests/outgoing');
      expect(reply.last!.uri.queryParameters['activeOnly'], 'true');
      expect(list.single.status, CallStatus.awaitingFeedback);
    });
  });
}
