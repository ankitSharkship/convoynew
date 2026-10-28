import '../entities/heatmap_entity.dart';
import '../repositories/heatmap_repository.dart';

class GetHeatmapUseCase {
  final HeatmapRepository _repository;

  GetHeatmapUseCase(this._repository);

  Future<HeatmapEntity> execute(HeatmapKind kind, int resolution) =>
      _repository.getHeatmap(kind, resolution);
}
