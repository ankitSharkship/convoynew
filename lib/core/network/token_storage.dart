import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'jwt_payload.dart';

class TokenStorage {
  static const _accessKey = 'access_token';

  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  Future<String?> getUserId() async {
    final token = await getAccessToken();
    if (token == null) return null;
    return decodeJwtPayload(token)?['sub'] as String?;
  }

  Future<void> save({required String accessToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
  }
}
