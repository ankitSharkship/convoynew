import 'dart:convert';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.memberSince,
    required super.rating,
    required super.totalPosts,
    required super.activePosts,
    required super.mutualConnections,
    required super.callsMade,
    required super.responseRate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        memberSince: json['memberSince'] as String,
        rating: (json['rating'] as num).toDouble(),
        totalPosts: json['totalPosts'] as int,
        activePosts: json['activePosts'] as int,
        mutualConnections: json['mutualConnections'] as int,
        callsMade: json['callsMade'] as int,
        responseRate: json['responseRate'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'memberSince': memberSince,
        'rating': rating,
        'totalPosts': totalPosts,
        'activePosts': activePosts,
        'mutualConnections': mutualConnections,
        'callsMade': callsMade,
        'responseRate': responseRate,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String str) =>
      UserModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
