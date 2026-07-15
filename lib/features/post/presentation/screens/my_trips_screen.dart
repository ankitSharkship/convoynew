import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/loader.dart';
import '../../domain/entities/trip_entity.dart';
import '../state/trips_notifier.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TripEntity trip,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tripsDeleteTitle),
        content: Text(l10n.tripsDeleteMessage),
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
      await ref.read(tripsNotifierProvider.notifier).delete(trip.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ApiException.messageFor(e))));
      }
    }
  }

  Future<void> _reactivate(
    BuildContext context,
    WidgetRef ref,
    TripEntity trip,
  ) async {
    try {
      await ref.read(tripsNotifierProvider.notifier).reactivate(trip.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ApiException.messageFor(e))));
      }
    }
  }

  void _edit(BuildContext context, TripEntity trip) {
    context.push('/post/edit', extra: trip);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

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
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/profile'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      l10n.tripsTitle,
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
                child: tripsAsync.when(
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
                                ref.invalidate(tripsNotifierProvider),
                            child: Text(l10n.tryAgain),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (trips) => trips.isEmpty
                      ? Center(
                          child: Text(
                            l10n.tripsNoTrips,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: trips.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _TripCard(
                            trip: trips[i],
                            onEdit: () => _edit(context, trips[i]),
                            onDelete: () =>
                                _confirmDelete(context, ref, trips[i]),
                            onReactivate: () =>
                                _reactivate(context, ref, trips[i]),
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

class _TripCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReactivate;

  const _TripCard({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
    required this.onReactivate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expired = trip.isExpired;
    final destinationName = trip.destinations.isNotEmpty
        ? trip.destinations.first.name
        : '';
    final extraDestinations = trip.destinations.length - 1;
    final dateText = DateFormat(
      'd MMM y',
      Localizations.localeOf(context).toString(),
    ).format(trip.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: expired ? AppColors.redLight : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      expired ? Icons.schedule : Icons.check_circle,
                      size: 12,
                      color: expired ? AppColors.red : AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      expired ? l10n.tripsExpiredLabel : l10n.tripsActiveLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: expired ? AppColors.red : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 2.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trip.originName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(
              width: 2,
              height: 16,
              color: AppColors.textTertiary.withValues(alpha: 0.4),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destinationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (extraDestinations > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF5FC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    l10n.tripsMoreDestinations(extraDestinations),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F8)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.capacity > 0
                      ? '${trip.vehicleNumber} · ${truckTypeLabel(context, trip.truckType)} · ${l10n.capacityTon(trip.capacity)}'
                      : '${trip.vehicleNumber} · ${truckTypeLabel(context, trip.truckType)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (expired) ...[
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onReactivate,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(
                        l10n.tripsReactivate,
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              _ActionIconButton(icon: Icons.edit_outlined, onTap: onEdit),
              const SizedBox(width: 8),
              _ActionIconButton(
                icon: Icons.delete_outline,
                onTap: onDelete,
                color: AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color ?? AppColors.primaryBlue),
      ),
    );
  }
}
