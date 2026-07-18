# Convoy (convoynew) — Project Context

## What it is

Convoy is a Flutter mobile app for Sharkship — a truck discovery and availability marketplace for Indian highway trucking (fleet owners posting available trucks, shippers/transporters searching for trucks on a route). Backend is a FastAPI service ("Convoy API", repo `SkandTrizip/convoy_prod`) at `https://convoy.logipod.in/`, all routes under `/api`. Package name: `convoynew`, version `1.0.0+4`.

## Governing rule files (`.agents/rules/`, all `trigger: always_on`)

- **flutter-agent-rules.md** — mandates Clean Architecture (`data/domain/presentation` per feature) + Riverpod codegen + Dio, strict UI → Notifier → UseCase → Repository → DataSource → API data flow, no layer-skipping, no raw exceptions shown to users ("Something went wrong" fallback), output must include full folder structure + code + imports on every feature request.
- **flutter-guardrails.md** — behavioral companion: error envelope contract `{success, error_message, error_code}`, errors caught once at repository boundary into a `Failure`/`AppException`, four mandatory UI states (loading/success/empty/error) sized to blast radius (full-screen vs snackbar vs silent), approved stack table (Riverpod codegen, Dio, GoRouter, Hive + flutter_secure_storage, freezed, json_serializable, flutter_dotenv), security rules (tokens only in secure storage, no OTP persistence, no hardcoded secrets), forbidden patterns list (print(), business logic in widgets, empty catch blocks, etc).
- **design.md** — full design system source of truth: saffron/orange-on-cream palette (`colorPrimary #EA6423`, `colorBackground #FDF1E7`, etc.), typography scale, 4px spacing grid, full component library (PrimaryCta, Voice CTA Card, AppFieldTile, Route Stepper, AppDropdownTile, Truck Card, Result/Person Card, Segmented Toggle, Hero Promo Banner, Quick Action Grid, custom top bar, bottom nav, Trust Badge Row), and per-screen layout patterns (Login, Home, Post Truck, Search Trucks, Search Results). New screens must reuse these tokens/components before inventing anything new.

These three files apply together on every feature; conflicts between them should be flagged, not silently resolved.

## Tech stack

- **State**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator` (codegen `@riverpod`, `.g.dart` parts everywhere)
- **Networking**: `dio` — single client in `core/network/dio_client.dart`
- **Routing**: `go_router` (`core/router/app_router.dart`)
- **Local storage**: `shared_preferences` (onboarding flags, non-sensitive prefs) + `flutter_secure_storage` (tokens)
- **Location**: `geolocator` + `geocoding`
- **Contacts**: `flutter_contacts` + `crypto` (phone hashing for mutual-contacts matching)
- **i18n**: `flutter_localizations` + `intl`, `.arb` files for **English, Hindi, Kannada, Marathi** (`lib/l10n/`)
- **Icons/splash**: `flutter_launcher_icons`, `flutter_native_splash`
- **Env**: `flutter_dotenv`, reads `.env` (`API_BASE_URL=https://convoy.logipod.in/`)
- **Deployment**: `shorebird.yaml` present — Shorebird code push configured
- Lints: `flutter_lints` + `custom_lint`/`riverpod_lint`

## Architecture as actually implemented

`lib/features/<feature>/{data,domain,presentation}` for: `auth`, `call`, `contacts`, `home`, `kyc`, `onboarding`, `post`, `profile`, `search`, `splash`. Matches the mandated Clean Architecture layering closely (entities/repositories/usecases in domain; models/datasources/repository impls in data; notifiers + screens in presentation, all with `.g.dart` riverpod codegen parts).

`lib/core/`: `network/` (dio_client, api_exception, jwt_payload, token_storage), `router/` (app_router), `l10n/` (locale_notifier), `services/` (location_service), `theme/` (app_theme), `constants/` (app_colors).

`lib/shared/`: cross-feature widgets (`loader.dart`, `main_shell.dart` bottom-nav shell, `sheet_form_field.dart`, `suggestions_overlay.dart`, `location_permission_dialog.dart`, `language_switcher_button.dart`, `borderless_input_decoration.dart`) and utils (`phone_number_formatter`, `truck_type_i18n`, `truck_type_image`).

### Auth flow
Phone + OTP login (`/api/auth/send-otp`, `/api/auth/verify-otp`). `dio_client.dart` attaches `Authorization: Bearer <token>` from `TokenStorage` (secure storage) on every request; on a 401 from an **authenticated** endpoint it clears the stored session (logs the user out), but explicitly does NOT clear on 401 from the unauthenticated OTP endpoints themselves (documented in code comments) — no refresh-token endpoint exists yet.

### Navigation
`GoRouter` with a top-level route list plus a `StatefulShellRoute.indexedStack` (`MainShell`) for the 3 bottom-nav tabs: `/home`, `/search`, `/profile`. Other routes (`/splash`, `/onboarding`, `/auth/phone`, `/auth/otp`, `/call`, `/post` (+ `success`/`edit`), `/search/results`, `/profile/vehicles`, `/profile/trips`, `/home/manage`, `/kyc` (+ `otp`)) sit outside the shell.

### Key domain features
- **post**: post a truck (trip), manage vehicles ("my trucks"), manage trips ("my posts"), vehicle verification (DL/vehicle docs)
- **search**: search trucks by route/type/capacity, location autocomplete, search results, demand tracking/call logging
- **kyc**: Aadhaar OTP-based KYC verification gating truck posting (`post_truck_gate.dart`)
- **contacts**: device contact sync (hashed phone matching) to surface "mutual contacts" against search results/trucking network
- **home**: recent post/search history, quick actions
- **call**: in-app call screen (name/phone/initials passed via query params) for contacting drivers/owners

### Backend API surface (from `openapi.json`, v1.0.0)
Auth (`send-otp`, `verify-otp`), KYC (`aadhaar/send-otp`, `aadhaar/verify`, `status`, `submit`), vehicle (`add`, `list`), verification (`batch`, `dl`, `vehicle`), posts (`create`, `delete`, `my-posts`, `reactivate`), trucks (`search`, `{truck_route_id}`, list), search (`trucks`, `log-call`, `track-demand`), locations (`search`), truck-types, user profile + push-token, notifications, bookings, admin (analytics, KYC review).

## Notable conventions / gotchas

- No `.env` secrets in source; base URL is the only value in `.env` and it's already committed to this workspace (dev convenience) — do not add real secrets there.
- All 4 UI states (loading/success/empty/error) are expected on every async screen; reuse `shared/widgets/loader.dart` and shared error/empty widgets rather than one-off widgets.
- Multi-language support (EN/HI/KN/MR) is load-bearing for the target audience — no hardcoded user-facing strings; always go through `.arb`/`AppLocalizations`.
- Design tokens must come from `lib/design_system/tokens.dart`-style centralization (per design.md) — avoid inline hex colors/spacing literals.
- Git history shows this was built feature-by-feature in a fairly short, active sprint (10 commits: initial setup → search/post/manage trucks → translations → onboarding/trips → UI passes → mutual contacts → Kannada + truck images), i.e. still an actively evolving MVP, not a mature/stable codebase.
</content>
