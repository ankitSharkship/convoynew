/// Which layer of activity a heatmap shows. [pathSegment] is the final part
/// of its endpoint: `GET /api/heatmap/<pathSegment>`.
enum HeatmapKind {
  trucks('trucks'),
  reels('reels');

  final String pathSegment;

  const HeatmapKind(this.pathSegment);
}

/// One H3 hexagon with how many trucks/reels fall inside it. Only the cell
/// centre is ever known — never an exact position.
class HeatCellEntity {
  final String h3Cell;
  final double lat;
  final double lng;
  final int count;

  const HeatCellEntity({
    required this.h3Cell,
    required this.lat,
    required this.lng,
    required this.count,
  });
}

class HeatmapEntity {
  final HeatmapKind kind;

  /// H3 resolution the [cells] were aggregated at (3 coarse .. 9 fine).
  final int resolution;

  /// Smallest `count` a returned cell can have: 1, or 3 at the finest
  /// resolutions, where the server hides cells that could pinpoint one item.
  final int minCellActivity;

  /// True when the server dropped the weakest cells to stay under its cap.
  final bool truncated;

  final List<HeatCellEntity> cells;

  const HeatmapEntity({
    required this.kind,
    required this.resolution,
    required this.minCellActivity,
    required this.truncated,
    required this.cells,
  });
}
