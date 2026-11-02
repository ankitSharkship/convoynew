# Memories — convoynew

Working notes for future sessions on this project. See `context.md` for the full project overview; this file tracks operating rules and decisions to carry forward.

## Always apply these rules (non-negotiable, from `.agents/rules/`)

1. Every new feature = full Clean Architecture slice (`data/domain/presentation`), Riverpod codegen (`@riverpod`), Dio for networking. No skipping the repository/usecase layers even for small features.
2. UI → Notifier → UseCase → Repository → DataSource → API. Never call Dio or hit business logic from a widget/notifier directly.
3. Errors: catch once at the repository boundary, convert to a typed `Failure`. Show `error_message` from the API verbatim if present, else "Something went wrong". Never show raw exceptions/stack traces/status codes/`error_code` to users.
4. Every async screen implements all 4 states: loading, success, empty, error — sized to blast radius (full-screen retry vs snackbar vs silent/log-only).
5. Approved stack only: Riverpod (codegen), Dio, GoRouter, Hive + flutter_secure_storage, freezed, json_serializable, flutter_dotenv. If a task needs something outside this list, flag the gap and propose an alternative instead of silently adding a new package.
6. Tokens (JWT/refresh) → `flutter_secure_storage` only, never Hive/shared_preferences. OTPs never persisted beyond the input field's lifetime.
7. No hardcoded user-facing strings — everything through `.arb`/`AppLocalizations` (EN/HI/KN/MR supported).
8. Design: pull colors/spacing/radii from centralized tokens (per `design.md`), reuse existing components (`PrimaryCta`, `AppFieldTile`, Route Stepper, Result/Person Card, etc.) before inventing new ones. Orange (`colorPrimary`) reserved for the single most important action per screen — never two competing solid-orange buttons.
9. If `flutter-agent-rules.md` and `flutter-guardrails.md` ever conflict, flag it rather than silently picking one.

## Project-specific facts worth remembering

- Backend base URL lives in `.env` (`API_BASE_URL=https://convoy.logipod.in/`) — dev/staging URL is commented out alongside it. Don't overwrite the commented line without asking.
- No refresh-token endpoint exists yet. `dio_client.dart`'s 401 handling deliberately does NOT clear session storage when the 401 comes from the OTP endpoints themselves (login failure ≠ session expiry) — preserve this distinction if touching auth interceptors.
- KYC (Aadhaar OTP) gates the ability to post a truck (`post_truck_gate.dart`) — any change to the post flow should check whether this gate still applies.
- `openapi.json` at repo root is the source of truth for backend contract — check it before assuming a request/response shape.
- 3-tab bottom nav (`home`, `search`, `profile`) via `StatefulShellRoute.indexedStack` in `MainShell`; everything else (`post`, `search/results`, `kyc`, `call`, etc.) is a full-screen route outside the shell.
- Git history (10 commits) suggests this is still an actively evolving MVP — expect incomplete edge cases and be ready to add missing error/empty states rather than assuming they exist.

## Open questions / things to confirm with the user if relevant

- Whether Hive is actually wired in yet (not seen in `pubspec.yaml` dependencies as of last check — guardrails mandate it for structured local data, but only `shared_preferences` + `flutter_secure_storage` are currently used). Confirm before assuming Hive is available.
- Whether `freezed` is in use — not present in `pubspec.yaml` either, despite guardrails requiring it for entities/state. Worth flagging if asked to add immutable models.

## Log

- 2026-07-17: Created `context.md` and `memories.md` after full review of `.agents/rules/*`, `pubspec.yaml`, `lib/` feature tree, `openapi.json`, and git log.
</content>
- 2026-10-30: Added `lib/features/call_request/` (paid 1:1 call requests: form + status sheet, hooked into `TruckDetailsSheet`'s "Request 1:1"). Behind `FeatureFlags.oneToOneEnabled` (off) and the dev-only `devWalletCreditEnabled` (off; never true against the shared DB). `build_runner` is broken (prompts to delete 26 generated files, then crashes) so its `.g.dart` and one provider in `wallet_notifier.g.dart` are hand-written. Backend contract: `convoy_prod/docs/ONE_TO_ONE_CALL_API.md`. `test/widget_test.dart` is Flutter's template test and has always failed.
- 2026-10-30: Stage 4 of the 1:1 calls: driver side in `lib/features/call_request/` (Home banner `IncomingRequestBanner`, review sheet `IncomingRequestSheet`, queue polling `IncomingCallRequestsNotifier`, push handling via `core/services/push_events_service.dart` + `CallPushListener` watched from `App`). Banner shows only on Home, only while Home is the visible tab (TickerMode). The feature-flag check lives in `HomeScreen`, not in the banner. Generated Riverpod files still hand-written (build_runner broken). Starting the call (driver) arrives with the call screens.
- 2026-10-30: Stage 5 of the 1:1 calls: the call itself in `lib/features/call_request/`. Layers: `media/` (a `CallMediaEngine` interface + `AgoraCallMediaEngine`; `CallPermissions`), `presentation/call/` (`CallSessionNotifier` = the whole call's logic: permissions -> start/join -> media -> 5 s heartbeats -> end, plus behaviour-event batching; screens `LiveCallScreen`, `IncomingCallScreen`, `RejoinScreen`, `FeedbackScreen`/`SatisfactionPrompt`; `CallCoordinator` in `App`'s builder brings up ring / rejoin / feedback by itself, only when `oneToOneEnabled`). New providers are **hand-written** (`state/call_providers.dart`, `outgoing_requests_notifier.dart`, `callSessionProvider`), not generated. **Chat rides Agora's RTC data stream, not RTM** (RTM is blocked on the console and drags in a second SDK + pod/ffi workarounds). The class name `CallScreen` was already taken by the phone-dial screen in `features/call`, so the live one is `LiveCallScreen`. Test gotchas: `testWidgets` has no real event loop (a bare `await` on a controller future hangs; pump instead), awaiting `StreamSubscription.cancel()` or `StreamController.close()` hangs under fake time (don't await them), and keepAlive providers need an explicit `container.dispose()` before the test ends. Native: `permission_handler` needs `PERMISSION_CAMERA/MICROPHONE=1` in the Podfile `post_install`; run `pod install` with `LANG=en_US.UTF-8`.
- 2026-10-30: Stage 6 (ring like a phone call) and Stage 7 (Razorpay recharge) of the 1:1 calls. Stage 6: `lib/features/call_request/incoming_call/` (`IncomingCallUi` interface; iPhone = own native CallKit+PushKit layer in `ios/Runner/AppDelegate.swift` over channel `convoy/callkit` because the scene-based startup may not have loaded plugins when a VoIP push wakes a closed phone; Android = `flutter_callkit_incoming` + data-only push + `call_background_handler.dart` registered in `main.dart`; `IncomingCallController` watched from `App`; `callKitShownProvider`/`pendingAnsweredCallProvider` link it to `CallCoordinator`), Android foreground service `CallForegroundService.kt` (channel `convoy/call_service`), VoIP token sync in `features/devices`. Stage 7: `lib/features/wallet/` (domain/data `recharge_*`, `data/gateway/razorpay_gateway.dart`, `presentation/state/recharge_controller.dart` stays alive while a payment is in flight, `widgets/recharge_sheet.dart`), flag `rechargeEnabled`. All new providers hand-written. Podfile pins pods to iOS 15.6 and enables permission_handler flags; Android `compileSdk` is `max(flutter, 37)`. Flags remain false.
