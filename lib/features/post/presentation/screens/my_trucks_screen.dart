import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/utils/truck_image.dart';
import '../../../../shared/widgets/loader.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../state/vehicle_notifier.dart';

class MyTrucksScreen extends ConsumerWidget {
  const MyTrucksScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VehicleEntity vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete truck'),
        content: Text(
          'Remove ${vehicle.vehicleNumber} from your trucks? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(vehicleNotifierProvider.notifier).deleteVehicle(vehicle.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiException.messageFor(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/profile'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'My Trucks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.translate, size: 20),
                    ),
                  ),
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
                          const Icon(Icons.error_outline,
                              size: 40, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            ApiException.messageFor(e),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(vehicleNotifierProvider),
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (vehicles) => vehicles.isEmpty
                      ? const Center(
                          child: Text(
                            'No trucks added yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: vehicles.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
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

class _TruckCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onDelete;

  const _TruckCard({required this.vehicle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              truckImageFor(vehicle.vehicleNumber),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
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
                  vehicle.capacity > 0
                      ? '${vehicle.truckType} · ${vehicle.capacity} Ton'
                      : vehicle.truckType,
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
