import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> hasSeen();
  Future<void> markSeen();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const _key = 'onboarding_seen';
  final SharedPreferences _prefs;

  OnboardingLocalDataSourceImpl(this._prefs);

  @override
  Future<bool> hasSeen() async => _prefs.getBool(_key) ?? false;

  @override
  Future<void> markSeen() async => _prefs.setBool(_key, true);
}
