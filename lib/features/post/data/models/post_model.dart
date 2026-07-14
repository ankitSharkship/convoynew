import 'dart:convert';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.truckType,
    required super.capacity,
    required super.origin,
    required super.destination,
    required super.vehicleNumber,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json['id'] as String,
        truckType: json['truckType'] as String,
        capacity: json['capacity'] as String,
        origin: json['origin'] as String,
        destination: json['destination'] as String,
        vehicleNumber: json['vehicleNumber'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'truckType': truckType,
        'capacity': capacity,
        'origin': origin,
        'destination': destination,
        'vehicleNumber': vehicleNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());
}
