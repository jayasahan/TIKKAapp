# TIKKA Shared UI and Navigation

**Status:** Phase 03 was merged in PR #19. Phase 04 now uses the shared components for its auth forms; feature-owned destination screens remain placeholders. Contract status is recorded in [SHARED_CONTRACTS.md](SHARED_CONTRACTS.md).

## App entry and navigation

`MyApp` in `lib/app/app.dart` supplies the shared theme and delegates named routes to `AppRouter`. `AppRoutes` in `lib/app/router/app_routes.dart` is the source for route paths and parameter builders. The app uses Flutter's built-in `Navigator` and `MaterialPageRoute`; no router or state-management package was added. Whether to retain this router long term is still a team decision.

The app preview mode starts on `/home`. The Android entry point initializes Supabase and uses the splash/login flow for signed-out users, restores verified sessions to the customer shell, and guards protected routes. Route guards are client navigation behavior; database access must still be secured by Supabase RLS. Auth routes are implemented; service and other feature routes remain placeholders.

| Route | Destination | Current behavior |
|---|---|---|
| `/splash` | Welcome | Figma-inspired splash; continue to sign in |
| `/auth/login` | Sign in | Supabase email/password sign-in; Google button deferred |
| `/auth/register` | Create account | Name/email/phone/password validation and email signup |
| `/auth/verify-email` | Verify email | Confirmation guidance and resend action |
| `/auth/forgot-password` | Forgot password | Generic password recovery request confirmation |
| `/auth/reset-password` | Reset password | Password update following recovery callback |
| `/home` | Home tab | Customer shell placeholder |
| `/services` | Services tab | Customer shell placeholder |
| `/services/:serviceId` | Service details | Feature placeholder |
| `/bookings/new/:serviceId` | Booking step 1 | Feature placeholder |
| `/bookings/confirm` | Booking step 2 | Feature placeholder |
| `/requests` | Requests tab | Customer shell placeholder |
| `/requests/:requestId` | Request tracking | Feature placeholder |
| `/profile` | Profile tab | Customer shell placeholder |
| `/profile/edit` | Edit profile | Feature placeholder |
| `/requests/:requestId/review` | Review request | Feature placeholder |

The shell displays Home, Services, Requests, and Profile in that order. Selecting a tab replaces the current named route. The Figma booking flow hides bottom navigation, so booking routes resolve to standalone placeholders.

## Shared components

Import components from their focused files under `package:tikka/core/widgets/`. Prefer the shared theme and spacing constants over feature-local copies.

- `TikkaButton`: primary, secondary, and text variants; 52 px high. Set `fullWidth: true` for a parent-width action.
- `TikkaTextField`: label and hint, optional controller/focus node, keyboard/autofill configuration, disabled state, and inline error state. It does not own or dispose an externally supplied controller or focus node.
- `TikkaAppBar`: 60 px app bar with optional eyebrow, back callback, and action.
- `TikkaBottomNavigation`: four destinations and selected-state semantics. Its parent handles navigation.
- `TikkaLoadingState`: 120 px state using the bundled 28 × 28 Figma indicator at `assets/icons/loading_indicator.svg`.
- `TikkaEmptyState`: centered title/message in a 180 px default region; height can be overridden.
- `TikkaErrorState`: generic retry/error presentation. This is an implementation convenience, not an error design observed in Figma.
- `TikkaPage`: top-centered content constrained to a configurable maximum width, with 16 px default padding.
- `FeaturePlaceholderScreen`: temporary route placeholder used until the owning feature supplies its screen.

The development shell currently uses `AppShell` and `CustomerDestination` under `lib/app/navigation/`. Feature-owned screens may reuse these widgets; shared components must not import feature code.

## Theme and bundled design assets

`AppTheme` and its `AppColors`, `AppSpacing`, and `AppRadii` constants are in `lib/app/theme/app_theme.dart`. The Inter variable font is bundled at `assets/fonts/Inter-Variable.ttf`; its license is `assets/fonts/OFL.txt`.

| Token | Value |
|---|---|
| Brand yellow | `#FCE314` |
| Text / black | `#000000` |
| White surface | `#FFFFFF` |
| Default background | `#F7F7F5` |
| Secondary text | `#777770` |
| Border | `#D4D4D0` |
| Success / warning / error / info | `#17803D` / `#B85C00` / `#C92A2A` / `#1F66D1` |
| Button / input / card / nav radius | 14 / 12 / 16 / 20 px |
| Button / app bar / navigation height | 52 / 60 / 74 px |

The theme defines Inter Display 36/44 bold; H1 28/36 bold; H2 22/30 semibold; H3 18/26 semibold; body 16/24; body small 14/20; label 14/20 medium; and caption 12/16. Figma Foundations specifies a 20 px default screen margin, while screen frames commonly use 16 px. `TikkaPage` and the shell currently use 16 px; confirm the shared margin with the team before standardizing feature layouts.

## Phase boundary and handoff

The shared UI phase supplied navigation paths, reusable UI, theme tokens, and temporary destination placeholders. Phase 04 added the auth/session integration described in [AUTHENTICATION.md](AUTHENTICATION.md). Feature owners should replace their placeholders and coordinate path or shared-contract changes through the decision register.
