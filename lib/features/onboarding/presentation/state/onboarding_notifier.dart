import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/usecases/check_onboarding_seen_usecase.dart';
import '../../domain/usecases/mark_onboarding_seen_usecase.dart';

part 'onboarding_notifier.g.dart';

@riverpod
OnboardingLocalDataSource onboardingLocalDataSource(
    OnboardingLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalDataSourceImpl(prefs);
}

@riverpod
OnboardingRepositoryImpl onboardingRepository(OnboardingRepositoryRef ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider));
}

@riverpod
CheckOnboardingSeenUseCase checkOnboardingSeenUseCase(
    CheckOnboardingSeenUseCaseRef ref) {
  return CheckOnboardingSeenUseCase(ref.watch(onboardingRepositoryProvider));
}

@riverpod
MarkOnboardingSeenUseCase markOnboardingSeenUseCase(
    MarkOnboardingSeenUseCaseRef ref) {
  return MarkOnboardingSeenUseCase(ref.watch(onboardingRepositoryProvider));
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<bool> build() async {
    final useCase = ref.watch(checkOnboardingSeenUseCaseProvider);
    return useCase.execute();
  }

  Future<void> markSeen() async {
    final useCase = ref.read(markOnboardingSeenUseCaseProvider);
    await useCase.execute();
  }
}
