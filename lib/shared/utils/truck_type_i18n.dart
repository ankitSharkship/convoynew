import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// Canonical (English) truck type values — these are the values actually
/// used in app state / sent as data, matching what the backend returns.
const truckTypes = [
  'Open Body',
  'Closed Body',
  'Tipper',
  'Sidewall Trailer',
  'Flat Bed Trailer',
  'Flat Bed Truck',
  'Low Bed Trailer',
  'Refrigerated Truck',
  'Bulker',
  'Tanker',
];

/// Translates a canonical truck type value for display. Falls back to the
/// raw value for anything outside the known set (e.g. future backend types).
String truckTypeLabel(BuildContext context, String rawType) {
  final l10n = AppLocalizations.of(context)!;
  switch (rawType) {
    case 'Open Body':
      return l10n.truckTypeOpenBody;
    case 'Closed Body':
      return l10n.truckTypeClosedBody;
    case 'Tipper':
      return l10n.truckTypeTipper;
    case 'Sidewall Trailer':
      return l10n.truckTypeSidewallTrailer;
    case 'Flat Bed Trailer':
      return l10n.truckTypeFlatBedTrailer;
    case 'Flat Bed Truck':
      return l10n.truckTypeFlatBedTruck;
    case 'Low Bed Trailer':
      return l10n.truckTypeLowBedTrailer;
    case 'Refrigerated Truck':
      return l10n.truckTypeRefrigeratedTruck;
    case 'Bulker':
      return l10n.truckTypeBulker;
    case 'Tanker':
      return l10n.truckTypeTanker;
    default:
      return rawType;
  }
}
