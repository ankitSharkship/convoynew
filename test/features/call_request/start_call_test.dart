import 'package:convoynew/features/call_request/presentation/widgets/incoming_request_sheet.dart';
import 'package:convoynew/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support.dart';

const _slide = Duration(milliseconds: 400);

/// Home with a button that opens the driver's sheet, and a stand-in for the
/// call route that shows how it was opened.
Future<void> openAcceptedSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repo = FakeRepository([
    request('accepted', role: 'provider', requesterName: 'Asha'),
  ]);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => IncomingRequestSheet.show(context, 'r1'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/video-call/:id',
        builder: (_, state) => Scaffold(
          body: Text(
            'CALL ${state.pathParameters['id']} '
            '${state.uri.queryParameters['mode']} '
            'driver=${state.uri.queryParameters['driver']}',
          ),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: repoOverrides(repo),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump(_slide);
  await tester.pump(_slide);
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('an accepted request offers Start call, with how long it rings', (
    tester,
  ) async {
    await openAcceptedSheet(tester);
    expect(find.text('Start call'), findsOneWidget);
    expect(
      find.text(
        "Asha's phone will ring for 45 seconds. Park safely before you start.",
      ),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Start call first reminds the driver not to use the phone while driving', (
    tester,
  ) async {
    await openAcceptedSheet(tester);
    await tester.ensureVisible(find.text('Start call'));
    await tester.tap(find.text('Start call'));
    await tester.pump(_slide);

    expect(find.text("Don't use the phone while driving"), findsOneWidget);
    expect(find.textContaining('Park safely before taking this call'), findsOneWidget);
    expect(find.textContaining('CALL r1'), findsNothing, reason: 'not yet');
    await unmount(tester);
  });

  testWidgets('Cancel on the reminder stays on the sheet and starts nothing', (
    tester,
  ) async {
    await openAcceptedSheet(tester);
    await tester.ensureVisible(find.text('Start call'));
    await tester.tap(find.text('Start call'));
    await tester.pump(_slide);

    await tester.tap(find.text('Cancel'));
    await tester.pump(_slide);
    expect(find.text('Start call'), findsOneWidget);
    expect(find.textContaining('CALL r1'), findsNothing);
    await unmount(tester);
  });

  testWidgets('"I\'m parked" closes the sheet and opens the call in start mode', (
    tester,
  ) async {
    await openAcceptedSheet(tester);
    await tester.ensureVisible(find.text('Start call'));
    await tester.tap(find.text('Start call'));
    await tester.pump(_slide);

    await tester.tap(find.text("I'm parked"));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('CALL r1 start driver=1'), findsOneWidget);
    expect(find.text('Start call'), findsNothing);
    await unmount(tester);
  });

  testWidgets('a request that is not accepted offers no Start call', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    for (final status in ['pending', 'rejected', 'expired', 'awaiting_feedback']) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: repoOverrides(
            FakeRepository([request(status, role: 'provider')]),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => IncomingRequestSheet.show(context, 'r1'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(_slide);
      await tester.pump(_slide);
      expect(find.text('Start call'), findsNothing, reason: status);
      await unmount(tester);
    }
  });
}
