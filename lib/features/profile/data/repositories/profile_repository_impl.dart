import '../../../../core/network/token_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;
  final TokenStorage _tokenStorage;

  ProfileRepositoryImpl(this._remote, this._local, this._tokenStorage);

  @override
  ProfileEntity? getCachedProfile() {
    final cached = _local.getCachedProfile();
    if (cached == null) return null;
    return _toEntity(cached);
  }

  @override
  Future<ProfileEntity> getProfile() async {
    final userId = await _tokenStorage.getUserId();
    ProfileModel? remoteProfile;
    if (userId != null) {
      remoteProfile = await _remote.getProfile(userId);
    }
    if (remoteProfile != null) {
      await _local.saveProfile(remoteProfile);
    }
    final profile = remoteProfile ?? _local.getCachedProfile();
    return _toEntity(profile);
  }

  @override
  Future<ProfileEntity> updatePhotoPath(String path) async {
    await _local.savePhotoPath(path);
    return getProfile();
  }

  ProfileEntity _toEntity(ProfileModel? profile) {
    final photoPath = _local.getPhotoPath();
    return ProfileEntity(
      name: (profile?.name.isNotEmpty ?? false) ? profile!.name : 'Pilot',
      phone: profile?.mobile ?? '',
      memberSince: _formatMemberSince(profile?.createdDate),
      rating: 0,
      totalPosts: 0,
      callsMade: 0,
      responseRate: 0,
      kycStatus: profile?.kycStatus ?? 'not_started',
      accountStatus: profile?.accountStatus ?? 'active',
      photoPath: photoPath,
      profilePhotoUrl: profile?.profilePhotoUrl,
    );
  }

  String _formatMemberSince(DateTime? date) {
    if (date == null) return '';
    return '${_months[date.month - 1]} ${date.year}';
  }
}
