import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../models/heatmap_model.dart';

abstract class HeatmapRemoteDataSource {
  Future<HeatmapEntity> getHeatmap(HeatmapKind kind, int resolution);
}

class HeatmapRemoteDataSourceImpl implements HeatmapRemoteDataSource {
  final Dio _dio;

  HeatmapRemoteDataSourceImpl(this._dio);

  @override
  Future<HeatmapEntity> getHeatmap(HeatmapKind kind, int resolution) async {
    try {
      final response = await _dio.get(
        '/api/heatmap/${kind.pathSegment}',
        queryParameters: {'resolution': resolution},
      );
      return HeatmapModel.fromJson(
        response.data as Map<String, dynamic>,
        kind: kind,
        requestedResolution: resolution,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException();
    }
  }
}
