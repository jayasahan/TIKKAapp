# TIKKA Phase 12 Known Limitations

- No Android emulator or physical device was connected; manual UI, restart,
  deep-link, keyboard, and network interruption testing is pending.
- No live Supabase URL/key or test accounts were available. Auth email
  confirmation, duplicate registration, RLS ownership, server errors, review
  uniqueness, storage policies, and SQL administrative authorization were not
  executed against a live project.
- Automated integration coverage uses controlled fakes. It verifies customer
  workflow orchestration but does not prove backend persistence.
- The repository has no separate `integration_test/` device target. The
  integration-style customer workflow is under `test/app/` and runs with
  `flutter test`.
- Service repositories intentionally provide seed data when no Supabase client
  is configured. This is suitable for local UI tests, not evidence of live
  catalog availability.
- The external administrative workflow has no mobile admin UI by design; use
  the documented Supabase Studio/SQL procedure and a separately authorized
  service-role environment for live verification.
- No unresolved critical or high-priority defect was confirmed after the
  booking failure-handling fix. DEF-001 still needs live fault-injection
  confirmation when the backend environment is available.
