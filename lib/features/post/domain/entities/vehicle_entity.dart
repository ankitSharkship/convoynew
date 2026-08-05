class VehicleEntity {
  final String id;
  final String vehicleNumber;
  final String truckType;
  final double capacity;
  final String verificationStatus;

  /// Both optional (feet) — null whenever the truck type doesn't have that
  /// dimension collected (see `truck_type_specs.dart`), or the vehicle was
  /// added before this data started being collected at all.
  final double? length;
  final double? height;

  const VehicleEntity({
    required this.id,
    required this.vehicleNumber,
    required this.truckType,
    required this.capacity,
    required this.verificationStatus,
    this.length,
    this.height,
  });
}
