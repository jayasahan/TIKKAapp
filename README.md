# TIKKA

TIKKA is a customer-facing Android home-services application for the EC5208 Mobile Application Development module at the University of Ruhuna. It is built with Flutter and Dart, with Supabase Auth and PostgreSQL as the intended backend.

The MVP covers customer sign-in, browsing household services, submitting and tracking requests, managing a customer profile, and rating completed work. A minimal authorized administrative testing workflow is outside the customer app; there is no separate admin mobile app.

## Team

| Member | Ownership |
|---|---|
| PrabodhaRanawaka | Flutter architecture, shared UI, authentication, integration, final UI consistency |
| ashuraweismann | Supabase backend, services, bookings, administrative testing, Android release preparation |
| jayasahan | Profiles, tracking, ratings and reviews, QA, final documentation |

## Repository and implementation status

Phase 01 architecture, Phase 02 backend setup artifacts (PR #18), and Phase 03 shared UI/navigation (PR #19) are merged to `main`. Phase 04 customer authentication is in progress on `feature/customer-authentication`; see [Authentication](docs/AUTHENTICATION.md) for local configuration and implemented flows and [Shared UI and Navigation](docs/SHARED_UI.md) for the component and route catalog. Service, booking, profile, tracking, and review screens remain with their assigned feature owners.

The repository now contains Phase 02 migrations, seed data, and a backend specification. Confirm with Member 2 whether these have been applied to the actual Supabase project; repository files alone do not establish live project configuration. Remaining proposals in shared contracts still require the listed approvals. See [Development Plan](docs/DEVELOPMENT_PLAN.md) for owners, milestones, and phase progress.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Shared contracts and decision register](docs/SHARED_CONTRACTS.md)
- [Backend specification](docs/BACKEND_SPECIFICATION.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Shared UI and navigation](docs/SHARED_UI.md)
- [Development phases and milestones](docs/DEVELOPMENT_PLAN.md)
- [Figma design reference](docs/DESIGN_REFERENCE.md)
- [Repository instructions](AGENTS.md)

## Technology and identifiers

- Flutter and Dart for Android.
- Supabase Auth and PostgreSQL are the target backend.
- Android application ID and namespace: `com.tikka.app`.
- Current Figma reference: [TIKKA Mobile App — Flutter MVP](https://www.figma.com/design/ZkL4pUNzpc3cJ1groSn2KT/TIKKA-Mobile-App-%E2%80%94-Flutter-MVP--Copy-?node-id=0-1&m=dev&t=mo3oijoMwRdsSb6r-1).

Do not assume a Supabase project is configured. The app must use only client-safe credentials; service-role credentials must never be bundled in the Flutter app.

## Getting started

Requirements documented by the scaffold include Flutter 3.47.6 stable, Dart 3.13.5, Android SDK, and Git.

~~~sh
flutter pub get
flutter devices
flutter run -d <device-id>
~~~

Before submitting approved Dart implementation work, format and verify it:

~~~sh
dart format lib test
flutter analyze
flutter test
~~~

## Development workflow

Work on an approved task branch based on the latest main, keep changes focused, and link a reviewed pull request to its GitHub issue. Do not create branches, worktrees, commits, pull requests, or modify remote issues without explicit user authorization. See AGENTS.md for the full collaboration rules.
