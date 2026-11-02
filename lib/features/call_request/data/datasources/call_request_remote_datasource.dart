import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/call_session_entities.dart';
import '../../domain/failures/call_request_exception.dart';
import '../models/call_request_model.dart';
import '../models/call_session_models.dart';

abstract class CallRequestRemoteDataSource {
  Future<CallRequestModel> create({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  });

  Future<CallRequestModel> get(String requestId);

  Future<CallRequestModel> cancel(String requestId);

  Future<List<CallRequestModel>> getIncoming();

  Future<CallRequestModel> accept(String requestId);

  Future<CallRequestModel> reject(String requestId);

  Future<List<CallRequestModel>> getOutgoingActive();

  Future<CallJoinResult> start(String requestId);

  Future<CallJoinResult> join(String requestId);

  Future<CallHeartbeatEntity> heartbeat(String requestId, bool peerPresent);

  Future<CallRequestModel> end(String requestId);

  Future<CallRequestModel> submitFeedback(String requestId, bool satisfied);

  Future<void> sendEvents(String requestId, List<CallBehaviourEvent> events);
}

class CallRequestRemoteDataSourceImpl implements CallRequestRemoteDataSource {
  final Dio _dio;

  CallRequestRemoteDataSourceImpl(this._dio);

  /// Rule violations carry a stable `code` next to the plain-string `detail`;
  /// those become a [CallRequestException]. Everything else (no network, a
  /// crash on the server, ...) goes through the app's usual [ApiException].
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['code'] is String && data['detail'] is String) {
        throw CallRequestException(
          code: data['code'] as String,
          message: data['detail'] as String,
          statusCode: e.response?.statusCode,
          extra: Map<String, dynamic>.from(data),
        );
      }
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (e, st) {
      // Not a network problem: most likely a response this app cannot read. Say so
      // in the debug console instead of showing only a generic "no connection".
      debugPrint('[call-api] unexpected error: $e\n$st');
      throw const ApiException();
    }
  }

  CallRequestModel _one(Response<dynamic> response) =>
      CallRequestModel.fromJson(
        (response.data as Map<String, dynamic>)['request']
            as Map<String, dynamic>,
      );

  @override
  Future<CallRequestModel> create({
    required String providerId,
    required String truckRouteId,
    required String topic,
    required int durationMinutes,
    required int amountRupees,
  }) => _guard(() async {
    final response = await _dio.post(
      '/api/call-requests',
      data: {
        'providerId': providerId,
        'truckRouteId': truckRouteId,
        'topic': topic,
        'durationMinutes': durationMinutes,
        'amount': amountRupees.toString(),
      },
    );
    return _one(response);
  });

  @override
  Future<CallRequestModel> get(String requestId) =>
      _guard(() async => _one(await _dio.get('/api/call-requests/$requestId')));

  @override
  Future<CallRequestModel> cancel(String requestId) => _guard(
    () async => _one(await _dio.post('/api/call-requests/$requestId/cancel')),
  );

  @override
  Future<List<CallRequestModel>> getIncoming() => _guard(() async {
    final response = await _dio.get('/api/call-requests/incoming');
    final list = (response.data as Map<String, dynamic>)['requests'] as List;
    return list
        .map((json) => CallRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<CallRequestModel> accept(String requestId) => _guard(
    () async => _one(await _dio.post('/api/call-requests/$requestId/accept')),
  );

  @override
  Future<CallRequestModel> reject(String requestId) => _guard(
    () async => _one(await _dio.post('/api/call-requests/$requestId/reject')),
  );

  @override
  Future<List<CallRequestModel>> getOutgoingActive() => _guard(() async {
    final response = await _dio.get(
      '/api/call-requests/outgoing',
      queryParameters: {'activeOnly': true},
    );
    final list = (response.data as Map<String, dynamic>)['requests'] as List;
    return list
        .map((json) => CallRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<CallJoinResult> start(String requestId) => _guard(() async {
    final response = await _dio.post('/api/call-requests/$requestId/start');
    return callJoinResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<CallJoinResult> join(String requestId) => _guard(() async {
    final response = await _dio.post('/api/call-requests/$requestId/join');
    return callJoinResultFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<CallHeartbeatEntity> heartbeat(String requestId, bool peerPresent) =>
      _guard(() async {
        final response = await _dio.post(
          '/api/call-requests/$requestId/heartbeat',
          data: {'peerPresent': peerPresent},
        );
        return callHeartbeatFromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<CallRequestModel> end(String requestId) => _guard(
    () async => _one(await _dio.post('/api/call-requests/$requestId/end')),
  );

  @override
  Future<CallRequestModel> submitFeedback(String requestId, bool satisfied) =>
      _guard(
        () async => _one(
          await _dio.post(
            '/api/call-requests/$requestId/feedback',
            data: {'satisfied': satisfied},
          ),
        ),
      );

  @override
  Future<void> sendEvents(
    String requestId,
    List<CallBehaviourEvent> events,
  ) => _guard(() async {
    await _dio.post(
      '/api/call-requests/$requestId/events',
      data: {'events': events.map(callEventToJson).toList()},
    );
  });
}
