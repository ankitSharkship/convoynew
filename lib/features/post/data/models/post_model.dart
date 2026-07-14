import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.vehicleId,
    required super.vehicleNumber,
    required super.truckType,
    required super.capacity,
    required super.originName,
    required super.destinationNames,
    required super.availableDate,
    required super.status,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final destinations = json['destinations'] as List<dynamic>? ?? [];
    return PostModel(
      id: json['_id'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      truckType: json['truckType'] as String,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      originName: json['originName'] as String? ??
          (json['origin'] as Map<String, dynamic>?)?['name'] as String? ??
          '',
      destinationNames: destinations
          .map((d) => (d as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      availableDate: json['availableDate'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
