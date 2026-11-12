# TIKKA Repository Instructions

## Project scope and sources of truth

TIKKA is the EC5208 Mobile Application Development customer-facing Android app, built with Flutter and Dart and intended to use Supabase Auth and PostgreSQL. The MVP also has a minimal authorized administrative testing workflow outside the customer app; it does not include a separate admin mobile app.

Use these documents as the shared project references:

- README.md: project overview, setup, and document index.
- docs/ARCHITECTURE.md: app structure, feature ownership, navigation, and engineering conventions.
- docs/SHARED_CONTRACTS.md: confirmed observations, proposed cross-feature contracts, and the decision register.
- docs/DEVELOPMENT_PLAN.md: phases, milestones, owners, and acceptance tracking.
- docs/DESIGN_REFERENCE.md: observed Figma screens, flows, and design system.

These documents distinguish confirmed requirements and Figma observations from proposals awaiting team approval. Do not present a proposal as a team decision.

## Team ownership

- Member 1 — PrabodhaRanawaka: Flutter architecture, shared UI, authentication, integration, and final UI consistency.
- Member 2 — ashuraweismann: Supabase backend, service browsing, bookings, administrative testing, and Android release preparation.
- Member 3 — jayasahan: customer profiles, request tracking, ratings and reviews, QA, and final documentation.

Respect these boundaries. Coordinate shared contracts with the owning members before changing their feature or backend behavior.

## Architecture and coding conventions

- Keep the app feature-first. App-wide setup and navigation belong under lib/app; cross-cutting utilities and reusable widgets belong under lib/core; feature code belongs under lib/features/<feature>.
- Keep UI code separate from Supabase data access. Feature UI should call a feature-owned repository or service boundary rather than issuing Supabase queries from widgets.
- Keep shared models and interfaces small. Put feature-specific models in their owning feature; avoid speculative abstractions and unnecessary dependencies.
- Use snake_case for Dart file names, UpperCamelCase for types, and lowerCamelCase for members. Prefer const constructors where practical, null-safe code, disposed controllers, and user-readable validation/network errors.
- Format Dart changes with dart format lib test. Run flutter analyze and flutter test for implementation changes.
- Never place Supabase service-role keys or other privileged credentials in the client. Enforce user access at the backend with appropriate Row Level Security and Storage policies.
- The route, state-management, auth, profile, booking, and status proposals in docs remain pending until the team approves them.

## Scope boundaries

- Do not add payment processing, live GPS worker tracking, real-time worker chat, a worker app, or an admin app unless the team revises MVP scope.
- Administrative testing must use an authorized Dashboard or restricted backend workflow; it is not a customer-app route.
- Do not invent missing Figma screens or backend rules. Record gaps and seek design or team decisions.

## Git and collaboration workflow

- Work on one approved phase or task at a time. Inspect git status and the diff before editing.
- Ask for explicit user authorization before creating branches or worktrees, committing, pushing, creating or updating pull requests, or modifying GitHub issues. An explicit authorization applies only to its stated scope.
- Never commit directly to main. Use a task branch based on the latest main when authorized, and link the pull request to its issue after the user authorizes the remote action.
- Use Conventional Commit subjects: type(scope): imperative lowercase description, without a trailing period.
- Keep commit attribution to the human developer. Do not add AI/bot co-authors or change git author configuration.
- Never stash, reset, discard, or overwrite existing user changes without explicit authorization.

## Decision and documentation hygiene

- Record decisions in docs/SHARED_CONTRACTS.md with proposal, owners, and approval status.
- Record Figma observations separately from implementation and backend recommendations.
- Update documentation when an approved contract changes; do not silently change shared behavior.
- Root-level instructions and the current user request take precedence over legacy assistant-specific notes supplied elsewhere.
