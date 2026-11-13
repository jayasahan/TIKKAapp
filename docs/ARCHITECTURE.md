# TIKKA Architecture

**Status:** Feature-first organization and team boundaries are confirmed project requirements. Shared UI and navigation are implemented on `feature/shared-ui-navigation` for review; long-term router, state-management, auth, and backend choices remain subject to the decision register.

## Product boundary

TIKKA is a customer-facing Android app built with Flutter and Dart. Supabase Auth and PostgreSQL are the intended identity and backend services. The minimal authorized administrative testing workflow is outside the customer app and is owned by Member 2. There is no admin or worker mobile app in the MVP.

## Feature-first structure

~~~text
lib/
  main.dart
  app/
    app.dart
    navigation/       # shared four-destination shell
    router/           # centralized route names and resolver
    theme/            # shared tokens and Material theme
  core/
    config/
    constants/
    errors/
    utils/
    widgets/          # reusable controls, layout, and UI states
  features/
    auth/
    services/
    bookings/
    profile/
    tracking/
    reviews/
~~~

App-wide setup, theme, and navigation belong under `lib/app`. Reusable cross-feature controls belong under `lib/core`. Feature-owned screens, repositories, and models belong under `lib/features/<feature>`. Add domain/application layers only when logic needs them; avoid boilerplate layers for every screen. The current Phase 03 app shell and route destinations are placeholders, not feature implementations.

## Responsibility boundaries

| Area | Owner | Boundary and handoff |
|---|---|---|
| App setup, shared architecture, router, shared UI, auth, integration | Member 1 — PrabodhaRanawaka | Owns `lib/app` and core contracts; publishes route, session, identity, and shared component interfaces. |
| Supabase backend, services, bookings, admin testing, Android release | Member 2 — ashuraweismann | Owns database schema, triggers, RLS and Storage policies, service catalog, booking persistence/status writes, and authorized backend test workflow. |
| Profile, tracking, reviews, QA, final docs | Member 3 — jayasahan | Owns profile display/editing, request history/tracking presentation, customer reviews, and functional QA. |

Feature owners should not depend on another feature’s screen internals. Cross-feature calls use documented route parameters and data contracts. Service and booking interfaces should be agreed between Members 1 and 2; profile and booking-contact snapshots between Members 2 and 3; status lifecycle between all three.

## Dependency direction and data access

**Confirmed project guidance:** keep UI and data access separate, use reusable shared UI, and follow feature-first organization.

**Proposed convention:** screen/presentation code calls feature-owned repositories or services. Those boundaries encapsulate Supabase queries and map backend failures to a small set of user-readable results. Widgets do not issue database queries directly. Avoid a general service locator, use-case layer, or cross-feature repository unless a demonstrated need justifies it.

Member 2 owns backend-enforced access. Use the signed-in Supabase identity for ownership checks, Row Level Security for tables, and Storage policies for uploaded booking photos. A client-side route guard is a navigation aid, not a security boundary. Never ship a service-role key in the Flutter app.

## Naming and code conventions

- Dart file and folder names: snake_case.
- Types and widgets: UpperCamelCase.
- Methods, variables, and parameters: lowerCamelCase.
- Keep one primary public widget or type per file where that improves discoverability; keep related private helpers close to their feature.
- Prefer const widgets and constructors where practical. Dispose owned text controllers and subscriptions.
- Keep validation at the form boundary and network/data failures at the repository boundary; display recoverable errors without crashing.
- Use shared theme and reusable controls rather than feature-specific copies.
- Format with `dart format lib test`. Run `flutter analyze` and `flutter test` for implementation changes.

## Navigation and access boundaries

`lib/app/router/app_routes.dart` centralizes route paths and parameter builders. `lib/app/router/app_router.dart` resolves them using Flutter's built-in `Navigator` and `MaterialPageRoute`, merged in Phase 03. The team has not decided whether to adopt a routing package such as go_router. Riverpod remains a state-management proposal; no state-management dependency was added.

The shared shell provides Home, Services, Requests, and Profile. `MyApp`'s preview mode enters `/home`; Android startup uses the Phase 04 auth bootstrap. Login, registration, verification, and recovery screens are implemented. Service details, booking, request tracking, profile editing, and review routes still display placeholders. The route map follows [SHARED_CONTRACTS.md](SHARED_CONTRACTS.md).

Phase 04 implements session-aware startup, public/protected route behavior, and logout navigation under the approved auth proposal; live Supabase settings remain unverified. The app restores a valid, email-verified Supabase session to Home and sends signed-out users through the public auth flow. Do not treat client-side protection as backend authorization. Booking routes are standalone, matching the Figma prototype's hidden bottom navigation in that flow.

See [SHARED_UI.md](SHARED_UI.md) for the component catalog, current placeholders, route list, and shared tokens.

## Authentication and integration boundary

Member 1 owns Flutter registration, sign-in, recovery, logout, and session presentation. The Auth user UUID is the proposed stable customer identifier; email and phone are contact attributes, not keys. Member 2 owns Supabase provider configuration and database security. Member 3 owns profile editing. See `docs/SHARED_CONTRACTS.md` for the full proposal and approval register.

Public app configuration may contain only client-safe Supabase values. Project URL/key delivery, auth provider settings, redirect configuration, and RLS are backend setup work and must be coordinated with Member 2.

## Android networking requirement

On the scaffold base, debug and profile manifests declare `android.permission.INTERNET`, while the main manifest does not. Supabase network access in release builds needs the merged release manifest to include INTERNET. Member 2 should account for this during backend integration and verify it in Phase 14 release preparation.
