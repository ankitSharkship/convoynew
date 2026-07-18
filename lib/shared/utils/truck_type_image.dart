/// Maps a canonical truck type value (see [truckTypes] in
/// `truck_type_i18n.dart`) to its illustration asset. Returns null for
/// types that don't have a dedicated image yet — callers should fall back
/// to a generic icon rather than guessing at a picture.
String? truckTypeImagePath(String rawType) {
  switch (rawType) {
    case 'Open Body':
      return 'assets/trucks/open_body.webp';
    case 'Closed Body':
      return 'assets/trucks/closed_body.webp';
    case 'Tipper':
      return 'assets/trucks/tipper.webp';
    case 'Sidewall Trailer':
      return 'assets/trucks/sidewall_trailer.webp';
    case 'Flat Bed Trailer':
      return 'assets/trucks/flat_bed_trailer.webp';
    case 'Flat Bed Truck':
      return 'assets/trucks/flat_bed_truck.webp';
    case 'Low Bed Trailer':
      return 'assets/trucks/low_bed_trailer.webp';
    case 'Refrigerated Truck':
      return 'assets/trucks/refrigerated.webp';
    case 'Bulker':
      return 'assets/trucks/bulker.webp';
    // No dedicated tanker photo yet — bulker is the closest visual stand-in
    // (both are cylindrical tank trucks) until a real one is provided.
    case 'Tanker':
      return 'assets/trucks/bulker.webp';
    default:
      return null;
  }
}
