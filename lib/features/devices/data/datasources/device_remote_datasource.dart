import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';

abstract class DeviceRemoteDataSource {
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String fcmToken,
    String? appVersion,
    String? deviceName,
  });

  Future<void> logoutDevice({
    required String userId,
    required String deviceId,
  });
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio _dio;

  DeviceRemoteDataSourceImpl(this._dio);

  @override
  Future<void> registerDevice({
    required String userId,
    required String deviceId,
    required String platform,
    required String fcmToken,
    String? appVersion,
    String? deviceName,
  }) async {
    try {
      await _dio.post(
        '/api/user/devices/register/$userId',
        data: {
          'deviceId': deviceId,
          'platform': platform,
          'fcmToken': fcmToken,
          'appVersion': ?appVersion,
          'deviceName': ?deviceName,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<void> logoutDevice({
    required String userId,
    required String deviceId,
  }) async {
    try {
      await _dio.post(
        '/api/user/devices/logout/$userId',
        data: {'deviceId': deviceId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}
