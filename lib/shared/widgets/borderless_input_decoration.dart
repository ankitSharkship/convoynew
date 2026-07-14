import 'package:flutter/material.dart';

/// A text-field decoration with every border state explicitly suppressed.
///
/// The app's global [InputDecorationTheme] (see `core/theme/app_theme.dart`)
/// sets a visible `focusedBorder`. Setting only `border: InputBorder.none`
/// on a field doesn't clear that — Flutter falls back to the theme's
/// `focusedBorder` once the field gains focus, so a stray outline shows up
/// on any "borderless" field nested inside a custom-styled card. This
/// nulls out every border state so that never happens.
InputDecoration borderlessInputDecoration({
  String? hintText,
  TextStyle? hintStyle,
  EdgeInsetsGeometry? contentPadding,
  String? counterText,
  bool isDense = false,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    hintText: hintText,
    hintStyle: hintStyle,
    contentPadding: contentPadding,
    counterText: counterText,
    isDense: isDense,
    filled: false,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
  );
}
