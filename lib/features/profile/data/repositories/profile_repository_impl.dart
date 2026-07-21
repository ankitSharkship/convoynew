import 'dart:io';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

const _extensionsByContentType = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/heic': 'heic',
};

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
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
      await _ensurePhotoCached();
    }
    final profile = remoteProfile ?? _local.getCachedProfile();
    return _toEntity(profile);
  }

  /// Makes sure a displayable local copy of the profile photo exists,
  /// downloading it from the server if needed. A cheap no-op once a local
  /// capture or a previously-cached remote copy is already on disk — safe
  /// to call as often as [getProfile] itself runs (app open, viewing the
  /// profile page, pull-to-refresh, etc.), and awaited here so the entity
  /// [getProfile] returns is always consistent with what's on disk — no
  /// separate fire-and-forget step for the UI to race against.
  Future<void> _ensurePhotoCached() async {
    if (_local.getPhotoPath() != null || _local.getRemotePhotoPath() != null) {
      return;
    }
    try {
      await cacheProfilePhotoFromServer();
    } catch (_) {
      // Non-fatal — the profile still loads fine without a photo; we'll
      // simply try again the next time getProfile() runs.
    }
  }

  @override
  Future<ProfileEntity> updatePhotoPath(String path) async {
    await _local.savePhotoPath(path);
    return getProfile();
  }

  @override
  Future<void> uploadPhoto(File imageFile) async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) throw const ApiException();
    await _remote.uploadProfilePhoto(userId, imageFile);
  }

  @override
  Future<void> cacheProfilePhotoFromServer() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) return;
    final photo = await _remote.downloadProfilePhoto(userId);
    if (photo == null) return;
    final extension = _extensionsByContentType[photo.contentType] ?? 'jpg';
    await _local.saveRemotePhoto(photo.bytes, extension);
  }

  ProfileEntity _toEntity(ProfileModel? profile) {
    // The freshest on-device capture always wins; the copy downloaded from
    // the server (see _ensurePhotoCached) is the fallback for when there's
    // no local capture yet (e.g. a fresh install/re-login).
    final photoPath = _local.getPhotoPath() ?? _local.getRemotePhotoPath();
    return ProfileEntity(
      id: profile?.id ?? '',
      name: (profile?.name.isNotEmpty ?? false) ? profile!.name : 'Pilot',
      phone: profile?.mobile ?? '',
      memberSince: _formatMemberSince(profile?.createdDate),
      rating: 0,
      totalPosts: 0,
      callsMade: 0,
      responseRate: 0,
      kycStatus: profile?.kycStatus ?? 'not_started',
      kycStep: profile?.kycStep,
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
