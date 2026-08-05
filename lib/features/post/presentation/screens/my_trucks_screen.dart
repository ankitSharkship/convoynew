import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/utils/truck_type_image.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../../shared/widgets/wheel_number_picker.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../state/vehicle_notifier.dart';
import '../widgets/add_truck_sheet.dart';

class MyTrucksScreen extends ConsumerWidget {
  const MyTrucksScreen({super.key});

  Future<void> _showAddTruckSheet(BuildContext context) async {
    await showModalBottomSheet<VehicleEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTruckSheet(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VehicleEntity vehicle,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myTrucksDeleteTitle),
        content: Text(l10n.myTrucksDeleteMessage(vehicle.vehicleNumber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(vehicleNotifierProvider.notifier)
          .deleteVehicle(vehicle.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ApiException.messageFor(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTruckSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/profile'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      l10n.myTrucksTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const LanguageSwitcherButton(),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: vehiclesAsync.when(
                  loading: () => const AppLoader(),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ApiException.messageFor(e),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(vehicleNotifierProvider),
                            child: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (vehicles) => vehicles.isEmpty
                      ? Center(
                          child: Text(
                            l10n.myTrucksNoTrucks,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: vehicles.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _TruckCard(
                            vehicle: vehicles[i],
                            onDelete: () =>
                                _confirmDelete(context, ref, vehicles[i]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _subtitle(
  BuildContext context,
  AppLocalizations l10n,
  VehicleEntity vehicle,
) {
  final parts = <String>[truckTypeLabel(context, vehicle.truckType)];
  if (vehicle.capacity > 0) {
    parts.add(l10n.capacityTon(displayNum(vehicle.capacity)));
  }
  if (vehicle.length != null) {
    parts.add(l10n.feetValue(displayNum(vehicle.length!)));
  }
  if (vehicle.height != null) {
    parts.add(l10n.feetValue(displayNum(vehicle.height!)));
  }
  return parts.join(' · ');
}

class _TruckCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onDelete;

  const _TruckCard({required this.vehicle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TruckTypeThumbnail(type: vehicle.truckType, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.vehicleNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(context, l10n, vehicle),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

class _TruckTypeThumbnail extends StatelessWidget {
  final String type;
  final double size;

  const _TruckTypeThumbnail({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final imagePath = truckTypeImagePath(type);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
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
