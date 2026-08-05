import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/exceptions/aadhaar_conflict_exception.dart';
import '../models/kyc_model.dart';

abstract class KycRemoteDataSource {
  Future<KycStatusEntity> getStatus(String userId);

  Future<SendAadhaarOtpResultEntity> sendAadhaarOtp({
    required String userId,
    required String aadhaarNumber,
  });

  Future<VerifyAadhaarOtpResultEntity> verifyAadhaarOtp({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  });

  Future<AadhaarAvailabilityEntity> checkAadhaarAvailability({
    required String userId,
    required String aadhaarNumber,
  });
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final Dio _dio;

  KycRemoteDataSourceImpl(this._dio);

  @override
  Future<KycStatusEntity> getStatus(String userId) async {
    try {
      final response = await _dio.get('/api/kyc/status/$userId');
      return KycStatusModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<SendAadhaarOtpResultEntity> sendAadhaarOtp({
    required String userId,
    required String aadhaarNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/kyc/aadhaar/send-otp/$userId',
        data: {'aadhaarNumber': aadhaarNumber},
      );
      return SendAadhaarOtpResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<VerifyAadhaarOtpResultEntity> verifyAadhaarOtp({
    required String userId,
    required String refId,
    required String otp,
    required String aadhaarNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/kyc/aadhaar/verify/$userId',
        data: {'refId': refId, 'otp': otp, 'aadhaarNumber': aadhaarNumber},
      );
      return VerifyAadhaarOtpResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // The OTP itself was valid — this Aadhaar just lost a race with
      // another account's verification landing first at the final DB
      // commit (the partial-unique-index safety net). Retrying the same
      // OTP, or even the same Aadhaar, can never succeed, so this needs
      // to be distinguishable from an ordinary verify failure (e.g. wrong
      // OTP) rather than surfaced as a generic retryable error.
      if (e.response?.statusCode == 409) {
        throw AadhaarConflictException(
          ApiException.fromDioException(e).message,
        );
      }
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<AadhaarAvailabilityEntity> checkAadhaarAvailability({
    required String userId,
    required String aadhaarNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/kyc/aadhaar/check/$userId',
        data: {'aadhaarNumber': aadhaarNumber},
      );
      return AadhaarAvailabilityModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
