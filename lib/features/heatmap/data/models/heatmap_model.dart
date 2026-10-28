import '../../domain/entities/heatmap_entity.dart';

class HeatCellModel {
  /// Returns null for a malformed cell so one bad entry can't fail the map.
  static HeatCellEntity? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final lat = json['centerLat'];
    final lng = json['centerLng'];
    final count = json['count'];
    if (lat is! num || lng is! num || count is! num) return null;
    if (count <= 0) return null;
    return HeatCellEntity(
      h3Cell: json['h3Cell'] as String? ?? '',
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      count: count.toInt(),
    );
  }
}

class HeatmapModel {
  static HeatmapEntity fromJson(
    Map<String, dynamic> json, {
    required HeatmapKind kind,
    required int requestedResolution,
  }) {
    final rawCells = json['cells'];
    final cells = <HeatCellEntity>[
      if (rawCells is List)
        for (final raw in rawCells) ?HeatCellModel.tryFromJson(raw),
    ];
    return HeatmapEntity(
      kind: kind,
      resolution: (json['resolution'] as num?)?.toInt() ?? requestedResolution,
      minCellActivity: (json['minCellActivity'] as num?)?.toInt() ?? 1,
      truncated: json['truncated'] as bool? ?? false,
      cells: cells,
    );
  }
}
