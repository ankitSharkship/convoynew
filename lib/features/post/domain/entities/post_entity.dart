class PostEntity {
  final String id;
  final String vehicleId;
  final String vehicleNumber;
  final String truckType;
  final int capacity;
  final String originName;
  final List<String> destinationNames;
  final String availableDate;
  final String status;
  final DateTime createdAt;
  final String? contactName;
  final String? contactNumber;

  const PostEntity({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.truckType,
    required this.capacity,
    required this.originName,
    required this.destinationNames,
    required this.availableDate,
    required this.status,
    required this.createdAt,
    this.contactName,
    this.contactNumber,
  });
}
