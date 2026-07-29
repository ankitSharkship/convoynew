import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/shared_preferences_provider.dart';

part 'locale_notifier.g.dart';

const supportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('mr'),
  Locale('kn'),
];

const _localePrefsKey = 'app_locale';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    final saved = ref
        .watch(sharedPreferencesProvider)
        .getString(_localePrefsKey);
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == saved,
      orElse: () => const Locale('en'),
    );
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_localePrefsKey, locale.languageCode);
  }
}
