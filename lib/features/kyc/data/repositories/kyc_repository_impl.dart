import '../../domain/entities/kyc_entity.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_local_datasource.dart';
import '../datasources/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource _remote;
  final KycLocalDataSource _local;

  KycRepositoryImpl(this._remote, this._local);

  @override
  Future<KycStatusEntity> getStatus(String userId) async {
    // Already confirmed approved for this exact user in a previous call —
    // no need to hit the network again just to be told the same thing.
    if (_local.isApprovedFor(userId)) {
      return const KycStatusEntity(status: 'approved');
    }

    final status = await _remote.getStatus(userId);
    if (status.isApproved) {
      await _local.markApproved(userId);
    }
    return status;
  }

  @override
  Future<SendAadhaarOtpResultEntity> sendAadhaarOtp({
    required String userId,
    required String aadhaarNumber,
  }) => _remote.sendAadhaarOtp(userId: userId, aadhaarNumber: aadhaarNumber);

  @override
  Future<VerifyAadhaarOtpResultEntity> verifyAadhaarOtp({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  }) => _remote.verifyAadhaarOtp(
    userId: userId,
    refId: refId,
    otp: otp,
    aadhaarNumber: aadhaarNumber,
  );

  @override
  Future<AadhaarAvailabilityEntity> checkAadhaarAvailability({
    required String userId,
    required String aadhaarNumber,
  }) => _remote.checkAadhaarAvailability(
    userId: userId,
    aadhaarNumber: aadhaarNumber,
  );
}
