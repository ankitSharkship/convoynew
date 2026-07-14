---
trigger: always_on
---

You are a senior Flutter engineer. This file complements
`flutter-agent-rules.md` (architecture) — that file governs *structure*,
this file governs *behavior*: error handling, approved tooling, and hard
guardrails. Both apply together on every feature; if they ever conflict,
flag it instead of silently picking one.

# 1. Error Handling (MANDATORY)

## 1.1 Contract with the backend
- Every API error response follows the envelope:
  `{ "success": false, "error_message": "...", "error_code": "..." }`.
- If `error_message` is present, show it to the user verbatim (no
  rewording). If it's missing/null, show **"Something went wrong"**.
- Never show the user: raw `DioException` text, `error.toString()`,
  stack traces, HTTP status codes, or backend-internal `error_code`
  values — `error_code` is for client-side branching logic only
  (e.g. `otp_expired` → show a "resend" button), never for display text.

## 1.2 Where errors are caught
- Errors are caught **once**, at the repository boundary, and converted
  into a sealed `Failure` type (or `AppException`) — never let a raw
  `DioException`/`SocketException`/`FormatException` escape the data
  layer.
- Notifiers/state classes never receive raw exceptions — they receive
  typed failures and map them to UI state.
- Use `AsyncValue` (Riverpod) or a custom sealed `Result<T>` — pick one
  per feature based on complexity, but never leave a "success-only" state
  shape that has no way to represent failure.

## 1.3 How errors surface in UI
- Every screen with async data must implement all four states explicitly:
  **loading, success, empty, error.** No screen ships with only a happy
  path.
- Error UI must match the failure's blast radius:
  - Full-screen fetch failure (e.g. can't load search results) →
    inline error state with retry button, not a Snackbar.
  - Action failure (e.g. post truck, submit OTP) → Snackbar or inline
    field error, not a full-screen replacement.
  - Background/non-critical failure (e.g. failed to refresh a badge
    count) → fail silently or log only, never interrupt the user.
- Use `shared/widgets/loader.dart` for loading and a shared
  `ErrorStateView`/`EmptyStateView` widget for error/empty — do not
  hand-roll ad hoc error widgets per screen.
- Network connectivity errors get a distinct, recognizable message
  ("No internet connection — check your network and try again") rather
  than falling through to the generic "Something went wrong."

## 1.4 Logging
- Log the real exception (with stack trace) via a single logging utility
  in debug/staging; never `print()`.
- In release builds, never log PII (phone numbers, OTPs, tokens, KYC
  data) — redact before logging, same standard as the backend.
- Every caught exception at the repository boundary is logged before
  being converted to a `Failure`, so nothing fails silently in
  development even though the user only ever sees the friendly message.

# 2. Approved Stack — Use These, Nothing Else Without Asking

| Concern | Use | Do NOT use |
|---|---|---|
| State management | Riverpod (codegen, `@riverpod`) | `Provider` package, `GetX`, `Bloc`, raw `ChangeNotifier` |
| Networking | `Dio` with a single configured client + interceptors | `http` package, raw `HttpClient`, ad hoc `Dio()` instances per feature |
| Routing | `GoRouter` | `Navigator` imperative pushes for top-level flows (fine for dialogs/bottom sheets only) |
| Local persistence | `Hive` for structured local data, `flutter_secure_storage` for tokens/secrets | `shared_preferences` for anything sensitive, raw file I/O for structured data |
| Forms | `flutter_hooks` + explicit `TextEditingController`s, or Riverpod-backed form state | `flutter_form_builder` unless already in use elsewhere in the app |
| Immutable models | `freezed` for entities/state classes | Hand-rolled `copyWith`, mutable model classes |
| JSON parsing | `json_serializable` via codegen | Manual `fromJson`/`toJson` written by hand for anything beyond 2-3 fields |
| Env config | `.env` via `flutter_dotenv` or compile-time `--dart-define`, read once in `core/config.dart` | Hardcoded base URLs / secrets in source files |
| Icons | Single icon font or SVG set mapped through `AppIcons` (see design.md) | Mixing multiple icon packages in one screen |

If a task seems to need something outside this table, state the gap and
propose an addition — don't silently pull in a new dependency.

# 3. Networking Guardrails

- One `Dio` instance, configured once in `core/network/dio_client.dart`,
  injected via Riverpod provider — never instantiate `Dio()` inline in a
  datasource.
- All requests go through a shared interceptor chain that handles:
  auth header injection, token refresh on 401, request/response logging
  (debug only), and the error-envelope parsing from §1.1.
- Timeouts are explicit and set on the shared client (connect, send,
  receive) — never rely on Dio defaults.
- Retries (if any) are limited, exponential-backoff, and only applied to
  idempotent GET requests — never auto-retry a POST that creates a
  resource (e.g. "Post a Truck") without explicit dedup protection.
- No datasource catches an exception and returns `null`/an empty object
  to hide a failure — failures must propagate as `Failure`, not silent
  defaults.

# 4. State & Widget Guardrails

- No `BuildContext` used after an `await` without checking `context.mounted`
  first.
- No business logic inside `build()` methods — `build()` only reads state
  and lays out widgets.
- Prefer `ConsumerWidget`/`HookConsumerWidget` over `StatefulWidget`; only
  use `StatefulWidget` for genuinely local, ephemeral UI state
  (animation controllers, scroll controllers) that has no business
  meaning.
- No `setState` calls that mutate anything beyond purely visual, local
  widget state.
- All user-facing strings go through localization (`.arb`/`intl`) — no
  hardcoded English/Hindi strings inline in widgets, since the app must
  support multiple languages (see design.md §7).
- Every list of unknown/variable length uses `ListView.builder` /
  `SliverList` — never `ListView(children: [...])` for dynamic data.
- Widgets that don't depend on external state are `const` wherever
  possible.

# 5. Security Guardrails

- Tokens (JWT, refresh tokens) live only in `flutter_secure_storage` —
  never in `Hive`, `shared_preferences`, or in-memory-only if the app
  needs persistence across restarts.
- OTPs are never stored on-device beyond the input field's lifetime; not
  cached, not logged, not kept in Riverpod state after verification
  completes.
- No API keys or secrets committed to source — pulled from `.env`/
  `--dart-define` and referenced through `core/config.dart` only.
- Certificate pinning / base-URL validation lives in `dio_client.dart`,
  not duplicated per feature.

# 6. Forbidden Patterns

- ❌ Business logic in widgets/screens
- ❌ Direct Dio/API calls from a widget or notifier (must go through
     repository → usecase per `flutter-agent-rules.md`)
- ❌ Showing raw exception text, stack traces, or backend `error_code`
     strings to the user
- ❌ `print()` anywhere in the codebase (use the shared logger)
- ❌ New third-party packages introduced without checking §2 first
- ❌ `shared_preferences` for tokens or any sensitive data
- ❌ Catching an exception and swallowing it silently (empty catch block)
- ❌ Screens with only a happy-path state (no loading/empty/error)
- ❌ Hardcoded user-facing strings bypassing localization
- ❌ `StatefulWidget` used to hold business/domain state

# 7. Behavior

- If a package or pattern isn't covered in §2, don't guess — name the gap
  and propose the closest approved alternative before proceeding.
- Every generated feature must implement all four UI states (§1.3) even
  if the initial ask only mentions the happy path.
- Maintain consistency with previously generated features — if an error
  pattern, retry policy, or widget already exists for a similar case,
  reuse it rather than inventing a variant.
- When in doubt about severity/placement of an error (Snackbar vs
  inline vs full-screen), default to the least disruptive option that
  still clearly communicates the failure.

Failure to follow these rules means the output is incorrect.
