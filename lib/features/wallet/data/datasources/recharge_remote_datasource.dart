import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/recharge_entities.dart';
import '../../domain/failures/recharge_exception.dart';
import '../models/recharge_models.dart';

abstract class RechargeRemoteDataSource {
  Future<RechargeConfig> getConfig();
  Future<RechargeOrder> create(String userId, int amountRupees);
  Future<RechargeOrder> confirm(String userId, PaymentProof proof);
  Future<RechargeOrder> get(String userId, String orderId);
}

class RechargeRemoteDataSourceImpl implements RechargeRemoteDataSource {
  final Dio _dio;

  RechargeRemoteDataSourceImpl(this._dio);

  /// Rule violations carry a stable `code` next to the plain `detail`: those
  /// become a [RechargeException]; anything else goes through [ApiException].
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['code'] is String && data['detail'] is String) {
        throw RechargeException(
          code: data['code'] as String,
          message: data['detail'] as String,
          statusCode: e.response?.statusCode,
        );
      }
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } on RechargeException {
      rethrow;
    } catch (_) {
      throw const ApiException();
    }
  }

  RechargeOrder _one(Response<dynamic> response) => rechargeOrderFromJson(
    (response.data as Map<String, dynamic>)['recharge'] as Map<String, dynamic>,
  );

  @override
  Future<RechargeConfig> getConfig() => _guard(() async {
    final response = await _dio.get('/api/wallet/recharge/config');
    return rechargeConfigFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<RechargeOrder> create(String userId, int amountRupees) => _guard(
    () async => _one(
      await _dio.post(
        '/api/wallet/$userId/recharges',
        data: {'amount': amountRupees.toString()},
      ),
    ),
  );

  @override
  Future<RechargeOrder> confirm(String userId, PaymentProof proof) => _guard(
    () async => _one(
      await _dio.post(
        '/api/wallet/$userId/recharges/confirm',
        data: {
          'orderId': proof.orderId,
          'paymentId': proof.paymentId,
          'signature': proof.signature,
        },
      ),
    ),
  );

  @override
  Future<RechargeOrder> get(String userId, String orderId) => _guard(
    () async =>
        _one(await _dio.get('/api/wallet/$userId/recharges/$orderId')),
  );
}
