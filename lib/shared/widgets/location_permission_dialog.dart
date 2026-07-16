import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shown when a "use current location" attempt fails because location
/// services are off or the app doesn't have location permission — tells
/// the user why and offers a button straight to the relevant system
/// settings screen. No-ops for other [LocationServiceException] types
/// (e.g. address resolution failures), since there's no settings screen
/// that would fix those.
Future<void> showLocationPermissionDialog(
  BuildContext context,
  LocationServiceException exception,
) {
  final l10n = AppLocalizations.of(context)!;
  final isServiceDisabled =
      exception.type == LocationServiceExceptionType.serviceDisabled;
  final isPermissionDenied =
      exception.type == LocationServiceExceptionType.permissionDenied;
  if (!isServiceDisabled && !isPermissionDenied) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(exception.message)));
    return Future.value();
  }

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        isServiceDisabled
            ? l10n.locationServiceDisabledTitle
            : l10n.locationPermissionDeniedTitle,
      ),
      content: Text(
        isServiceDisabled
            ? l10n.locationServiceDisabledMessage
            : l10n.locationPermissionDeniedMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (isServiceDisabled) {
              Geolocator.openLocationSettings();
            } else {
              Geolocator.openAppSettings();
            }
          },
          child: Text(
            isServiceDisabled
                ? l10n.locationEnableButton
                : l10n.locationOpenSettingsButton,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
