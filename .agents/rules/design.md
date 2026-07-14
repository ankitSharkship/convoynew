# Design System — Convoy App (Flutter)

This document is the source of truth for visual design, layout, and component
behavior. It is derived from the approved screenshots (Login, Home, Post
Truck, Search Trucks, Search Results). **Follow it exactly** — do not
introduce new colors, radii, spacing values, or component patterns without
checking this file first. If a screen isn't covered here, extrapolate using
the tokens and component rules below rather than inventing new ones.

---

## 1. Brand Personality

- **Warm, trustworthy, driver-first.** The palette is saffron/orange on a
  soft cream base — evokes Indian highway trucking culture without being
  garish.
- **Voice-first, low-friction.** Primary actions are large, thumb-reachable,
  and text is short. Assume some users are on budget Android devices with
  variable literacy — prioritize icons + big tap targets over dense text.
- **Verified & safe.** Trust signals (verified badges, "Secure Login",
  "24×7 Support") appear near anything involving another person or a
  transaction.

---

## 2. Color Tokens

Define these as `ThemeData` extensions / constants — never hardcode hex
values inline in widgets.

| Token | Hex | Usage |
|---|---|---|
| `colorPrimary` | `#EA6423` | Primary CTAs, active nav icon/label, links, icons on light bg, accent bars |
| `colorPrimaryDark` | `#C4501A` | Pressed/hover state of primary buttons |
| `colorPrimarySurface` | `#FCEFE3` | Light tint of primary — badges, subtle fills, dashed-border button fill |
| `colorBackground` | `#FDF1E7` | App scaffold background (the warm cream, used on nearly every screen) |
| `colorSurface` | `#FFFFFF` | Cards, sheets, input fields |
| `colorSurfaceDark` | `#152238` | Hero/promo banner background (navy), used sparingly for high-contrast promo cards |
| `colorTextPrimary` | `#1A1A1A` | Headlines, primary body text |
| `colorTextSecondary` | `#6B7280` | Subtitles, helper text, labels like "ORIGIN" |
| `colorTextOnDark` | `#FFFFFF` | Text on navy/orange solid backgrounds |
| `colorBorder` | `#F0E3D6` | Card borders / dividers on cream background |
| `colorSuccess` | `#1FA35C` | Origin pin, GPS-detected badge, positive states |
| `colorDestination` | `#E8462F` | Destination pin (distinct red-orange from primary) |
| `colorVerifiedBlue` | `#3B82F6` | Verified checkmark badge only — do not reuse elsewhere |
| `colorIconMuted` | `#9CA3AF` | Inactive bottom-nav icons, filter/sort icon buttons |

**Rule:** Orange (`colorPrimary`) is reserved for the single most important
action on a screen. Never put two competing solid-orange buttons on one
screen — secondary actions use outline/dashed/ghost style instead.

---

## 3. Typography

Use a single geometric sans-serif (e.g. **Inter** or **Poppins** — pick one
and load via `google_fonts`, do not mix). Scale:

| Style | Size / Weight | Usage |
|---|---|---|
| `displayGreeting` | 24sp / SemiBold | "Good morning 👋", screen H1 ("Post Your Truck") |
| `headline` | 18sp / SemiBold | Card titles, person names ("Akash Patil") |
| `subtitle` | 14sp / Regular, `colorTextSecondary` | Screen subheads ("Verified requests in 30 seconds") |
| `bodyLarge` | 16sp / Medium | Route city names, primary values |
| `body` | 14sp / Regular | Standard body text |
| `label` | 12sp / Medium, uppercase, `colorTextSecondary`, letter-spacing 0.5 | Field labels ("ORIGIN", "DESTINATION 1", "SELECT TRUCK") |
| `caption` | 12sp / Regular, `colorTextSecondary` | Timestamps, meta info |
| `button` | 16sp / SemiBold | All button labels |

All headline/title text is `colorTextPrimary`; never gray-on-gray for
anything the user must read to act.

---

## 4. Spacing & Layout

- **Base unit: 4px.** All padding/margins are multiples of 4 (8, 12, 16, 20,
  24).
- **Screen horizontal padding:** 20px both sides, consistently, on every
  screen.
- **Card padding:** 16px internal on all sides.
- **Vertical rhythm between major sections:** 24px.
- **Vertical rhythm between related items inside a card:** 12px.
- **Card corner radius:** 20px for primary cards/hero banners, 16px for
  nested content blocks (truck list items, search result rows), 14px for
  buttons and input fields, full-pill (999px) only for the tab
  toggle/segmented control.
- **Elevation:** Cards use a soft, low-opacity shadow (`blurRadius: 12,
  opacity: 0.05, offset: (0,4)`) rather than Material default elevation —
  keep it subtle, the app has almost no visible drop shadows.
- **Bottom nav bar:** fixed, 4 items, safe-area aware, lives outside scroll
  content on every authenticated screen.

---

## 5. Component Library

Build every one of these as a shared, reusable widget under
`lib/design_system/components/`. Screens must compose these, not
reimplement styling ad hoc.

### 5.1 Primary Button (`PrimaryCta`)
- Full width (minus screen padding), height 56px, radius 14px.
- Fill: `colorPrimary`. Label: white, `button` style, centered, with a
  trailing arrow icon (`→`) when the action navigates forward (e.g. "Post a
  Truck →", "Find Trucks →", "Continue with Mobile Number →").
- Disabled state: `colorPrimary` at 40% opacity, no arrow removed (keep
  layout stable).

### 5.2 Voice CTA Card
- Large rounded (24px) solid `colorPrimary` card, used only for the single
  hero voice action on a screen (e.g. "Speak to Post").
- Contains: centered circular white icon button (mic), bold white title,
  white/90%-opacity supporting line with an example phrase in quotes, small
  row of supported-language chips (checkmark + language name, white text at
  reduced opacity), then a white pill button with orange text + mic icon
  inside the card ("Start Voice Posting").
- Use for any "let the user speak instead of typing" entry point.

### 5.3 Input / Selector Field (`AppFieldTile`)
- White (or `colorPrimarySurface` when read-only/auto-filled) rounded
  rectangle, 14px radius, 1px `colorBorder`, min height 56px.
- Layout: leading icon slot (pin, optional), label above value in `label`
  style, value/placeholder below in `bodyLarge`, trailing chevron (`>`) for
  navigable selectors OR a circular icon button (locate/target icon in
  `colorPrimary`) for "use current location" actions — never both.
- Placeholder text uses `colorTextSecondary` ("Select Origin", "Select
  Destination").
- When a field is auto-filled via GPS, show a small pill badge below the
  value: green dot/pin icon + "GPS Auto-detected" text, `colorSuccess` on
  `colorPrimarySurface`-tinted-green background.

### 5.4 Route Stepper (origin → destination)
- Vertical layout: green filled circle (origin) — dotted vertical
  connector line — orange/red pin icon (destination).
- Each destination row is itself an `AppFieldTile`. Support **multiple
  destinations**: label them "Destination 1", "Destination 2", etc., each
  with a small circular "×" remove button top-right when count > 1.
- Below the last destination, a dashed-border pill button in
  `colorPrimarySurface` fill, `colorPrimary` text/icon, "+ Add Destination".
  This dashed style is reserved specifically for "add another item" actions.

### 5.5 Dropdown Select (`AppDropdownTile`)
- Same shell as `AppFieldTile` but two sit side-by-side in a row with 12px
  gap (e.g. Truck Type / Capacity), each taking 50% width, with a
  down-chevron trailing icon instead of a forward chevron.

### 5.6 Selectable List Item — Truck Card
- Horizontal row inside the parent card: leading 56×56 rounded-12px image
  thumbnail, then vehicle number in `headline`-weight (semibold, larger than
  body), then a single meta line below in `caption`/`body-secondary`
  style using " • " as separator (e.g. "Container • 32 Ft • 25 Ton").
- Selected state gets a `colorPrimarySurface` fill + 1.5px `colorPrimary`
  border; unselected state is plain white/transparent with `colorBorder`.
- List ends with the same dashed "+ Add New Truck" pattern as 5.4.

### 5.7 Result / Person Card
- Used for search results and any "contact a person" context.
- Top row: circular avatar (44px) + name in `headline` + verified badge
  (small filled blue circle with white checkmark, immediately after name,
  never separated) — pushed left; a circular orange icon button (phone)
  pinned top-right of the row for the primary contact action.
- Below: the Route Stepper mini-version (no editing, just green/red pins +
  city names) reusing 5.4's visual language but non-interactive.
- Footer row: 3 meta columns (Truck Type / Capacity / Date), each with a
  small muted icon above/beside a `label` + `body` value pair, evenly
  spaced (`MainAxisAlignment.spaceBetween`).

### 5.8 Recent Item Row (searches / posts)
- Compact white card: route as "City A → City B" in `bodyLarge`-semibold on
  one line, meta line below in `caption` ("Container • 30 Ton • 12 Jun
  2026"), trailing circular action button (orange fill, icon-only —
  magnifying glass for "search again" / "Repost" as a labeled orange pill
  button depending on context).
- On the Home screen, "Repost" is a small outlined-or-filled orange pill
  button with text, not icon-only — match screenshot exactly: solid
  `colorPrimary` pill, white "Repost" label, compact (not full width).

### 5.9 Segmented Toggle (`AppSegmentedTab`)
- Two options only (e.g. "Recent Posts" / "Recent Search"), full-pill
  container in `colorBackground`/light gray, active segment is a dark
  filled pill (`colorSurfaceDark`/near-black) with white text, inactive
  segment is transparent with `colorTextSecondary` text. Animate the
  active-pill transition.

### 5.10 Hero Promo Banner (Home)
- Full-width card, `colorSurfaceDark` (navy) background, 20px radius.
- Left-aligned white bold headline (2 lines max, e.g. "Your truck is ready
  to earn"), muted white subtext line below, then a compact `PrimaryCta`
  -style button (not full width here — intrinsic width, "Post Truck Now
  →").
- Right side: truck illustration/photo bleeding to the card edge, may
  overflow the top-right corner slightly for visual interest.

### 5.11 Quick Action Grid
- Two equal-width cards side by side, white fill, 16px radius, 16px
  padding. Each: a small square icon tile (rounded 12px,
  `colorPrimarySurface` fill, colored icon) top-left, title in `headline`
  below, one-line `caption` description below that.

### 5.12 Top App Bar Pattern
- No traditional `AppBar` — headers are custom, left-aligned text stack
  (greeting/eyebrow line + bold page title), right-aligned circular icon
  button cluster (language toggle "A/अ", notification bell with red dot
  badge when unread). Keep this consistent across all authenticated
  screens; height ~64px including top safe area padding.
- On list/results screens, the right cluster instead holds
  filter/sort/language icon buttons — square, 40×40, `colorSurface` fill,
  `colorBorder` outline, muted icon color, 12px radius, spaced 8px apart.

### 5.13 Bottom Navigation
- 4 fixed items: Home, (My Trucks / Search Trucks — label is
  context-sensitive per role, see §7), Trips/Post Truck, Profile.
- Active item: `colorPrimary` icon + label. Inactive: `colorIconMuted` icon
  + label, no fill/pill background (plain icon+label, not a filled
  indicator).
- Icons are outline-style (not filled) at rest; the app does not use a
  filled/outline swap on selection — color change is the only signal.

### 5.14 Trust Badge Row (Login/onboarding only)
- Row of 3 items, evenly spaced, each: small green checkmark + short label
  ("Verified Drivers", "Secure Login", "24×7 Support"), `caption` size,
  `colorTextSecondary` text with `colorSuccess` check icon. Centered under
  the primary CTA.

---

## 6. Screen-Level Patterns

### 6.1 Login / Auth
- Full-bleed hero photo (no padding) occupying top ~45% of screen, status
  bar icons in white/light mode over the image.
- Content sheet below is NOT a rounded bottom-sheet overlay — it's a flat
  continuation on `colorBackground`, padded 20px.
- Phone input: flag/country-code chip (`+91`) + divider + numeric field,
  inside one `AppFieldTile`-style shell.
- Primary CTA directly below input, trust badge row directly below that.
  No extra marketing copy — this screen must stay minimal and fast.

### 6.2 Home
- Order top-to-bottom: custom header → hero promo banner → "Quick Actions"
  section label + grid → "Manage Post & Searches" label + segmented toggle
  → list of recent item rows → bottom nav.
- Section labels are `headline` weight, 16-20px, with 12px gap before the
  content below them and 24px gap from the section above.

### 6.3 Post Truck (form-heavy creation flow)
- Order: header → Voice CTA card → "or fill manually" divider (thin line +
  centered italic `caption` text) → Route section card (label "ROUTE" +
  route stepper) → Select Truck section card (label "SELECT TRUCK" + truck
  list) → sticky/bottom primary CTA ("Post a Truck →").
- Every logical group (Route, Select Truck) is its own white card with a
  small uppercase section `label` at the top-left before its content —
  reuse this "card with eyebrow label" shell for any new form section.

### 6.4 Search Trucks
- Single consolidated white card holds Origin, Destination, Truck Type,
  Capacity, and the primary CTA — this is the one exception where a
  `PrimaryCta` lives inside a card rather than full-bleed on the page,
  because it's the card's own submit action.
- "Recent Searches" below, using the Recent Item Row component, each with a
  small orange circular search icon-button trailing.

### 6.5 Search Results
- Summary card first (shows the query itself, read-only route + meta,
  "Edit Search" link in `colorPrimary` bottom-right, no icon) — this acts
  as a persistent filter recap.
- Followed by a scrollable list of Result/Person Cards (§5.7).
- Result count shown in the header subtitle area ("2 trucks found").

---

## 7. Content & Copy Rules

- Keep all button labels to 2-4 words, action-first ("Find Trucks", "Post a
  Truck", "Continue with Mobile Number").
- Use directional arrows (`→`) on forward-moving primary actions only.
- Dates in `DD Mon YYYY` format (e.g. "12 Jun 2026").
- Truck meta strings are always `Type • Size/Capacity • Weight` joined with
  " • " — keep this exact separator app-wide for scannability.
- Support at minimum Hindi + English copy; the language toggle icon ("A/अ")
  must appear on every primary screen header, top-right.

---

## 8. Flutter Implementation Notes

- Centralize tokens in `lib/design_system/tokens.dart` (colors, spacing,
  radii, text styles) and expose via a custom `ThemeExtension` on
  `ThemeData` — do not scatter `Color(0xFF...)` literals in screen files.
- Build components listed in §5 as standalone widgets under
  `lib/design_system/components/`, each with a documented public API
  (required params only, sane defaults) so screens stay declarative.
- Use `flutter_svg` or icon font for all iconography; keep a single
  `AppIcons` class mapping semantic names (`AppIcons.originPin`,
  `AppIcons.verifiedBadge`, etc.) to assets so icon swaps are one-line
  changes.
- Respect safe-area insets on every screen bottom (nav bar) and top (custom
  header) — do not rely on default `AppBar` safe-area handling since none
  of these screens use a Material `AppBar`.
- Buttons, cards, and fields should all pull radius/padding from tokens,
  not literals, so a future rebrand only touches `tokens.dart`.
- New screens: before building, check §5/§6 for an existing pattern to
  reuse. Only propose a new component if nothing here fits, and add it to
  this document when you do.
