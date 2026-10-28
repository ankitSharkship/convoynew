import 'package:convoynew/features/heatmap/data/models/truck_pins_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses pins and the truncated flag', () {
    final result = TruckPinsModel.fromJson({
      'success': true,
      'count': 2,
      'truncated': true,
      'pins': [
        {'id': 'a', 'lat': 28.6, 'lng': 77.2, 'truckType': 'Open Body', 'capacity': 9.0},
        {'id': 'b', 'lat': 19, 'lng': 72, 'truckType': 'Container', 'capacity': 16},
      ],
    });
    expect(result.truncated, isTrue);
    expect(result.pins.map((p) => p.id), ['a', 'b']);
    expect(result.pins.first.capacity, 9); // a JSON double becomes an int
    expect(result.pins.last.lng, 72.0);
  });

  test('skips malformed pins instead of failing the whole response', () {
    final result = TruckPinsModel.fromJson({
      'pins': [
        {'id': 'ok', 'lat': 1.0, 'lng': 2.0},
        {'lat': 1.0, 'lng': 2.0},
        {'id': 'x', 'lat': 'bad', 'lng': 2.0},
        'nope',
        null,
      ],
    });
    expect(result.pins.map((p) => p.id), ['ok']);
    expect(result.pins.single.truckType, '');
    expect(result.truncated, isFalse);
  });

  test('a missing pins list is an empty result', () {
    expect(TruckPinsModel.fromJson({'pins': 'x'}).pins, isEmpty);
    expect(TruckPinsModel.fromJson({}).pins, isEmpty);
  });
}
