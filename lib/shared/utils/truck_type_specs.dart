/// Per-truck-type valid ranges for capacity (tons), length (ft), and height
/// (ft), sourced directly from the ops-provided reference table. A `null`
/// range means that field simply doesn't apply to the type (e.g. no truck
/// type in the table has a capacity AND a height both blank, but several
/// have one or the other blank) — the add-truck form hides the
/// corresponding wheel picker entirely rather than showing an unbounded one.
///
/// Height ranges are the *table* values — the accepted ±0.5ft margin around
/// them is applied where the picker/validation range is actually built
/// (see `add_truck_sheet.dart`), not baked in here, so this file stays a
/// faithful copy of the source table.
///
/// Tanker deliberately has no entry: it isn't in the reference table at
/// all, so the add-truck form falls back to its old unrestricted capacity
/// list for it and shows no length/height fields.
library;

class TruckTypeRange {
  final double min;
  final double max;

  const TruckTypeRange(this.min, this.max);
}

class TruckTypeSpec {
  final TruckTypeRange? capacity;
  final TruckTypeRange? length;
  final TruckTypeRange? height;

  const TruckTypeSpec({this.capacity, this.length, this.height});
}

const truckTypeSpecs = <String, TruckTypeSpec>{
  'Open Body': TruckTypeSpec(
    capacity: TruckTypeRange(4, 35),
    length: TruckTypeRange(14, 32),
  ),
  'Closed Body': TruckTypeSpec(
    capacity: TruckTypeRange(4, 35),
    length: TruckTypeRange(14, 36),
    height: TruckTypeRange(8, 11),
  ),
  'Sidewall Trailer': TruckTypeSpec(
    capacity: TruckTypeRange(20, 42),
    length: TruckTypeRange(30, 50),
  ),
  'Flat Bed Trailer': TruckTypeSpec(
    capacity: TruckTypeRange(20, 42),
    length: TruckTypeRange(20, 50),
  ),
  'Flat Bed Truck': TruckTypeSpec(
    capacity: TruckTypeRange(7, 25),
    length: TruckTypeRange(20, 38),
  ),
  'Low Bed Trailer': TruckTypeSpec(
    capacity: TruckTypeRange(20, 100),
    length: TruckTypeRange(30, 50),
  ),
  // No length field — the reference table lists "cbm" (volume) instead of
  // a feet range for these two bulk-cargo types.
  'Bulker': TruckTypeSpec(capacity: TruckTypeRange(20, 85)),
  'Tipper': TruckTypeSpec(capacity: TruckTypeRange(10, 50)),
  'Puller': TruckTypeSpec(
    capacity: TruckTypeRange(35, 200),
    length: TruckTypeRange(20, 300),
  ),
  // No capacity field — blank in the reference table.
  'Windblade Trailer': TruckTypeSpec(length: TruckTypeRange(40, 240)),
  'Refrigerated Truck': TruckTypeSpec(
    length: TruckTypeRange(14, 36),
    height: TruckTypeRange(8, 11),
  ),
  'Pickup Truck/Tata Ace': TruckTypeSpec(
    capacity: TruckTypeRange(0.8, 2),
    length: TruckTypeRange(6, 14),
  ),
};

/// Accepted margin around a height range's stated min/max — e.g. a
/// stated 8-11ft range accepts 7.5-11.5ft.
const heightRangeMarginFt = 0.5;

/// Wheel-picker step for a capacity range: 5-ton increments for very wide
/// ranges (span > 100, e.g. Puller's 35-200) so the wheel doesn't have to
/// scroll through hundreds of entries; a finer 0.2-ton step for small
/// fractional ranges (e.g. Pickup Truck's 0.8-2); otherwise whole tons.
double capacityStep(TruckTypeRange range) {
  final span = range.max - range.min;
  if (span > 100) return 5;
  if (range.max <= 5) return 0.2;
  return 1;
}

/// Wheel-picker step for a length range: 5ft increments for very wide
/// ranges (span > 100, e.g. Puller's 20-300 or Windblade Trailer's
/// 40-240), otherwise whole feet.
double lengthStep(TruckTypeRange range) {
  final span = range.max - range.min;
  return span > 100 ? 5 : 1;
}

/// Wheel-picker step for a height range — always half-feet, since the
/// ±0.5ft accepted margin means the actual picker range's endpoints
/// (e.g. 7.5, 11.5) aren't whole numbers to begin with.
double heightStep(TruckTypeRange range) => 0.5;

/// Whole-ton capacity values for the search-trucks capacity filter, which
/// (unlike the add-truck form) always deals in whole tons — the search
/// API's capacity filter is an int. Fractional ranges (e.g. Pickup
/// Truck/Tata Ace's 0.8-2 ton) are rounded inward to the nearest whole
/// ton (1-2), rather than showing decimal values a search filter can't
/// use.
List<double> searchCapacityValues(TruckTypeRange range) {
  final min = range.min.ceil();
  final max = range.max.floor();
  final step = max - min > 100 ? 5 : 1;
  return [for (var v = min; v <= max; v += step) v.toDouble()];
}
