import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/utils/truck_type_image.dart';
import '../../../../shared/widgets/borderless_input_decoration.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../../shared/widgets/sheet_form_field.dart';
import '../../../../shared/widgets/suggestions_overlay.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../state/post_notifier.dart';
import '../state/vehicle_notifier.dart';
import '../widgets/add_truck_sheet.dart';

const _addNewTruckSentinel = '__add_new_truck__';

class PostFormScreen extends ConsumerStatefulWidget {
  final TripEntity? editingTrip;

  const PostFormScreen({super.key, this.editingTrip});

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  final _originController = TextEditingController();
  final _destControllers = <TextEditingController>[TextEditingController()];
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final trip = widget.editingTrip;
    if (trip != null) {
      // Editing an existing trip already has an origin (from the trip
      // itself) — don't clobber it with a fresh GPS fetch.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postNotifierProvider.notifier).startEditing(trip);
      });
    } else {
      // New post: fill origin with the user's current location right away
      // instead of waiting for them to tap the locate button.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postNotifierProvider.notifier).useCurrentOriginLocation();
      });
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    for (final c in _destControllers) {
      c.dispose();
    }
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  void _syncDestControllers(int count) {
    while (_destControllers.length < count) {
      _destControllers.add(TextEditingController());
    }
    while (_destControllers.length > count) {
      _destControllers.removeLast().dispose();
    }
  }

  Future<void> _useCurrentOriginLocation() async {
    try {
      await ref.read(postNotifierProvider.notifier).useCurrentOriginLocation();
    } on LocationServiceException catch (e) {
      if (mounted) await showLocationPermissionDialog(context, e);
    }
  }

  Future<void> _showAddTruckSheet() async {
    final vehicle = await showModalBottomSheet<VehicleEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTruckSheet(),
    );
    if (vehicle != null && mounted) {
      ref.read(postNotifierProvider.notifier).selectVehicle(vehicle.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postNotifierProvider);
    final notifier = ref.read(postNotifierProvider.notifier);
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    _syncDestControllers(state.destinations.length);

    ref.listen<PostFormState>(postNotifierProvider, (previous, next) {
      if (next.origin != null && next.origin != previous?.origin) {
        _originController.text = next.origin!.name;
      }
      _syncDestControllers(next.destinations.length);
      for (var i = 0; i < next.destinations.length; i++) {
        final location = next.destinations[i].location;
        final previousLocation = i < (previous?.destinations.length ?? 0)
            ? previous!.destinations[i].location
            : null;
        if (location != null && location != previousLocation) {
          _destControllers[i].text = location.name;
        }
      }
      // Only re-sync from state when editing starts (a one-time prefill) —
      // not on every keystroke, since typing already updates these
      // controllers directly and the state field mirrors that same text.
      if (next.editingTripId != previous?.editingTripId) {
        _contactNameController.text = next.contactName;
        _contactNumberController.text = formatPhoneDisplay(next.contactNumber);
      }
      if (next.submission is PostDone) {
        final post = (next.submission as PostDone).post;
        context.pushReplacement(
          '/post/success',
          extra: {
            'truckType': post.truckType,
            'capacity': post.capacity,
            'origin': post.originName,
          },
        );
        notifier.resetSubmission();
      } else if (next.submission is PostEditSaved) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile/trips');
        }
        notifier.resetSubmission();
      }
    });

    final isSubmitting = state.submission is PostSubmitting;
    final submissionError = state.submission is PostError
        ? (state.submission as PostError).message
        : null;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          state.isEditing ? l10n.postEditTitle : l10n.postScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: const [LanguageSwitcherButton(card: false)],
        backgroundColor: AppColors.primaryBlueLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Route card ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.postRouteSectionLabel),
                  const SizedBox(height: 14),
                  _OriginField(
                    controller: _originController,
                    origin: state.origin,
                    locating: state.originLocating,
                    onLocate: _useCurrentOriginLocation,
                    onClear: () {
                      _originController.clear();
                      notifier.clearOrigin();
                    },
                  ),
                  ...state.destinations.asMap().entries.map((entry) {
                    final i = entry.key;
                    final field = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _DestinationField(
                        index: i,
                        controller: _destControllers[i],
                        field: field,
                        removable: i > 0,
                        canAdd: state.canAddDestination,
                        onChanged: (v) =>
                            notifier.onDestinationQueryChanged(i, v),
                        onSelect: (loc) =>
                            notifier.selectDestinationSuggestion(i, loc),
                        onClear: () {
                          _destControllers[i].clear();
                          notifier.clearDestination(i);
                        },
                        onDismiss: () =>
                            notifier.dismissDestinationSuggestions(i),
                        onAdd: notifier.addDestination,
                        onRemove: () => notifier.removeDestination(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Select truck card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.postSelectTruckSectionLabel),
                  const SizedBox(height: 12),
                  vehiclesAsync.when(
                    loading: () => const SizedBox(
                      height: 56,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    error: (e, _) => Text(
                      l10n.postCouldNotLoadTrucks,
                      style: const TextStyle(color: AppColors.red),
                    ),
                    data: (vehicles) => _TruckDropdown(
                      vehicles: vehicles,
                      selectedVehicleId: state.selectedVehicleId,
                      onChanged: (value) {
                        if (value == _addNewTruckSentinel) {
                          _showAddTruckSheet();
                          return;
                        }
                        notifier.selectVehicle(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Contact card ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: _ContactSection(
                mode: state.contactMode,
                contactNumberValid: state.contactNumberValid,
                contactNumber: state.contactNumber,
                nameController: _contactNameController,
                numberController: _contactNumberController,
                onModeChanged: (mode) {
                  if (mode == ContactMode.me) {
                    _contactNameController.clear();
                    _contactNumberController.clear();
                  }
                  notifier.setContactMode(mode);
                },
                onNameChanged: notifier.updateContactName,
                onNumberChanged: notifier.updateContactNumber,
              ),
            ),

            if (submissionError != null) ...[
              const SizedBox(height: 16),
              Text(
                submissionError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 28),

            // ── Post Truck button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: state.canSubmit && !isSubmitting
                    ? notifier.submitPost
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primaryBlue.withValues(
                    alpha: 0.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.isEditing
                                ? l10n.postSaveChangesButton
                                : l10n.postSubmitButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.textTertiary,
      letterSpacing: 0.5,
    ),
  );
}

// ── Origin field ─────────────────────────────────────────────────────────────

class _OriginField extends StatelessWidget {
  final TextEditingController controller;
  final LocationEntity? origin;
  final bool locating;
  final VoidCallback onLocate;
  final VoidCallback onClear;

  const _OriginField({
    required this.controller,
    required this.origin,
    required this.locating,
    required this.onLocate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isGpsDetected = origin?.type == 'current';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.green, width: 2.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.postOriginLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    readOnly: true,
                    showCursor: false,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    decoration: borderlessInputDecoration(
                      hintText: AppLocalizations.of(context)!.postOriginHint,
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  if (isGpsDetected) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed,
                            size: 10,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.postGpsAutoDetected,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: locating ? null : onLocate,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: locating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : const Icon(
                        Icons.my_location,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 17, top: 4),
          child: Container(
            width: 2,
            height: 16,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

// ── Destination field ────────────────────────────────────────────────────────

class _DestinationField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final DestinationField field;
  final bool removable;
  final bool canAdd;
  final ValueChanged<String> onChanged;
  final ValueChanged<LocationEntity> onSelect;
  final VoidCallback onClear;
  final VoidCallback onDismiss;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DestinationField({
    required this.index,
    required this.controller,
    required this.field,
    required this.removable,
    required this.canAdd,
    required this.onChanged,
    required this.onSelect,
    required this.onClear,
    required this.onDismiss,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.postDestinationLabel(index + 1),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            if (removable)
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: AppColors.red,
                  ),
                ),
              ),
          ],
        ),
        SuggestionsOverlay(
          visible: field.showSuggestions,
          onDismissTap: onDismiss,
          overlayBuilder: (_) => _SuggestionsList(
            suggestions: field.suggestions,
            loading: field.suggestionsLoading,
            onSelect: onSelect,
          ),
          field: Row(
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.location_on,
                    size: 26,
                    color: AppColors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: borderlessInputDecoration(
                    hintText: AppLocalizations.of(context)!.postDestinationHint,
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.normal,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: field.location != null
                        ? GestureDetector(
                            onTap: onClear,
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (isFirst) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: canAdd ? onAdd : null,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: canAdd
                          ? AppColors.primaryBlue.withValues(alpha: 0.1)
                          : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: canAdd
                          ? AppColors.primaryBlue
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Suggestions dropdown ─────────────────────────────────────────────────────

class _SuggestionsList extends StatelessWidget {
  final List<LocationEntity> suggestions;
  final bool loading;
  final ValueChanged<LocationEntity> onSelect;

  const _SuggestionsList({
    required this.suggestions,
    required this.loading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading && suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: suggestions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 12, endIndent: 12),
              itemBuilder: (_, i) {
                final loc = suggestions[i];
                return InkWell(
                  onTap: () => onSelect(loc),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── Truck dropdown ───────────────────────────────────────────────────────────

class _TruckDropdown extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  final String? selectedVehicleId;
  final ValueChanged<String?> onChanged;

  const _TruckDropdown({
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      value: selectedVehicleId,
      isExpanded: true,
      itemHeight: 72,
      borderRadius: BorderRadius.circular(18),
      decoration: InputDecoration(
        hintText: l10n.postSelectTruckHint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      items: [
        ...vehicles.map(
          (v) => DropdownMenuItem(
            value: v.id,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _TruckTypeThumbnail(type: v.truckType, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.vehicleNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.capacity > 0
                              ? '${truckTypeLabel(context, v.truckType)} · ${l10n.capacityTon(v.capacity)}'
                              : truckTypeLabel(context, v.truckType),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: _addNewTruckSentinel,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 24,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  l10n.postAddNewTruck,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      // The closed/collapsed field reuses each DropdownMenuItem's child by
      // default, but that rich (image + two lines of text) item is taller
      // than the space the collapsed field allocates, causing an overflow.
      // selectedItemBuilder supplies a compact, single-line stand-in just
      // for the closed state instead.
      selectedItemBuilder: (context) => [
        ...vehicles.map(
          (v) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TruckTypeThumbnail(
                  type: v.truckType,
                  size: 28,
                  borderRadius: 6,
                ),
                const SizedBox(width: 10),
                Text(
                  v.vehicleNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.postAddNewTruck,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _TruckTypeThumbnail extends StatelessWidget {
  final String type;
  final double size;
  final double borderRadius;

  const _TruckTypeThumbnail({
    required this.type,
    required this.size,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = truckTypeImagePath(type);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imagePath != null
          ? Image.asset(imagePath, width: size, height: size, fit: BoxFit.cover)
          : Container(
              width: size,
              height: size,
              color: AppColors.chipBackground,
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.textTertiary,
              ),
            ),
    );
  }
}

// ── Contact section ──────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  final ContactMode mode;
  final bool contactNumberValid;
  final String contactNumber;
  final TextEditingController nameController;
  final TextEditingController numberController;
  final ValueChanged<ContactMode> onModeChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onNumberChanged;

  const _ContactSection({
    required this.mode,
    required this.contactNumberValid,
    required this.contactNumber,
    required this.nameController,
    required this.numberController,
    required this.onModeChanged,
    required this.onNameChanged,
    required this.onNumberChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSomeoneElse = mode == ContactMode.someoneElse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.postContactSectionTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RadioOption(
                label: l10n.postContactMe,
                value: ContactMode.me,
                groupValue: mode,
                onChanged: onModeChanged,
              ),
            ),
            Expanded(
              child: _RadioOption(
                label: l10n.postContactSomeoneElse,
                value: ContactMode.someoneElse,
                groupValue: mode,
                onChanged: onModeChanged,
              ),
            ),
          ],
        ),
        if (isSomeoneElse) ...[
          const SizedBox(height: 16),
          SheetLabel(l10n.postContactNameLabel),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            onChanged: onNameChanged,
            decoration: sheetFieldDecoration(l10n.postContactNameHint),
          ),
          const SizedBox(height: 16),
          SheetLabel(l10n.postContactNumberLabel),
          const SizedBox(height: 6),
          TextField(
            controller: numberController,
            keyboardType: TextInputType.phone,
            inputFormatters: [PhoneNumberFormatter()],
            onChanged: onNumberChanged,
            decoration: sheetFieldDecoration(l10n.postContactNumberHint),
          ),
          if (contactNumber.isNotEmpty && !contactNumberValid) ...[
            const SizedBox(height: 6),
            Text(
              l10n.postContactNumberError,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ],
        ],
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final ContactMode value;
  final ContactMode groupValue;
  final ValueChanged<ContactMode> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primaryBlue : AppColors.border,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
