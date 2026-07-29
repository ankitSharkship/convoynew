import 'package:shared_preferences/shared_preferences.dart';

/// Caches only the fact that a specific user's KYC was seen as fully
/// approved — never any in-progress/pending state, since those can change
/// on every call and aren't worth short-circuiting. Once approved, it stays
/// approved in this domain, so serving that from cache indefinitely (until
/// explicitly cleared on logout) is safe.
abstract class KycLocalDataSource {
  /// True only if the cached approval belongs to exactly this [userId] —
  /// a leftover cache from a previous session belonging to a different
  /// user must never be read as "approved" for the current one.
  bool isApprovedFor(String userId);

  Future<void> markApproved(String userId);

  Future<void> clear();
}

class KycLocalDataSourceImpl implements KycLocalDataSource {
  static const _approvedUserIdKey = 'kyc_approved_user_id';

  final SharedPreferences _prefs;

  KycLocalDataSourceImpl(this._prefs);

  @override
  bool isApprovedFor(String userId) =>
      _prefs.getString(_approvedUserIdKey) == userId;

  @override
  Future<void> markApproved(String userId) async {
    await _prefs.setString(_approvedUserIdKey, userId);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_approvedUserIdKey);
  }
}
