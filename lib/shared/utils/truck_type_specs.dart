/// Placeholder physical-spec data per truck type (length/breadth/height
/// options in feet, and compatible capacity options in tons), plus the
/// reverse capacity -> truck type lookup.
///
/// Not wired into any UI or API yet — the vehicle-add/search endpoints
/// don't accept these fields today. Values below are illustrative
/// placeholders only, to be replaced with real specs once the backend
/// contract for vehicle dimensions is finalized.
library;

class TruckTypeSpec {
  final List<double> lengthsFt;
  final List<double> breadthsFt;
  final List<double> heightsFt;
  final List<int> capacitiesTon;

  const TruckTypeSpec({
    required this.lengthsFt,
    required this.breadthsFt,
    required this.heightsFt,
    required this.capacitiesTon,
  });
}

const truckTypeSpecs = <String, TruckTypeSpec>{
  'Open Body': TruckTypeSpec(
    lengthsFt: [14, 17, 19, 22],
    breadthsFt: [6, 7],
    heightsFt: [6, 7],
    capacitiesTon: [9, 16, 21],
  ),
  'Closed Body': TruckTypeSpec(
    lengthsFt: [14, 17, 19],
    breadthsFt: [6, 7],
    heightsFt: [6, 7],
    capacitiesTon: [9, 16],
  ),
  'Tipper': TruckTypeSpec(
    lengthsFt: [12, 14],
    breadthsFt: [7, 8],
    heightsFt: [5, 6],
    capacitiesTon: [16, 21, 25],
  ),
  'Sidewall Trailer': TruckTypeSpec(
    lengthsFt: [28, 32],
    breadthsFt: [8],
    heightsFt: [7],
    capacitiesTon: [25, 30, 35],
  ),
  'Flat Bed Trailer': TruckTypeSpec(
    lengthsFt: [28, 32, 40],
    breadthsFt: [8],
    heightsFt: [4],
    capacitiesTon: [25, 30, 35],
  ),
  'Flat Bed Truck': TruckTypeSpec(
    lengthsFt: [19, 22],
    breadthsFt: [7],
    heightsFt: [4],
    capacitiesTon: [16, 21],
  ),
  'Low Bed Trailer': TruckTypeSpec(
    lengthsFt: [32, 40],
    breadthsFt: [8],
    heightsFt: [4],
    capacitiesTon: [30, 35],
  ),
  'Refrigerated Truck': TruckTypeSpec(
    lengthsFt: [17, 19, 22],
    breadthsFt: [7],
    heightsFt: [7],
    capacitiesTon: [9, 16],
  ),
  'Bulker': TruckTypeSpec(
    lengthsFt: [32],
    breadthsFt: [8],
    heightsFt: [8],
    capacitiesTon: [25, 30],
  ),
  'Tanker': TruckTypeSpec(
    lengthsFt: [28, 32],
    breadthsFt: [8],
    heightsFt: [8],
    capacitiesTon: [21, 25, 30],
  ),
};

const capacityToTruckTypes = <int, List<String>>{
  9: ['Open Body', 'Closed Body', 'Refrigerated Truck'],
  16: ['Open Body', 'Closed Body', 'Tipper', 'Refrigerated Truck', 'Flat Bed Truck'],
  21: ['Open Body', 'Tipper', 'Flat Bed Truck', 'Tanker'],
  25: ['Tipper', 'Sidewall Trailer', 'Flat Bed Trailer', 'Bulker', 'Tanker'],
  30: ['Sidewall Trailer', 'Flat Bed Trailer', 'Low Bed Trailer', 'Bulker', 'Tanker'],
  35: ['Sidewall Trailer', 'Flat Bed Trailer', 'Low Bed Trailer'],
};
