import '../../domain/entities/auth_session_entity.dart';

class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.phone,
    required super.accessToken,
  });

  factory AuthSessionModel.fromJson(String phone, Map<String, dynamic> json) =>
      AuthSessionModel(
        phone: phone,
        accessToken: json['accessToken'] as String,
      );
}
