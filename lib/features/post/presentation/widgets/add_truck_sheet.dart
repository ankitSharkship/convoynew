import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../state/vehicle_notifier.dart';

final _capacities = List.generate(30, (i) => i + 6);

/// Bottom sheet for adding a new truck. First verifies the vehicle number
/// against the RTO verification API; only once that succeeds do the truck
/// type/capacity fields appear. On success, pops with the created
/// [VehicleEntity] so callers can react (e.g. auto-select it).
class AddTruckSheet extends ConsumerStatefulWidget {
  const AddTruckSheet({super.key});

  @override
  ConsumerState<AddTruckSheet> createState() => _AddTruckSheetState();
}

class _AddTruckSheetState extends ConsumerState<AddTruckSheet> {
  final _numberCtrl = TextEditingController();
  String? _selectedType;
  int? _selectedCapacity;

  bool _verifying = false;
  bool _verified = false;
  String? _verifyError;

  bool _submitting = false;
  String? _submitError;

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

  Future<void> _submit() async {
    final number = _numberCtrl.text.trim();
    final type = _selectedType;
    final capacity = _selectedCapacity;
    if (!_verified || type == null || capacity == null) return;

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
            capacity: capacity,
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
    final canSubmit =
        _verified &&
        _selectedType != null &&
        _selectedCapacity != null &&
        !_submitting;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                Text(
                  l10n.postAddTruckSheetTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
                    style: const TextStyle(color: AppColors.red, fontSize: 12),
                  ),
                ],
                if (_verified) ...[
                  const SizedBox(height: 16),
                  SheetLabel(l10n.postTruckTypeLabel),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: sheetFieldDecoration(l10n.postSelectTypeHint),
                    items: truckTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(truckTypeLabel(context, t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 16),
                  SheetLabel(l10n.postCapacityLabel),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: _selectedCapacity,
                    decoration: sheetFieldDecoration(
                      l10n.postSelectCapacityHint,
                    ),
                    isExpanded: true,
                    items: _capacities
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(l10n.capacityTon(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCapacity = v),
                  ),
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
    );
  }
}
