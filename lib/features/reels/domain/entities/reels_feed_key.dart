/// How a reels feed is ordered. [apiValue] is the `sort` query parameter of
/// `GET /api/reels`.
enum ReelsSort {
  latest('latest'),
  popular('popular');

  final String apiValue;

  const ReelsSort(this.apiValue);
}

/// Identifies one reels feed: which reels it contains and in what order. This is the
/// key the feed notifier is keyed on, so two screens asking for the same key share one
/// loaded feed, and a different key is a different feed from page one.
///
/// Today a feed is the whole feed (newest first), optionally narrowed to a [categoryId]
/// and/or to the reels of a heatmap hotspot ([areaCell]). The upcoming reels algorithm
/// belongs here: new ways to choose or order reels become new fields of this key (and
/// a new [ReelsSort]) rather than new providers.
class ReelsFeedKey {
  /// Category id, or null for every category.
  final String? categoryId;

  /// H3 cell of a Reels-heatmap hotspot (the `h3Cell` of a cell from
  /// `GET /api/heatmap/reels`), or null for no area.
  final String? areaCell;

  const ReelsFeedKey({this.categoryId, this.areaCell});

  bool get hasArea => areaCell != null;

  /// An area feed is the area's *popular* reels; every other feed stays newest-first.
  ReelsSort get sort => hasArea ? ReelsSort.popular : ReelsSort.latest;

  @override
  bool operator ==(Object other) =>
      other is ReelsFeedKey &&
      other.categoryId == categoryId &&
      other.areaCell == areaCell;

  @override
  int get hashCode => Object.hash(categoryId, areaCell);

  @override
  String toString() => 'ReelsFeedKey(category: $categoryId, area: $areaCell)';
}
