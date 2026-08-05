import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// Renders a picker value without a trailing ".0" for whole numbers (e.g.
/// so `l10n.capacityTon(displayNum(20.0))` reads "20 Ton" rather than
/// "20.0 Ton"), while still showing real decimals (e.g. "0.8 Ton") as-is.
num displayNum(double value) =>
    value == value.roundToDouble() ? value.round() : value;

/// Every `min + i*step` up to `max`, rounded to 2 decimals so floating
/// point summation never renders as e.g. "1.7999999999999998".
List<double> wheelPickerValues({
  required double min,
  required double max,
  required double step,
}) {
  final count = ((max - min) / step).round() + 1;
  return List.generate(count, (i) {
    final raw = min + i * step;
    return double.parse(raw.toStringAsFixed(2));
  });
}

/// A scrolling wheel for picking one value out of [values] — the same
/// "spin to choose" feel as a clock app's time picker — shown as a modal
/// bottom sheet. Returns the chosen value, or null if dismissed without
/// confirming.
Future<double?> showWheelNumberPickerSheet(
  BuildContext context, {
  required String title,
  required List<double> values,
  required double? initialValue,
  required String Function(double value) labelBuilder,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WheelNumberPickerSheet(
      title: title,
      values: values,
      initialValue: initialValue,
      labelBuilder: labelBuilder,
    ),
  );
}

class _WheelNumberPickerSheet extends StatefulWidget {
  final String title;
  final List<double> values;
  final double? initialValue;
  final String Function(double value) labelBuilder;

  const _WheelNumberPickerSheet({
    required this.title,
    required this.values,
    required this.initialValue,
    required this.labelBuilder,
  });

  @override
  State<_WheelNumberPickerSheet> createState() =>
      _WheelNumberPickerSheetState();
}

class _WheelNumberPickerSheetState extends State<_WheelNumberPickerSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _selectedIndex = initial == null ? 0 : _closestIndex(initial);
  }

  int _closestIndex(double target) {
    var closest = 0;
    var closestDiff = (widget.values[0] - target).abs();
    for (var i = 1; i < widget.values.length; i++) {
      final diff = (widget.values[i] - target).abs();
      if (diff < closestDiff) {
        closest = i;
        closestDiff = diff;
      }
    }
    return closest;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(
                height: 180,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (i) =>
                      setState(() => _selectedIndex = i),
                  children: widget.values
                      .map(
                        (v) => Center(
                          child: Text(
                            widget.labelBuilder(v),
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, widget.values[_selectedIndex]),
                  child: Text(l10n.wheelPickerDoneButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
