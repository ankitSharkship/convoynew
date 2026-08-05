import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/utils/truck_type_specs.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../../../../shared/widgets/truck_type_thumbnail.dart';
import '../../../../shared/widgets/wheel_number_picker.dart';
import '../../../search/presentation/widgets/truck_type_sheet.dart';
import '../state/vehicle_notifier.dart';

/// Fallback capacity range when the selected truck type has no entry in
/// `truckTypeSpecs` (e.g. Tanker, which isn't in the reference table) —
/// the same 6-35 ton window the capacity field used for every type before
/// per-type ranges existed.
const _fallbackCapacityRange = TruckTypeRange(6, 35);

/// Bottom sheet for adding a new truck. First verifies the vehicle number
/// against the RTO verification API; only once that succeeds do the truck
/// type/capacity/length/height fields appear. Capacity/length/height are
/// each a scroll-wheel picker (like a clock app's time picker) scoped to
/// the selected truck type's valid range — see `truck_type_specs.dart` —
/// and a field is hidden entirely if that truck type has no such
/// dimension at all. On success, pops with the created [VehicleEntity] so
/// callers can react (e.g. auto-select it).
class AddTruckSheet extends ConsumerStatefulWidget {
  /// Prefills the truck number field and immediately triggers Vahan
  /// verification — used when opened from the truck-search picker's "no
  /// results" empty state, so the number the user already typed there
  /// doesn't have to be retyped here.
  final String? initialVehicleNumber;

  const AddTruckSheet({super.key, this.initialVehicleNumber});

  @override
  ConsumerState<AddTruckSheet> createState() => _AddTruckSheetState();
}

class _AddTruckSheetState extends ConsumerState<AddTruckSheet> {
  final _numberCtrl = TextEditingController();
  String? _selectedType;
  double? _selectedCapacity;
  double? _selectedLength;
  double? _selectedHeight;

  bool _verifying = false;
  bool _verified = false;
  String? _verifyError;

  bool _submitting = false;
  String? _submitError;

  TruckTypeSpec? get _spec =>
      _selectedType == null ? null : truckTypeSpecs[_selectedType];

  /// Whether the selected type has an entry in `truckTypeSpecs` at all.
  /// False both when nothing is selected yet and for a type absent from
  /// the reference table (e.g. Tanker) — in either case we don't know
  /// which fields apply, so length/height stay hidden and capacity falls
  /// back to the old unrestricted range rather than guessing.
  bool get _isKnownType =>
      _selectedType != null && truckTypeSpecs.containsKey(_selectedType);

  /// Capacity is shown for every type except ones explicitly marked with
  /// no capacity in the table (e.g. Windblade Trailer, Refrigerated
  /// Truck) — and, before/absent a known type, defaults to shown so the
  /// fallback range still works.
  bool get _showCapacity => !_isKnownType || _spec!.capacity != null;

  bool get _showLength => _isKnownType && _spec!.length != null;

  bool get _showHeight => _isKnownType && _spec!.height != null;

  @override
  void initState() {
    super.initState();
    final initialNumber = widget.initialVehicleNumber;
    if (initialNumber != null && initialNumber.isNotEmpty) {
      _numberCtrl.text = initialNumber;
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  void _onNumberChanged(String _) {
    setState(() {
      if (_verified) {
        _verified = false;
        _selectedType = null;
        _selectedCapacity = null;
        _selectedLength = null;
        _selectedHeight = null;
      }
      _verifyError = null;
    });
  }

  Future<void> _verify() async {
    final number = _numberCtrl.text.trim();
    if (number.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _verifying = true;
      _verifyError = null;
    });
    try {
      final result = await ref
          .read(vehicleNotifierProvider.notifier)
          .verifyVehicle(number);
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _verified = result.verified;
        _verifyError = result.verified
            ? null
            : (result.message.isNotEmpty
                  ? result.message
                  : l10n.somethingWentWrong);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _verified = false;
        _verifyError = ApiException.messageFor(e);
      });
    }
  }

  /// Dev-only escape hatch: skips the ULIP/Vahan verification call entirely
  /// so the rest of the add-truck flow can be tested without a working
  /// verification backend. Never reachable in release builds.
  void _bypassVerification() {
    if (_numberCtrl.text.trim().isEmpty) return;
    setState(() {
      _verifying = false;
      _verified = true;
      _verifyError = null;
    });
  }

  void _onTypeSelected(String type) {
    // Ranges differ per type — a value valid for the previous type could
    // be out of range (or simply not a field at all) for the new one, so
    // always start fresh rather than silently carrying over a stale value.
    setState(() {
      _selectedType = type;
      _selectedCapacity = null;
      _selectedLength = null;
      _selectedHeight = null;
    });
  }

  Future<void> _pickCapacity() async {
    final l10n = AppLocalizations.of(context)!;
    final range = _spec?.capacity ?? _fallbackCapacityRange;
    final values = wheelPickerValues(
      min: range.min,
      max: range.max,
      step: capacityStep(range),
    );
    final result = await showWheelNumberPickerSheet(
      context,
      title: l10n.postCapacityLabel,
      values: values,
      initialValue: _selectedCapacity,
      labelBuilder: (v) => l10n.capacityTon(displayNum(v)),
    );
    if (result != null) setState(() => _selectedCapacity = result);
  }

  Future<void> _pickLength() async {
    final range = _spec?.length;
    if (range == null) return;
    final l10n = AppLocalizations.of(context)!;
    final values = wheelPickerValues(
      min: range.min,
      max: range.max,
      step: lengthStep(range),
    );
    final result = await showWheelNumberPickerSheet(
      context,
      title: l10n.postLengthLabel,
      values: values,
      initialValue: _selectedLength,
      labelBuilder: (v) => l10n.feetValue(displayNum(v)),
    );
    if (result != null) setState(() => _selectedLength = result);
  }

  Future<void> _pickHeight() async {
    final range = _spec?.height;
    if (range == null) return;
    final l10n = AppLocalizations.of(context)!;
    final values = wheelPickerValues(
      min: range.min - heightRangeMarginFt,
      max: range.max + heightRangeMarginFt,
      step: heightStep(range),
    );
    final result = await showWheelNumberPickerSheet(
      context,
      title: l10n.postHeightLabel,
      values: values,
      initialValue: _selectedHeight,
      labelBuilder: (v) => l10n.feetValue(displayNum(v)),
    );
    if (result != null) setState(() => _selectedHeight = result);
  }

  Future<void> _submit() async {
    final number = _numberCtrl.text.trim();
    final type = _selectedType;
    if (!_verified || type == null) return;
    if (_showCapacity && _selectedCapacity == null) return;
    if (_showLength && _selectedLength == null) return;
    if (_showHeight && _selectedHeight == null) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final vehicle = await ref
          .read(vehicleNotifierProvider.notifier)
          .addVehicle(
            vehicleNumber: number,
            truckType: type,
            // 0 is this codebase's existing "not applicable" sentinel for
            // capacity (see my_trucks_screen.dart's `capacity > 0` check) —
            // used for types like Windblade Trailer that have no capacity
            // field to select in the first place.
            capacity: _showCapacity ? _selectedCapacity! : 0,
            length: _showLength ? _selectedLength : null,
            height: _showHeight ? _selectedHeight : null,
          );
      if (mounted) Navigator.pop(context, vehicle);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = ApiException.messageFor(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canVerify =
        !_verifying && !_verified && _numberCtrl.text.trim().isNotEmpty;
    final showCapacity = _showCapacity;
    final showLength = _showLength;
    final showHeight = _showHeight;
    final canSubmit =
        _verified &&
        _selectedType != null &&
        (!showCapacity || _selectedCapacity != null) &&
        (!showLength || _selectedLength != null) &&
        (!showHeight || _selectedHeight != null) &&
        !_submitting;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        // A fixed height (rather than growing with content) keeps the sheet
        // from visibly jumping in size the moment verification succeeds and
        // the type/capacity/submit fields appear.
        height: MediaQuery.of(context).size.height * 0.75,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.postAddTruckSheetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.chipBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SheetLabel(l10n.postTruckNumberLabel),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _numberCtrl,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: _onNumberChanged,
                          decoration: sheetFieldDecoration(
                            l10n.postTruckNumberHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: canVerify ? _verify : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _verified
                                ? AppColors.green
                                : AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: _verified
                                ? AppColors.green
                                : AppColors.primaryBlue.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // Overrides the app theme's default full-width
                            // minimumSize (Size(double.infinity, 52)) — this
                            // button sits in a Row next to the text field, so
                            // an infinite-width minimum crashes layout. Sizing
                            // to content (rather than a fixed width) keeps it
                            // safe for longer translated labels.
                            minimumSize: const Size(64, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: _verifying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : _verified
                              ? const Icon(Icons.check, size: 20)
                              : Text(l10n.postVerifyButton),
                        ),
                      ),
                    ],
                  ),
                  if (_verifyError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _verifyError!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  // if (kDebugMode && !_verified) ...[
                  //   const SizedBox(height: 8),
                  //   Center(
                  //     child: TextButton.icon(
                  //       onPressed: _numberCtrl.text.trim().isNotEmpty
                  //           ? _bypassVerification
                  //           : null,
                  //       style: TextButton.styleFrom(
                  //         foregroundColor: Colors.orange.shade800,
                  //       ),
                  //       icon: const Icon(Icons.bug_report_outlined, size: 16),
                  //       label: const Text(
                  //         'Bypass verification (dev)',
                  //         style: TextStyle(fontSize: 12),
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  if (_verified) ...[
                    const SizedBox(height: 16),
                    SheetLabel(l10n.postTruckTypeLabel),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final type = await TruckTypeSheet.show(
                          context,
                          selected: _selectedType,
                        );
                        if (type != null) _onTypeSelected(type);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            TruckTypeThumbnail(
                              type: _selectedType ?? '',
                              size: 40,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedType != null
                                    ? truckTypeLabel(context, _selectedType!)
                                    : l10n.postSelectTypeHint,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedType != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _selectedType != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showCapacity) ...[
                      const SizedBox(height: 16),
                      SheetLabel(l10n.postCapacityLabel),
                      const SizedBox(height: 6),
                      _WheelPickerField(
                        valueLabel: _selectedCapacity != null
                            ? l10n.capacityTon(displayNum(_selectedCapacity!))
                            : null,
                        placeholder: l10n.postSelectCapacityHint,
                        onTap: _pickCapacity,
                      ),
                    ],
                    if (showLength) ...[
                      const SizedBox(height: 16),
                      SheetLabel(l10n.postLengthLabel),
                      const SizedBox(height: 6),
                      _WheelPickerField(
                        valueLabel: _selectedLength != null
                            ? l10n.feetValue(displayNum(_selectedLength!))
                            : null,
                        placeholder: l10n.postSelectLengthHint,
                        onTap: _pickLength,
                      ),
                    ],
                    if (showHeight) ...[
                      const SizedBox(height: 16),
                      SheetLabel(l10n.postHeightLabel),
                      const SizedBox(height: 6),
                      _WheelPickerField(
                        valueLabel: _selectedHeight != null
                            ? l10n.feetValue(displayNum(_selectedHeight!))
                            : null,
                        placeholder: l10n.postSelectHeightHint,
                        onTap: _pickHeight,
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primaryDark
                              .withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                l10n.postAddTruckButton,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    if (_submitError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _submitError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable row styled like a dropdown, opening a wheel-picker sheet on
/// tap — shared shape for the capacity/length/height fields.
class _WheelPickerField extends StatelessWidget {
  final String? valueLabel;
  final String placeholder;
  final VoidCallback onTap;

  const _WheelPickerField({
    required this.valueLabel,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                valueLabel ?? placeholder,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueLabel != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: valueLabel != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
