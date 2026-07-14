import '../entities/kyc_entity.dart';
import '../repositories/kyc_repository.dart';

class GetKycStatusUseCase {
  final KycRepository _repository;

  GetKycStatusUseCase(this._repository);

  Future<KycStatusEntity> execute(String userId) => _repository.getStatus(userId);
}
