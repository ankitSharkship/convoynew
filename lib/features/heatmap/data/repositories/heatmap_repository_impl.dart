import '../../domain/entities/heatmap_entity.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../datasources/heatmap_remote_datasource.dart';

class HeatmapRepositoryImpl implements HeatmapRepository {
  final HeatmapRemoteDataSource _remote;

  HeatmapRepositoryImpl(this._remote);

  @override
  Future<HeatmapEntity> getHeatmap(HeatmapKind kind, int resolution) =>
      _remote.getHeatmap(kind, resolution);
}
