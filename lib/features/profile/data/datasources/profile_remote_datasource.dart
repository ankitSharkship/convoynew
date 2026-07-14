import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile(String userId);
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
}
