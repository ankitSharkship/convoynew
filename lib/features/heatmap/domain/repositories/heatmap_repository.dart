import '../entities/heatmap_entity.dart';

abstract class HeatmapRepository {
  Future<HeatmapEntity> getHeatmap(HeatmapKind kind, int resolution);
}
