# TIKKA Phase 12 Test Execution Report

## Summary

The final automated Flutter run executed **56 tests: 56 passed, 0 failed**.
Static analysis completed with **0 issues**. No manual Android tests were
executed because no emulator/device or live Supabase configuration was
available.

| Result | Count |
|---|---:|
| PASS | 29 documented cases were directly exercised by the automated suite |
| FAIL | 0 |
| BLOCKED | 11 |
| NOT RUN | 5 |

The case counts above are a functional-case classification, not a one-to-one
assertion count; one automated test can cover several cases.

## Environment

- Windows host, Flutter project root.
- Dependencies restored with `flutter pub get`.
- Flutter/Dart SDK as configured by the repository.
- Synthetic in-memory repositories and fakes.
- No `config/supabase.local.json`; no credentials or production data used.
- No Android emulator or physical device connected.

## Commands and results

| Command | Result |
|---|---|
| `flutter pub get` | PASS — dependencies resolved; package update notices only. |
| `flutter analyze` | PASS — `No issues found!`. |
| `flutter test` | PASS — `All tests passed!` (56 tests). |
| `flutter test integration_test` | BLOCKED — no `integration_test` device target was connected; Flutter reported no supported devices. |

The repository's integration-style workflow is under
`test/app/customer_workflow_integration_test.dart` and is included in
`flutter test`; it does not require a device.

## Coverage executed

Automated coverage includes auth validation/error handling, service browsing
and search, booking validation/submission/navigation, profile display/editing,
history/tracking, status lifecycle rules, review validation/submission,
protected-route redirection, session guards, and the complete fake-backed
customer workflow.

Live Supabase Auth, RLS, network interruption, Android restart/session restore,
and SQL administrative execution remain blocked and are listed in
[known-limitations.md](known-limitations.md).
