import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  String? getPhotoPath();
  Future<void> savePhotoPath(String path);
  Future<void> clearPhotoPath();

  ProfileModel? getCachedProfile();
  Future<void> saveProfile(ProfileModel profile);
  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const _photoKey = 'profile_photo_path';
  static const _profileCacheKey = 'user_profile_cache';

  final SharedPreferences _prefs;

  ProfileLocalDataSourceImpl(this._prefs);

  @override
  String? getPhotoPath() => _prefs.getString(_photoKey);

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
          jsonDecode(raw) as Map<String, dynamic>);
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
}
