import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/scratch_card_model.dart';

abstract class ScratchCardRemoteDataSource {
  Future<List<ScratchCardModel>> listCards(String userId);

  /// [idempotencyKey]: one fresh key per scratch attempt, generated right
  /// before this call and reused on retry — see ScratchCardsNotifier.scratch.
  Future<ScratchResultModel> scratch({
    required String userId,
    required String cardId,
    required String idempotencyKey,
  });
}

class ScratchCardRemoteDataSourceImpl implements ScratchCardRemoteDataSource {
  final Dio _dio;

  ScratchCardRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ScratchCardModel>> listCards(String userId) async {
    try {
      final response = await _dio.get('/api/scratch-cards/$userId');
      final list = response.data['scratchCards'] as List;
      return list
          .map((json) => ScratchCardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<ScratchResultModel> scratch({
    required String userId,
    required String cardId,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        '/api/scratch-cards/$userId/$cardId/scratch',
        data: {'idempotencyKey': idempotencyKey},
      );
      return ScratchResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
