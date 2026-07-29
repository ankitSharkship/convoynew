import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main.dart` with the real instance once it's available at
/// startup. Lives in its own file (rather than `app_router.dart`, where it
/// used to live) so core files like `dio_client.dart` can depend on it
/// without creating an import cycle back through the router.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in main'),
);
