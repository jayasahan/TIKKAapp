# TIKKA Phase 12 Functional Test Plan

## Scope

This plan covers the customer Flutter application and its Supabase integration
boundary: authentication, service discovery, booking creation, profile
management, request history/tracking, the external administrative status
workflow, reviews, access control, and recoverable application states.

The administrative workflow is intentionally outside the mobile app. It is
tested through the local state-machine test double and documented Supabase
SQL procedures, while live authorization requires a configured project.

## Objectives

- Verify the approved customer workflows end to end.
- Verify validation, loading, empty, and error behavior.
- Verify ownership boundaries in client queries and documented RLS policies.
- Detect integration defects without replacing the feature-first architecture.
- Retest fixes and record evidence accurately.

## Approach and test types

| Type | Approach |
|---|---|
| Unit | Domain validation, serialization, lifecycle rules, and repository contracts with controlled doubles. |
| Widget | Forms, screens, loading/error/empty states, navigation, and duplicate-submit guards. |
| Integration-style | `test/app/customer_workflow_integration_test.dart` exercises registration-independent customer booking, tracking, review, profile, and logout flow with fakes. |
| Backend/security | Local administrative state-machine tests plus inspection of migrations/RLS and SQL workflow. Live Supabase verification remains environment-dependent. |
| Manual | Android device/emulator execution against a configured Supabase project. Not executed in this environment. |

## Modules under test

Auth, services, bookings, profile, tracking/history, reviews, shared routing
and shell navigation, Supabase repositories, and the external administrative
workflow.

## Environment and prerequisites

- Flutter/Dart project dependencies restored with `flutter pub get`.
- Windows host; no Android emulator or physical device connected.
- No `config/supabase.local.json`, live Supabase credentials, or test account
  was available.
- Automated tests use in-memory repositories and controlled fakes; they do not
  write production data.

## Test data

Use synthetic customer IDs, service requests, and review content only. The
backend documentation defines `NEW -> REVIEWING -> SCHEDULED -> ASSIGNED ->
IN_PROGRESS -> COMPLETED -> CONFIRMED`, with `CANCELLED` and `REJECTED` as
terminal states. The test seed data and admin SQL are in `supabase/`.

## Entry and exit criteria

**Entry:** feature modules and their repository contracts are present, test
dependencies resolve, and the working tree is on the Phase 12 branch.

**Exit:** all executable automated tests pass, analysis is clean, resolved
defects have regression coverage, and unavailable live/device checks are
explicitly documented as blocked or not run.

## Severity and priority

- **Critical / P0:** application-wide failure, severe security issue, or data
  corruption.
- **High / P1:** broken critical customer workflow or ownership bypass.
- **Medium / P2:** significant impairment with a workaround.
- **Low / P3:** minor behavior or usability issue.

## Limitations

Live Auth, RLS, network interruption, server failures, Android lifecycle/session
restore, and the Supabase administrative SQL workflow require project
credentials and a device/emulator. They are not represented as passing tests.
