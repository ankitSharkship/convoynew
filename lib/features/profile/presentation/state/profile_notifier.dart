import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_cached_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_notifier.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(ProfileRemoteDataSourceRef ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(dioProvider));
}

@riverpod
ProfileLocalDataSource profileLocalDataSource(ProfileLocalDataSourceRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSourceImpl(prefs);
}

@riverpod
ProfileRepositoryImpl profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    ref.watch(profileLocalDataSourceProvider),
    ref.watch(tokenStorageProvider),
  );
}

@riverpod
GetProfileUseCase getProfileUseCase(GetProfileUseCaseRef ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
GetCachedProfileUseCase getCachedProfileUseCase(GetCachedProfileUseCaseRef ref) {
  return GetCachedProfileUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
UpdateProfilePhotoUseCase updateProfilePhotoUseCase(
    UpdateProfilePhotoUseCaseRef ref) {
  return UpdateProfilePhotoUseCase(ref.watch(profileRepositoryProvider));
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<ProfileEntity> build() async {
    final cached = ref.watch(getCachedProfileUseCaseProvider).execute();
    if (cached != null) {
      Future.microtask(_refreshInBackground);
      return cached;
    }
    return ref.watch(getProfileUseCaseProvider).execute();
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await ref.read(getProfileUseCaseProvider).execute();
      if (!_isSameProfile(state.valueOrNull, fresh)) {
        state = AsyncData(fresh);
      }
    } catch (_) {
      // Keep showing the cached profile if the background refresh fails.
    }
  }

  bool _isSameProfile(ProfileEntity? a, ProfileEntity b) {
    if (a == null) return false;
    return a.name == b.name &&
        a.phone == b.phone &&
        a.memberSince == b.memberSince &&
        a.kycStatus == b.kycStatus &&
        a.accountStatus == b.accountStatus &&
        a.photoPath == b.photoPath &&
        a.profilePhotoUrl == b.profilePhotoUrl;
  }

  Future<void> updatePhoto(String photoPath) async {
    final useCase = ref.read(updateProfilePhotoUseCaseProvider);
    final updated = await useCase.execute(photoPath);
    state = AsyncData(updated);
  }
}
