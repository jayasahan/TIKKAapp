# TIKKA Phase 12 Defect Log

## DEF-001 — Live booking failures were converted to local success

| Field | Detail |
|---|---|
| Module | Booking repository and integration boundary |
| Severity / priority | High / P1 |
| Description | When a configured Supabase booking request failed, the repository silently created or modified an in-memory booking. This could show a false confirmation during a network/server failure and could make fallback reads or cancellation operate on records outside the authenticated customer. |
| Reproduction | Configure a repository with a Supabase client, make the client request fail, then create, list, fetch, cancel, or administratively update a booking. Observe that the previous implementation continued with local data instead of surfacing a failure. |
| Expected | Surface a user-readable `BookingsFailure`; never report a booking as persisted when the backend request failed, and preserve ownership checks. |
| Root cause | Broad `catch (Object)` blocks treated live-client errors as an offline simulation path. |
| Resolution | Live-client paths now throw explicit booking failures. Local simulation remains available only when no client is configured; local cancellation also enforces cancellable statuses. |
| Retest | PASS — all 56 automated tests pass; repository regression paths and security assertions remain green. Live fault injection remains environment-blocked. |

No other critical or high-priority defect was confirmed during this execution.
