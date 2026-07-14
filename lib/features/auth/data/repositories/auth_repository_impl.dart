import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<void> sendOtp(String phone) => _remote.requestOtp(phone);

  @override
  Future<AuthSessionEntity> verifyOtp(String phone, String otp) async {
    final session = await _remote.verifyOtp(phone, otp);
    await _local.saveSession(session);
    return session;
  }

  @override
  Future<AuthSessionEntity?> getSession() => _local.getSession();

  @override
  Future<void> logout() => _local.clearSession();
}
