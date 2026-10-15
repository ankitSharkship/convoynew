import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/profile_model.dart';

/// Raw bytes of a downloaded profile photo, plus the content-type the
/// server reported for it (used to pick a file extension when caching it).
class ProfilePhotoBytes {
  final List<int> bytes;
  final String contentType;

  const ProfilePhotoBytes({required this.bytes, required this.contentType});
}

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
  Future<ProfileModel> updateProfile(String userId, String name);
  Future<void> uploadProfilePhoto(String userId, File imageFile);

  /// Returns null if the user has no profile photo uploaded yet (404).
  Future<ProfilePhotoBytes?> downloadProfilePhoto(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _dio.get('/api/user/profile/$userId');
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) return null;
      return ProfileModel.fromJson(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<ProfileModel> updateProfile(String userId, String name) async {
    try {
      final response = await _dio.put(
        '/api/user/profile/$userId',
        data: {'name': name},
      );
      final data = response.data as Map<String, dynamic>;
      final user = (data['user'] as Map<String, dynamic>?) ?? data;
      return ProfileModel.fromJson(user);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<void> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      await _dio.post('/api/user/profile-photo/$userId', data: formData);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<ProfilePhotoBytes?> downloadProfilePhoto(String userId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/user/profile-photo/$userId',
        options: Options(responseType: ResponseType.bytes),
      );
      final contentType =
          response.headers.value('content-type') ?? 'image/jpeg';
      return ProfilePhotoBytes(bytes: response.data!, contentType: contentType);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
