import 'dart:convert';

class VehicleModel {
  final String number;
  final String type;
  final String capacity;

  const VehicleModel({
    required this.number,
    required this.type,
    required this.capacity,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        number: json['number'] as String,
        type: json['type'] as String,
        capacity: json['capacity'] as String,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type,
        'capacity': capacity,
      };

  String toJsonString() => jsonEncode(toJson());
}
