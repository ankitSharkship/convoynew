import 'package:convoynew/features/heatmap/domain/entities/geo_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const city = GeoBox(minLat: 28.5, minLng: 77.1, maxLat: 28.7, maxLng: 77.3);

  test('containsBox: inside, equal, partly outside', () {
    expect(city.containsBox(city), isTrue);
    expect(
      city.containsBox(
        const GeoBox(minLat: 28.55, minLng: 77.15, maxLat: 28.65, maxLng: 77.25),
      ),
      isTrue,
    );
    expect(
      city.containsBox(
        const GeoBox(minLat: 28.55, minLng: 77.15, maxLat: 28.75, maxLng: 77.25),
      ),
      isFalse,
    );
  });

  test('padded grows by the fraction on every side and contains the original', () {
    final padded = city.padded(0.5);
    expect(padded.minLat, closeTo(28.4, 1e-9));
    expect(padded.maxLat, closeTo(28.8, 1e-9));
    expect(padded.minLng, closeTo(77.0, 1e-9));
    expect(padded.maxLng, closeTo(77.4, 1e-9));
    expect(padded.containsBox(city), isTrue);
  });

  test('padded never exceeds the span the server accepts, around the same centre', () {
    const huge = GeoBox(minLat: 10, minLng: 70, maxLat: 14, maxLng: 75);
    final padded = huge.padded(0.5, maxSpanDegrees: 2.5);
    expect(padded.latSpan, lessThanOrEqualTo(2.5));
    expect(padded.lngSpan, lessThanOrEqualTo(2.5));
    expect(padded.centerLat, closeTo(huge.centerLat, 1e-9));
    expect(padded.centerLng, closeTo(huge.centerLng, 1e-9));
  });

  test('padded stays within valid coordinates', () {
    const edge = GeoBox(minLat: 89.5, minLng: 179.5, maxLat: 90, maxLng: 180);
    final padded = edge.padded(1);
    expect(padded.maxLat, lessThanOrEqualTo(90));
    expect(padded.maxLng, lessThanOrEqualTo(180));
  });
}
