import 'dart:convert';
import 'dart:typed_data';

import 'package:convoynew/core/network/api_exception.dart';
import 'package:convoynew/features/call_request/data/datasources/call_request_remote_datasource.dart';
import 'package:convoynew/features/call_request/data/models/call_request_model.dart';
import 'package:convoynew/features/call_request/domain/entities/call_request_entity.dart';
import 'package:convoynew/features/call_request/domain/failures/call_request_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A request exactly as docs/ONE_TO_ONE_CALL_API.md shows it.
Map<String, dynamic> requestJson({
  String status = 'pending',
  String role = 'requester',
}) => {
  'id': 'r1',
  'role': role,
  'status': status,
  'topic': 'Route status',
  'durationMinutes': 15,
  'amount': '150.00',
  'holdAmount': '37.50',
  'requester': {'id': 'a', 'name': 'Asha', 'photo': null},
  'provider': {
    'id': 'p',
    'name': 'Vikram',
    'photo': '/api/user/profile-photo/p',
  },
  'truckRouteId': 't1',
  'expiresAt': '2026-10-29T10:45:00',
  'createdAt': '2026-10-29T10:15:00.123456',
  'respondedAt': null,
  'callStartedAt': null,
  'callEndedAt': null,
  'connectedSeconds': null,
  'feedbackDeadline': null,
  'satisfied': null,
  'settledAmount': null,
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
  group('CallRequestModel', () {
    test('parses a server payload', () {
      final r = CallRequestModel.fromJson(requestJson());
      expect(r.status, CallStatus.pending);
      expect(r.isRequester, isTrue);
      expect(r.amount, '150.00');
      expect(r.holdAmount, '37.50');
      expect(r.provider.name, 'Vikram');
      expect(r.otherParty.name, 'Vikram'); // the requester sees the driver
      expect(r.callStartedAt, isNull);
      expect(r.satisfied, isNull);
    });

    test('knows when the call is on the person\'s other phone', () {
      expect(CallRequestModel.fromJson(requestJson()).onAnotherDevice, isFalse);
      final json = requestJson()..['onAnotherDevice'] = true;
      expect(CallRequestModel.fromJson(json).onAnotherDevice, isTrue);
    });

    test('timestamps without a zone are read as UTC', () {
      final r = CallRequestModel.fromJson(requestJson());
      expect(r.expiresAt.isUtc, isTrue);
      expect(r.expiresAt, DateTime.utc(2026, 10, 29, 10, 45));
      expect(r.createdAt.isUtc, isTrue);
    });

    test('timestamps with an offset keep their instant', () {
      final json = requestJson()..['expiresAt'] = '2026-10-29T16:15:00+05:30';
      expect(
        CallRequestModel.fromJson(json).expiresAt.toUtc(),
        DateTime.utc(2026, 10, 29, 10, 45),
      );
    });

    test('the driver sees the requester as the other party', () {
      final r = CallRequestModel.fromJson(requestJson(role: 'provider'));
      expect(r.isRequester, isFalse);
      expect(r.otherParty.name, 'Asha');
      expect(r.canCancel, isFalse); // only the requester can cancel
    });

    test('only pending and accepted requests can be cancelled', () {
      bool can(String s) =>
          CallRequestModel.fromJson(requestJson(status: s)).canCancel;
      expect(can('pending'), isTrue);
      expect(can('accepted'), isTrue);
      for (final s in [
        'ringing',
        'live',
        'awaiting_feedback',
        'completed',
        'rejected',
        'cancelled',
        'expired',
        'failed',
      ]) {
        expect(can(s), isFalse, reason: s);
      }
    });

    test('in progress means worth polling', () {
      bool going(String s) =>
          CallRequestModel.fromJson(requestJson(status: s)).isInProgress;
      for (final s in ['pending', 'accepted', 'ringing', 'live']) {
        expect(going(s), isTrue, reason: s);
      }
      for (final s in [
        'awaiting_feedback',
        'completed',
        'rejected',
        'cancelled',
        'expired',
        'failed',
      ]) {
        expect(going(s), isFalse, reason: s);
      }
    });
  });

  group('CallRequestRemoteDataSource', () {
    test(
      'create posts the offer as the server expects it and parses the reply',
      () async {
        final reply = _Reply(201, {'success': true, 'request': requestJson()});
        final r = await _source(reply).create(
          providerId: 'p',
          truckRouteId: 't1',
          topic: 'Route status',
          durationMinutes: 15,
          amountRupees: 150,
        );
        expect(r.id, 'r1');
        expect(reply.last!.path, '/api/call-requests');
        expect(reply.last!.data, {
          'providerId': 'p',
          'truckRouteId': 't1',
          'topic': 'Route status',
          'durationMinutes': 15,
          'amount': '150',
        });
      },
    );

    test('cancel posts to the cancel endpoint', () async {
      final reply = _Reply(200, {
        'success': true,
        'request': requestJson(status: 'cancelled'),
      });
      final r = await _source(reply).cancel('r1');
      expect(r.status, 'cancelled');
      expect(reply.last!.path, '/api/call-requests/r1/cancel');
      expect(reply.last!.method, 'POST');
    });

    test(
      '402 INSUFFICIENT_BALANCE becomes a typed exception with the shortfall',
      () async {
        final reply = _Reply(402, {
          'detail': 'Add ₹80.00 to your wallet to offer ₹200.00',
          'code': 'INSUFFICIENT_BALANCE',
          'requiredAmount': '200.00',
          'spendableBalance': '120.00',
          'shortfall': '80.00',
        });
        await expectLater(
          _source(reply).create(
            providerId: 'p',
            truckRouteId: 't',
            topic: 'x',
            durationMinutes: 15,
            amountRupees: 200,
          ),
          throwsA(
            isA<CallRequestException>()
                .having(
                  (e) => e.isInsufficientBalance,
                  'isInsufficientBalance',
                  isTrue,
                )
                .having((e) => e.shortfall, 'shortfall', '80.00')
                .having(
                  (e) => e.message,
                  'message',
                  'Add ₹80.00 to your wallet to offer ₹200.00',
                )
                .having((e) => e.statusCode, 'statusCode', 402),
          ),
        );
      },
    );

    test('409 ALREADY_OPEN carries the existing request id', () async {
      final reply = _Reply(409, {
        'detail': 'You already have an open request with this driver',
        'code': 'ALREADY_OPEN',
        'requestId': 'existing-1',
      });
      await expectLater(
        _source(reply).create(
          providerId: 'p',
          truckRouteId: 't',
          topic: 'x',
          durationMinutes: 15,
          amountRupees: 100,
        ),
        throwsA(
          isA<CallRequestException>()
              .having((e) => e.isAlreadyOpen, 'isAlreadyOpen', isTrue)
              .having(
                (e) => e.existingRequestId,
                'existingRequestId',
                'existing-1',
              ),
        ),
      );
    });

    test(
      'an error without a code stays an ApiException with the server message',
      () async {
        final reply = _Reply(500, {'detail': 'Boom'});
        await expectLater(
          _source(reply).get('r1'),
          throwsA(
            isA<ApiException>().having((e) => e.message, 'message', 'Boom'),
          ),
        );
      },
    );
  });
}
