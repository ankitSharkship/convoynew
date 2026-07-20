import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  String? getPhotoPath();
  Future<void> savePhotoPath(String path);
  Future<void> clearPhotoPath();

  ProfileModel? getCachedProfile();
  Future<void> saveProfile(ProfileModel profile);
  Future<void> clearProfile();

  /// The locally-cached copy of the photo downloaded once at login (see
  /// [saveRemotePhoto]) — distinct from [getPhotoPath], which is the file
  /// from the most recent on-device capture.
  String? getRemotePhotoPath();
  Future<String> saveRemotePhoto(List<int> bytes, String extension);
  Future<void> clearRemotePhoto();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const _photoKey = 'profile_photo_path';
  static const _profileCacheKey = 'user_profile_cache';
  static const _remotePhotoPathKey = 'profile_remote_photo_path';

  final SharedPreferences _prefs;

  ProfileLocalDataSourceImpl(this._prefs);

  @override
  String? getPhotoPath() {
    final path = _prefs.getString(_photoKey);
    // A capture from a previous install/session can vanish from disk (the
    // camera plugin writes to a temp dir the OS is free to clear) while the
    // path string stays in prefs — without this check, a stale non-null
    // path here would permanently shadow the (still valid) remote-cached
    // photo in _toEntity's `getPhotoPath() ?? getRemotePhotoPath()`.
    if (path == null || !File(path).existsSync()) return null;
    return path;
  }

  @override
  Future<void> savePhotoPath(String path) async {
    await _prefs.setString(_photoKey, path);
  }

  @override
  Future<void> clearPhotoPath() async {
    await _prefs.remove(_photoKey);
  }

  @override
  ProfileModel? getCachedProfile() {
    final raw = _prefs.getString(_profileCacheKey);
    if (raw == null) return null;
    try {
      return ProfileModel.fromCacheJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await _prefs.setString(_profileCacheKey, jsonEncode(profile.toCacheJson()));
  }

  @override
  Future<void> clearProfile() async {
    await _prefs.remove(_profileCacheKey);
  }

  @override
  String? getRemotePhotoPath() {
    final path = _prefs.getString(_remotePhotoPathKey);
    if (path == null || !File(path).existsSync()) return null;
    return path;
  }

  @override
  Future<String> saveRemotePhoto(List<int> bytes, String extension) async {
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/profile_remote_photo.$extension';
    await File(path).writeAsBytes(bytes, flush: true);
    await _prefs.setString(_remotePhotoPathKey, path);
    return path;
  }

  @override
  Future<void> clearRemotePhoto() async {
    final path = _prefs.getString(_remotePhotoPathKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _prefs.remove(_remotePhotoPathKey);
  }
}
