import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource _remote;

  KycRepositoryImpl(this._remote);

  @override
  Future<KycStatusEntity> getStatus(String userId) => _remote.getStatus(userId);

  @override
  Future<SendAadhaarOtpResultEntity> sendAadhaarOtp({
    required String userId,
    required String aadhaarNumber,
  }) =>
      _remote.sendAadhaarOtp(userId: userId, aadhaarNumber: aadhaarNumber);

  @override
  Future<VerifyAadhaarOtpResultEntity> verifyAadhaarOtp({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  }) =>
      _remote.verifyAadhaarOtp(
        userId: userId,
        refId: refId,
        otp: otp,
        aadhaarNumber: aadhaarNumber,
      );
}
