/// A latitude/longitude rectangle — the part of the map currently on screen.
class GeoBox {
  final double minLat;
  final double minLng;
  final double maxLat;
  final double maxLng;

  const GeoBox({
    required this.minLat,
    required this.minLng,
    required this.maxLat,
    required this.maxLng,
  });

  double get centerLat => (minLat + maxLat) / 2;
  double get centerLng => (minLng + maxLng) / 2;
  double get latSpan => maxLat - minLat;
  double get lngSpan => maxLng - minLng;
 
  /// True when [other] lies entirely inside this box.
  bool containsBox(GeoBox other) =>
      other.minLat >= minLat &&
      other.maxLat <= maxLat &&
      other.minLng >= minLng &&
      other.maxLng <= maxLng;

  /// This box grown by [fraction] of its size on every side (so a small pan
  /// stays inside it), kept within valid coordinates and never wider than
  /// [maxSpanDegrees] per side (the server refuses larger areas).
  GeoBox padded(double fraction, {double maxSpanDegrees = 2.5}) {
    final dLat = latSpan * fraction;
    final dLng = lngSpan * fraction;
    var lat0 = minLat - dLat;
    var lat1 = maxLat + dLat;
    var lng0 = minLng - dLng;
    var lng1 = maxLng + dLng;
    if (lat1 - lat0 > maxSpanDegrees) {
      lat0 = centerLat - maxSpanDegrees / 2;
      lat1 = centerLat + maxSpanDegrees / 2;
    }
    if (lng1 - lng0 > maxSpanDegrees) {
      lng0 = centerLng - maxSpanDegrees / 2;
      lng1 = centerLng + maxSpanDegrees / 2;
    }
    return GeoBox(
      minLat: lat0.clamp(-90.0, 90.0),
      minLng: lng0.clamp(-180.0, 180.0),
      maxLat: lat1.clamp(-90.0, 90.0),
      maxLng: lng1.clamp(-180.0, 180.0),
    );
  }
}
