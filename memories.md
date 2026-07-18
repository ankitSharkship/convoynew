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
