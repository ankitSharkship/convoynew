import '../entities/auth_session_entity.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<AuthSessionEntity> verifyOtp(String phone, String otp);
  Future<AuthSessionEntity?> getSession();
  Future<void> logout();
}
