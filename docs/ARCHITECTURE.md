# TIKKA Architecture

**Status:** Phase 01 working proposal. Feature-first organization and member boundaries come from project requirements; routing, state management, and detailed boundaries below require team review.

## Product boundary

TIKKA is a customer-facing Android app built with Flutter and Dart. Supabase Auth and PostgreSQL are the intended identity and backend services. The minimal authorized administrative testing workflow is outside the customer app and is owned by Member 2. There is no admin or worker mobile app in the MVP.

The repository currently contains the Flutter scaffold, theme, lint setup, and empty feature-directory placeholders. The architecture below is a target structure, not a description of implemented features.

## Feature-first structure

~~~text
lib/
  main.dart
  app/
    app.dart
    router/
      app_router.dart
    theme/
      app_theme.dart
  core/
    config/
    constants/
    errors/
    utils/
    widgets/
  features/
    auth/
      data/
      presentation/
    services/
      data/
      presentation/
    bookings/
      data/
      presentation/
    profile/
      data/
      presentation/
    tracking/
      data/
      presentation/
    reviews/
      data/
      presentation/
~~~

Keep each feature self-contained. Add a domain or application layer only when the feature’s logic needs it; the MVP does not require creating boilerplate layers for every screen.

### Responsibility boundaries

| Area | Owner | Boundary and handoff |
|---|---|---|
| App setup, shared architecture, router, shared UI, auth, integration | Member 1 — PrabodhaRanawaka | Owns lib/app and core contracts; publishes route, session, identity, and shared component interfaces. |
| Supabase backend, services, bookings, admin testing, Android release | Member 2 — ashuraweismann | Owns database schema, triggers, RLS and Storage policies, service catalog, booking persistence/status writes, and authorized backend test workflow. |
| Profile, tracking, reviews, QA, final docs | Member 3 — jayasahan | Owns profile display/editing, request history/tracking presentation, customer reviews, and functional QA. |

Feature owners should not depend on another feature’s screen internals. Cross-feature calls use documented route parameters and data contracts. Service and booking interfaces should be agreed between Members 1 and 2; profile and booking-contact snapshots between Members 2 and 3; status lifecycle between all three.

## Dependency direction and data access

**Confirmed project guidance:** keep UI and data access separate, use reusable shared UI, and follow feature-first organization.

**Proposed convention:** screen/presentation code calls feature-owned repositories or services. Those boundaries encapsulate Supabase queries and map backend failures to a small set of user-readable results. The app uses one initialized client supplied to data-access code; widgets do not issue database queries directly. Avoid adding a general service locator, use-case layer, or cross-feature repository unless a demonstrated need justifies it.

Member 2 owns backend-enforced access. Use the signed-in Supabase identity for ownership checks, Row Level Security for tables, and Storage policies for uploaded booking photos. A client-side route guard is a navigation aid, not a security boundary. Never ship a service-role key in the Flutter app.

## Naming and code conventions

- Dart file and folder names: snake_case.
- Types and widgets: UpperCamelCase.
- Methods, variables, and parameters: lowerCamelCase.
- Keep one primary public widget or type per file where that improves discoverability; keep related private helpers close to their feature.
- Prefer const widgets and constructors where practical. Dispose text controllers and subscriptions.
- Keep validation at the form boundary and network/data failures at the repository boundary; display recoverable errors without crashing.
- Use the shared theme and reusable controls rather than feature-specific copies.
- Format with dart format lib test. Run flutter analyze and flutter test for approved implementation changes.
- Do not add dependencies without an approved need. Phase 01 does not add packages.

## Navigation proposal

The Figma Prototype page starts the main flow at Splash, then taps to Login/Register; the Login action leads to Home. Home is the proposed authenticated landing destination. The four visible main destinations are Home, Services, Requests, and Profile. The design does not define returning-session behavior; bypassing sign-in when a valid session is restored is a proposal.

| Proposed route | Screen/purpose | Access |
|---|---|---|
| /splash | Figma entry screen | Public |
| /auth/login | Email/password sign-in | Public |
| /auth/register | Registration; screen not present in Figma | Public |
| /auth/verify-email | Verification guidance; screen not present in Figma | Public |
| /auth/forgot-password | Recovery request; link visible, screen absent | Public |
| /auth/reset-password | Set a recovered password; screen absent | Public |
| /home | Customer home and signed-in landing | Protected |
| /services | Browse and search service categories | Protected |
| /services/:serviceId | Service details | Protected |
| /bookings/new/:serviceId | Booking step 1 | Protected |
| /bookings/confirm | Review and confirm booking step 2 | Protected |
| /requests | Request history and Active/Completed/Cancelled filters | Protected |
| /requests/:requestId | Request tracking | Protected |
| /profile | Profile summary and settings | Protected |
| /profile/edit | Edit profile; screen absent in Figma | Protected |
| /requests/:requestId/review | Review a completed request; screen absent in Figma | Protected |

The path names and guard rules are proposals for review, not implemented routes. Keep the four tab roots in a shared authenticated shell. The Figma booking steps omit that bottom navigation. Proposed startup behavior: restore the Supabase session; send a valid session to /home; otherwise show /splash and then /auth/login. A protected-route attempt without a session redirects to sign-in. Logout clears the session and replaces the protected navigation stack with the public auth entry. Exact logout destination and email-verification continuation need team approval.

A centralized router is required by the Phase 01 issue. go_router is the current package proposal only; no routing package is installed in this phase. Riverpod is a state-management proposal only; no provider package is installed in this phase.

## Authentication and integration boundary

Member 1 owns the Flutter registration, sign-in, recovery, logout, and session presentation. The Auth user UUID is the proposed stable customer identifier; email and phone are contact attributes, not keys. Member 2 owns Supabase provider configuration and database security. Member 3 owns profile editing. See docs/SHARED_CONTRACTS.md for the full proposal and approval register.

The public app configuration must contain only client-safe Supabase values. Project URL/key delivery, auth provider settings, redirect configuration, and RLS are backend setup work and must be coordinated with Member 2.

## Android networking requirement

On the scaffold base, debug and profile manifests declare android.permission.INTERNET, while the main manifest does not. Supabase network access in release builds needs the merged release manifest to include INTERNET. Member 2 should account for this during backend integration and verify it in Phase 14 release preparation. This is a recorded implementation requirement; no manifest was changed in Phase 01.
