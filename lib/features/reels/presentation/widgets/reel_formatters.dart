import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

/// Resolves an API-relative path (e.g. `/api/user/profile-photo/{id}`) against
/// `API_BASE_URL`; absolute URLs pass through.
String resolveApiUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final base = dotenv.env['API_BASE_URL'] ?? '';
  return Uri.parse(base).resolve(url).toString();
}

/// 1200 -> "1.2K", 3400000 -> "3.4M"; small numbers are shown as-is.
String formatCount(int count) =>
    NumberFormat.compact(locale: 'en').format(count);
