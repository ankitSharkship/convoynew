import 'package:convoynew/features/search/domain/entities/truck_search_result_entity.dart';
import 'package:convoynew/features/truck_map/presentation/widgets/truck_details_sheet.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TruckSearchResultEntity _post() => TruckSearchResultEntity(
  truckId: 't',
  truckRouteId: 'r',
  truckNumber: 'HR26DQ8821',
  truckType: 'Container',
  capacity: 32,
  origin: 'Manesar',
  originDistanceKm: 0,
  status: 'active',
  originLocation: const TruckSearchLocationEntity(
    lat: 1,
    lng: 1,
    name: 'Manesar',
    type: 'city',
    city: 'Gurugram',
    state: 'Haryana',
    pincode: '122051',
  ),
  currentLocation: const TruckSearchLocationEntity(
    lat: 1,
    lng: 1,
    name: 'Manesar',
    type: 'city',
  ),
  destinations: const [
    TruckSearchDestinationEntity(
      id: 'd',
      position: 1,
      lat: 2,
      lng: 2,
      name: 'Jaipur',
      type: 'city',
      city: 'Jaipur',
      state: 'Rajasthan',
    ),
  ],
  userId: 'u',
  userName: 'Vikramjeet Singh',
  userMobile: '9999999999',
  mutualsCount: 0,
  mutualNames: const [],
  createdAt: DateTime(2026),
  expiresAt: DateTime(2027),
);

void main() {
  group('fullLocation', () {
    test('joins name, city, state and pincode', () {
      expect(
        fullLocation('Manesar', 'Gurugram', 'Haryana', '122051'),
        'Manesar, Gurugram, Haryana 122051',
      );
    });

    test('skips blanks and repeated parts', () {
      expect(fullLocation('Jaipur', 'Jaipur', 'Rajasthan', ''), 'Jaipur, Rajasthan');
      expect(fullLocation('Delhi', null, ' ', null), 'Delhi');
    });
  });

  testWidgets('sheet shows user row with close, route and both buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TruckDetailsSheet(result: _post())),
        ),
      ),
    );
    expect(find.text('Truck Details'), findsNothing);
    expect(find.text('Vikramjeet Singh'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Manesar, Gurugram, Haryana 122051'), findsOneWidget);
    expect(find.text('Jaipur, Rajasthan'), findsOneWidget);
    expect(find.text('Request 1:1'), findsOneWidget);
    expect(find.text('Call Driver to Book'), findsOneWidget);
    await tester.tap(find.text('Request 1:1'));
    await tester.pump();
    expect(find.text('1:1 requests are coming soon'), findsOneWidget);
  });
}
