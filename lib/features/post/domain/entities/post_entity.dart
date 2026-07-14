class PostEntity {
  final String id;
  final String truckType;
  final String capacity;
  final String origin;
  final String destination;
  final String vehicleNumber;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.truckType,
    required this.capacity,
    required this.origin,
    required this.destination,
    required this.vehicleNumber,
    required this.createdAt,
  });
}
