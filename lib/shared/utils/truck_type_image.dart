/// Maps a canonical truck type value (see [truckTypes] in
/// `truck_type_i18n.dart`) to its illustration asset. Returns null for
/// types that don't have a dedicated image yet — callers should fall back
/// to a generic icon rather than guessing at a picture.
String? truckTypeImagePath(String rawType) {
  switch (rawType) {
    case 'Open Body':
      return 'assets/trucks/open_body.png';
    case 'Closed Body':
      return 'assets/trucks/closed_body.png';
    case 'Tipper':
      return 'assets/trucks/tipper.png';
    case 'Sidewall Trailer':
      return 'assets/trucks/sidewall_trailer.png';
    case 'Flat Bed Trailer':
      return 'assets/trucks/flat_bed_trailer.png';
    case 'Flat Bed Truck':
      return 'assets/trucks/flat_bed_truck.png';
    case 'Low Bed Trailer':
      return 'assets/trucks/low_bed_trailer.png';
    case 'Refrigerated Truck':
      return 'assets/trucks/refrigerated.png';
    case 'Bulker':
      return 'assets/trucks/bulker.png';
    // No dedicated tanker photo yet — bulker is the closest visual stand-in
    // (both are cylindrical tank trucks) until a real one is provided.
    case 'Tanker':
      return 'assets/trucks/bulker.png';
    default:
      return null;
  }
}
