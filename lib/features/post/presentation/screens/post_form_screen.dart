import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/utils/truck_image.dart';
import '../../../../shared/widgets/borderless_input_decoration.dart';
import '../../../search/domain/entities/location_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../state/post_notifier.dart';
import '../state/vehicle_notifier.dart';

const _addNewTruckSentinel = '__add_new_truck__';

const _truckTypes = [
  'Open Body',
  'Closed Body',
  'Container 20ft',
  'Container 32ft',
  'Tipper',
  'Sidewall Trailer',
  'Flat Bed Trailer',
  'Bulker',
  'Tanker',
];

final _capacities = List.generate(30, (i) => '${i + 6} Ton');

class PostFormScreen extends ConsumerStatefulWidget {
  const PostFormScreen({super.key});

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  final _originController = TextEditingController();
  final _destControllers = <TextEditingController>[TextEditingController()];

  @override
  void dispose() {
    _originController.dispose();
    for (final c in _destControllers) {
      c.dispose();
    }
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

  Future<void> _showAddTruckSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTruckSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postNotifierProvider);
    final notifier = ref.read(postNotifierProvider.notifier);
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    _syncDestControllers(state.destinations.length);

    ref.listen<PostFormState>(postNotifierProvider, (previous, next) {
      if (next.origin != null && next.origin != previous?.origin) {
        _originController.text = next.origin!.name;
      }
      for (var i = 0; i < next.destinations.length; i++) {
        final location = next.destinations[i].location;
        final previousLocation = i < (previous?.destinations.length ?? 0)
            ? previous!.destinations[i].location
            : null;
        if (location != null && location != previousLocation) {
          _destControllers[i].text = location.name;
        }
      }
      if (next.submission is PostDone) {
        final post = (next.submission as PostDone).post;
        context.pushReplacement(
          '/post/success',
          extra: {
            'truckType': post.truckType,
            'capacity': post.capacity > 0 ? '${post.capacity} Ton' : '—',
            'origin': post.originName,
          },
        );
        notifier.resetSubmission();
      }
    });

    final isSubmitting = state.submission is PostSubmitting;
    final submissionError = state.submission is PostError
        ? (state.submission as PostError).message
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Post your truck',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.translate), onPressed: () {}),
        ],
        backgroundColor: AppColors.background,
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
                  const _SectionLabel('ROUTE'),
                  const SizedBox(height: 14),
                  _OriginField(
                    controller: _originController,
                    origin: state.origin,
                    locating: state.originLocating,
                    onLocate: () => notifier.useCurrentOriginLocation(),
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
                  const _SectionLabel('SELECT TRUCK'),
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
                      'Could not load your trucks',
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Post a Truck',
                            style: TextStyle(
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
                  const Text(
                    'From (current location)',
                    style: TextStyle(
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
                      hintText: 'Tap the locate button to detect',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: origin != null
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            size: 10,
                            color: AppColors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'GPS Auto-detected',
                            style: TextStyle(
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
                'Destination ${index + 1}',
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
        Row(
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Icon(Icons.location_on, size: 26, color: AppColors.red),
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
                  hintText: 'Enter destination',
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
        _SuggestionsList(
          suggestions: field.suggestions,
          loading: field.suggestionsLoading,
          onSelect: onSelect,
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
      margin: const EdgeInsets.only(left: 48, top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
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
    return DropdownButtonFormField<String>(
      value: selectedVehicleId,
      isExpanded: true,
      itemHeight: 72,
      borderRadius: BorderRadius.circular(18),
      decoration: InputDecoration(
        hintText: 'Select a truck',
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      truckImageFor(v.vehicleNumber),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.vehicleNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.capacity > 0
                              ? '${v.truckType} · ${v.capacity} Ton'
                              : v.truckType,
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
                const Text(
                  'Add New Truck',
                  style: TextStyle(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    truckImageFor(v.vehicleNumber),
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
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
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add New Truck',
            style: TextStyle(
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

// ── Add truck sheet (UI only, no functionality yet) ─────────────────────────

class _AddTruckSheet extends StatefulWidget {
  const _AddTruckSheet();

  @override
  State<_AddTruckSheet> createState() => _AddTruckSheetState();
}

class _AddTruckSheetState extends State<_AddTruckSheet> {
  final _numberCtrl = TextEditingController();
  String? _selectedType;
  String? _selectedCapacity;

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Add a Truck',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const _SheetLabel('Truck Number'),
                const SizedBox(height: 6),
                TextField(
                  controller: _numberCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration('e.g. MH04AB1234'),
                ),
                const SizedBox(height: 16),
                const _SheetLabel('Truck Type'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration('Select type'),
                  items: _truckTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v),
                ),
                const SizedBox(height: 16),
                const _SheetLabel('Capacity'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCapacity,
                  decoration: _inputDecoration('Select capacity'),
                  isExpanded: true,
                  items: _capacities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCapacity = v),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Truck',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
);

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}
