import 'package:flutter/services.dart';

/// Formats a raw string (with or without a country code / separators) into
/// the display form `XXXXX XXXXX`, using only the last 10 digits.
String formatPhoneDisplay(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final last10 = digits.length > 10
      ? digits.substring(digits.length - 10)
      : digits;
  if (last10.length <= 5) return last10;
  return '${last10.substring(0, 5)} ${last10.substring(5)}';
}

/// Formats raw digit input into a 10-digit mobile number as `XXXXX XXXXX`.
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(limited[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
