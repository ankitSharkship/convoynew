import '../entities/kyc_entity.dart';
import '../repositories/kyc_repository.dart';

class CheckAadhaarAvailabilityUseCase {
  final KycRepository _repository;

  CheckAadhaarAvailabilityUseCase(this._repository);

  Future<AadhaarAvailabilityEntity> execute({
    required String userId,
    required String aadhaarNumber,
  }) => _repository.checkAadhaarAvailability(
    userId: userId,
    aadhaarNumber: aadhaarNumber,
  );
}
