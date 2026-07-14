import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestOtp(String phone);
  Future<AuthSessionModel> verifyOtp(String phone, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> requestOtp(String phone) async {
    try {
      await _dio.post(
        '/api/auth/send-otp',
        data: {'mobile': _withCountryCode(phone)},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<AuthSessionModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        '/api/auth/verify-otp',
        data: {'mobile': _withCountryCode(phone), 'otp': otp},
      );
      return AuthSessionModel.fromJson(
        phone,
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  String _withCountryCode(String phone) =>
      phone.startsWith('+') ? phone : '+91$phone';
}
