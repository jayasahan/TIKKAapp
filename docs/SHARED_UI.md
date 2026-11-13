# TIKKA Shared UI and Navigation

**Status:** Phase 03 implementation draft on `feature/shared-ui-navigation`. Routes and reusable components are available for review; product and backend contracts remain subject to the approvals in [SHARED_CONTRACTS.md](SHARED_CONTRACTS.md).

## App entry and navigation

`MyApp` in `lib/app/app.dart` supplies the shared theme and delegates named routes to `AppRouter`. `AppRoutes` in `lib/app/router/app_routes.dart` is the source for route paths and parameter builders. Phase 03 uses Flutter's built-in `Navigator` and `MaterialPageRoute`; no router or state-management package was added. Whether to retain this router long term is still a team decision.

The app currently starts on `/home` to preview the four-destination shell. This is a development entry point, not the final authentication bootstrap. Phase 04 must replace it with session restoration and public/protected route handling. Routes are placeholders only; they do not authenticate users or provide backend authorization.

| Route | Destination | Phase 03 behavior |
|---|---|---|
| `/splash` | Welcome | Placeholder |
| `/auth/login` | Sign in | Placeholder |
| `/auth/register` | Create account | Placeholder |
| `/auth/verify-email` | Verify email | Placeholder |
| `/auth/forgot-password` | Forgot password | Placeholder |
| `/auth/reset-password` | Reset password | Placeholder |
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

This phase supplies navigation paths, shared UI primitives, theme tokens, and temporary destination placeholders. It does not implement authentication, session restoration, route guards, service content, booking behavior, profile behavior, tracking, reviews, or Supabase access. Phase 04 owns auth/session integration. Feature owners should replace their placeholders and coordinate path or shared-contract changes through the decision register.
