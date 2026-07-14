import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_session_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSessionEntity session);
  Future<AuthSessionEntity?> getSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _phoneKey = 'auth_phone';

  final SharedPreferences _prefs;
  final TokenStorage _tokenStorage;

  AuthLocalDataSourceImpl(this._prefs, this._tokenStorage);

  @override
  Future<void> saveSession(AuthSessionEntity session) async {
    await _prefs.setString(_phoneKey, session.phone);
    await _tokenStorage.save(accessToken: session.accessToken);
  }

  @override
  Future<AuthSessionEntity?> getSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null) return null;
    return AuthSessionEntity(
      phone: _prefs.getString(_phoneKey) ?? '',
      accessToken: accessToken,
    );
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_phoneKey);
    await _tokenStorage.clear();
  }
}
