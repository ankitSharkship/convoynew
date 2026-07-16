import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/device_contact_entity.dart';
import '../../domain/entities/mutual_contact_entity.dart';
import '../models/mutual_contact_model.dart';

abstract class ContactsRemoteDataSource {
  Future<void> syncContacts({
    required String userId,
    required List<DeviceContactEntity> contacts,
  });

  Future<List<MutualContactEntity>> getMutualContacts({
    required String searcherUserId,
    required String otherUserId,
  });
}

class ContactsRemoteDataSourceImpl implements ContactsRemoteDataSource {
  final Dio _dio;

  ContactsRemoteDataSourceImpl(this._dio);

  @override
  Future<void> syncContacts({
    required String userId,
    required List<DeviceContactEntity> contacts,
  }) async {
    try {
      await _dio.post(
        '/api/contacts/sync/$userId',
        data: {'contacts': _toSyncPayload(contacts)},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }

  @override
  Future<List<MutualContactEntity>> getMutualContacts({
    required String searcherUserId,
    required String otherUserId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/contacts/mutual/$searcherUserId',
        queryParameters: {'otherUserId': otherUserId},
      );
      return mutualContactsFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (_) {
      throw const ApiException();
    }
  }
}

// Confirmed against the real API: each entry needs both `name` and
// `hashedNumber` (a bare hash-only payload 422s).
List<Map<String, dynamic>> _toSyncPayload(List<DeviceContactEntity> contacts) {
  final seen = <String>{};
  return contacts
      .where((c) => seen.add(c.hashedNumber))
      .map((c) => {'name': c.name, 'hashedNumber': c.hashedNumber})
      .toList();
}
