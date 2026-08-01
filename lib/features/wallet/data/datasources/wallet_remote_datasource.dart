import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet(String userId);

  Future<List<WalletTransactionModel>> getTransactions(String userId);

  /// [idempotencyKey]: one fresh key per redeem attempt, reused across
  /// retries of that same attempt — see WalletNotifier.redeem for why.
  Future<RedeemRequestModel> redeem({
    required String userId,
    required String upiId,
    required String idempotencyKey,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio _dio;

  WalletRemoteDataSourceImpl(this._dio);

  @override
  Future<WalletModel> getWallet(String userId) async {
    try {
      final response = await _dio.get('/api/wallet/$userId');
      return WalletModel.fromJson(
        response.data['wallet'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions(String userId) async {
    try {
      final response = await _dio.get('/api/wallet/$userId/transactions');
      final list = response.data['transactions'] as List;
      return list
          .map(
            (json) =>
                WalletTransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<RedeemRequestModel> redeem({
    required String userId,
    required String upiId,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        '/api/wallet/$userId/redeem',
        data: {'upiId': upiId, 'idempotencyKey': idempotencyKey},
      );
      return RedeemRequestModel.fromJson(
        response.data['redeemRequest'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
