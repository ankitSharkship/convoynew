import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/vehicle_model.dart';
import '../state/post_notifier.dart';
import '../state/vehicle_notifier.dart';

class PostFormScreen extends ConsumerStatefulWidget {
  const PostFormScreen({super.key});

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  final _originController = TextEditingController();
  bool _originLoading = false;
  VehicleModel? _selectedVehicle;

  // One controller per destination field
  late List<TextEditingController> _destControllers;

  static const _truckTypes = [
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

  static final _capacities = List.generate(30, (i) => '${i + 6} Ton');

  @override
  void initState() {
    super.initState();
    _destControllers = [TextEditingController()];
  }

  @override
  void dispose() {
    _originController.dispose();
    for (final c in _destControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Origin refresh ────────────────────────────────────────────────────────

  Future<void> _refreshOrigin() async {
    setState(() => _originLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _originLoading = false);
  }

  // ── Destination management ────────────────────────────────────────────────

  void _addDestination() {
    setState(() => _destControllers.add(TextEditingController()));
  }

  void _removeDestination(int index) {
    setState(() {
      _destControllers[index].dispose();
      _destControllers.removeAt(index);
    });
  }

  // ── Truck selector sheet ──────────────────────────────────────────────────

  Future<void> _showTruckSelector(List<VehicleModel> vehicles) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TruckSelectorSheet(
        vehicles: vehicles,
        selected: _selectedVehicle,
        onSelect: (v) {
          setState(() => _selectedVehicle = v);
          Navigator.pop(context);
        },
        onAddTruck: () {
          Navigator.pop(context);
          _showAddTruckSheet();
        },
      ),
    );
  }

  // ── Add truck sheet ───────────────────────────────────────────────────────

  Future<void> _showAddTruckSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTruckSheet(
        truckTypes: _truckTypes,
        capacities: _capacities,
        onSave: (number, type, capacity) async {
          await ref
              .read(vehicleNotifierProvider.notifier)
              .addVehicle(number: number, type: type, capacity: capacity);
          final vehicles = await ref.read(vehicleNotifierProvider.future);
          final newVehicle = vehicles.lastWhere((v) => v.number == number);
          if (mounted) setState(() => _selectedVehicle = newVehicle);
        },
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final destinations = _destControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await ref
        .read(postNotifierProvider.notifier)
        .submitPost(
          truckType: _selectedVehicle!.type,
          capacity: _selectedVehicle!.capacity,
          origin: _originController.text.trim(),
          destination: destinations.join(' | '),
          vehicleNumber: _selectedVehicle?.number ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PostState>(postNotifierProvider, (_, next) {
      if (next is PostDone) {
        context.pushReplacement(
          '/post/success',
          extra: {
            'truckType': next.post.truckType,
            'capacity': next.post.capacity,
            'origin': next.post.origin,
          },
        );
        ref.read(postNotifierProvider.notifier).reset();
      }
    });

    final postState = ref.watch(postNotifierProvider);
    final isSubmitting = postState is PostSubmitting;
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Post your truck',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF0F6FF),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voice-fill banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.graphic_eq, size: 16, color: AppColors.green),
                  SizedBox(width: 8),
                  Text(
                    'Filled from your voice — check & confirm',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Origin ──────────────────────────────────────────────────────
            const _Label('Origin'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _originController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your location',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.normal,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _originLoading ? null : _refreshOrigin,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: _originLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryBlue,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Destinations ─────────────────────────────────────────────────
            const _Label('Destination'),
            const SizedBox(height: 8),
            ..._destControllers.asMap().entries.map((entry) {
              final i = entry.key;
              final ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter destination',
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.normal,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_destControllers.length > 1)
                        GestureDetector(
                          onTap: () => _removeDestination(i),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            // Add destination button
            GestureDetector(
              onTap: _addDestination,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Add destination',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Select Truck dropdown ────────────────────────────────────────
            const _Label('Select Truck'),
            const SizedBox(height: 8),
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
              error: (e, _) => Text('Error: $e'),
              data: (vehicles) => GestureDetector(
                onTap: () => _showTruckSelector(vehicles),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping,
                        size: 22,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedVehicle == null
                            ? const Text(
                                'Select a truck',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textTertiary,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedVehicle!.number,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedVehicle!.type} · ${_selectedVehicle!.capacity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Post Truck button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting || _selectedVehicle == null
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primaryDark.withValues(
                    alpha: 0.5,
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
                          Icon(Icons.campaign, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Post Truck',
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

// ── Truck selector sheet ─────────────────────────────────────────────────────

class _TruckSelectorSheet extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final VehicleModel? selected;
  final ValueChanged<VehicleModel> onSelect;
  final VoidCallback onAddTruck;

  const _TruckSelectorSheet({
    required this.vehicles,
    required this.selected,
    required this.onSelect,
    required this.onAddTruck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Truck',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...vehicles.map((v) {
              final isSelected = selected?.number == v.number;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    size: 20,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  v.number,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${v.type} · ${v.capacity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                      )
                    : null,
                onTap: () => onSelect(v),
              );
            }),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: const Text(
                'Add a truck',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              onTap: onAddTruck,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Add truck sheet ──────────────────────────────────────────────────────────

class _AddTruckSheet extends StatefulWidget {
  final List<String> truckTypes;
  final List<String> capacities;
  final Future<void> Function(String number, String type, String capacity)
  onSave;

  const _AddTruckSheet({
    required this.truckTypes,
    required this.capacities,
    required this.onSave,
  });

  @override
  State<_AddTruckSheet> createState() => _AddTruckSheetState();
}

class _AddTruckSheetState extends State<_AddTruckSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  String? _selectedType;
  String? _selectedCapacity;
  bool _saving = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave(
      _numberCtrl.text.trim().toUpperCase(),
      _selectedType!,
      _selectedCapacity!,
    );
    if (mounted) Navigator.pop(context);
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
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

                  // Truck number
                  const _SheetLabel('Truck Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _numberCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration('e.g. MH04AB1234'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter truck number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Truck type
                  const _SheetLabel('Truck Type'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _inputDecoration('Select type'),
                    items: widget.truckTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                    validator: (v) => v == null ? 'Select a truck type' : null,
                  ),
                  const SizedBox(height: 16),

                  // Capacity
                  const _SheetLabel('Capacity'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCapacity,
                    decoration: _inputDecoration('Select capacity'),
                    isExpanded: true,
                    items: widget.capacities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCapacity = v),
                    validator: (v) => v == null ? 'Select capacity' : null,
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Truck',
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
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.red),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
);

// ── Small helpers ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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
