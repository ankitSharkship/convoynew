import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../post/data/models/trip_model.dart';
import '../../../post/domain/entities/trip_entity.dart';
import '../../../search/domain/entities/search_history_entity.dart';
import '../models/search_history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<TripEntity>> getPostHistory();

  Future<List<SearchHistoryEntity>> getSearchHistory();
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio _dio;

  HistoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TripEntity>> getPostHistory() async {
    final items = await _getHistoryItems('post');
    return items.map((e) => TripModel.fromJson(e)).toList();
  }

  @override
  Future<List<SearchHistoryEntity>> getSearchHistory() async {
    final items = await _getHistoryItems('search');
    return items.map((e) => searchHistoryFromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> _getHistoryItems(String type) async {
    try {
      final response = await _dio.get(
        '/api/history',
        queryParameters: {'type': type},
      );
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
