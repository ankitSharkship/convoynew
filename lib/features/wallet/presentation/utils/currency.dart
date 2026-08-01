import 'package:intl/intl.dart';

/// Amounts arrive from the backend as strings (e.g. "150.00") — kept as
/// strings everywhere except here, where they're parsed purely for display.
String formatRupees(String amount) {
  final value = double.tryParse(amount) ?? 0;
  return '₹${NumberFormat('#,##0.00', 'en_IN').format(value)}';
}
