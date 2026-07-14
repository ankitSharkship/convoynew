import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  OnboardingRepositoryImpl(this._dataSource);

  @override
  Future<bool> hasSeen() => _dataSource.hasSeen();

  @override
  Future<void> markSeen() => _dataSource.markSeen();
}
