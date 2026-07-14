import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// Canonical (English) truck type values — these are the values actually
/// used in app state / sent as data, matching what the backend returns.
const truckTypes = [
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

/// Translates a canonical truck type value for display. Falls back to the
/// raw value for anything outside the known set (e.g. future backend types).
String truckTypeLabel(BuildContext context, String rawType) {
  final l10n = AppLocalizations.of(context)!;
  switch (rawType) {
    case 'Open Body':
      return l10n.truckTypeOpenBody;
    case 'Closed Body':
      return l10n.truckTypeClosedBody;
    case 'Container 20ft':
      return l10n.truckTypeContainer20Ft;
    case 'Container 32ft':
      return l10n.truckTypeContainer32Ft;
    case 'Tipper':
      return l10n.truckTypeTipper;
    case 'Sidewall Trailer':
      return l10n.truckTypeSidewallTrailer;
    case 'Flat Bed Trailer':
      return l10n.truckTypeFlatBedTrailer;
    case 'Bulker':
      return l10n.truckTypeBulker;
    case 'Tanker':
      return l10n.truckTypeTanker;
    default:
      return rawType;
  }
}
