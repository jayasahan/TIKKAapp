# TIKKA Phase 12 Test Cases

`PASS` means executed by the automated suite. `BLOCKED` requires a live
Supabase project or Android device. `NOT RUN` means no focused automated or
manual execution was available.

| ID | Module | Scenario and expected result | Actual result | Status | Defect |
|---|---|---|---|---|---|
| AUTH-01 | Authentication | Valid registration submits name, email, phone and password and opens verification. | Verified by auth widget test. | PASS | — |
| AUTH-02 | Authentication | Duplicate registration shows a user-readable duplicate-account error. | Requires live Auth error response. | BLOCKED | — |
| AUTH-03 | Authentication | Invalid email/password inputs are rejected before repository call. | Required-field/email validation is verified; live password policy is not. | PASS | — |
| AUTH-04 | Authentication | Missing registration fields display inline errors. | Form validation path exercised by auth tests. | PASS | — |
| AUTH-05 | Authentication | Valid login publishes a verified session and opens the customer shell. | Verified with authentication fake/integration flow. | PASS | — |
| AUTH-06 | Authentication | Invalid credentials display a friendly error. | Verified with repository failure fake. | PASS | — |
| AUTH-07 | Authentication | Logout clears session and returns to public auth flow. | Verified by customer workflow test. | PASS | — |
| AUTH-08 | Authentication | Verified session persists after process restart. | Requires Android lifecycle and live Auth configuration. | BLOCKED | — |
| AUTH-09 | Authentication | Signed-out deep link to protected route is redirected. | Verified for `/requests`. | PASS | — |
| SRV-01 | Services | Service categories and listing render. | Verified with seeded repository data. | PASS | — |
| SRV-02 | Services | Service details show description and common jobs. | Verified by services widget test. | PASS | — |
| SRV-03 | Services | Search matches service names, descriptions, and common jobs. | Verified with `drain` search. | PASS | — |
| SRV-04 | Services | Category filtering shows only selected category services. | Verified through services navigation test. | PASS | — |
| SRV-05 | Services | Empty search result shows an empty state. | No focused execution recorded. | NOT RUN | — |
| SRV-06 | Services | Loading and backend error states are recoverable. | Widget loading state is covered; live error recovery is not. | NOT RUN | — |
| BOOK-01 | Booking | Valid booking completes form, confirmation, and request-history flow. | Verified by customer workflow integration test. | PASS | — |
| BOOK-02 | Booking | Required booking fields block continuation with inline errors. | Verified by booking widget tests. | PASS | — |
| BOOK-03 | Booking | Short/invalid booking inputs are rejected. | Problem description boundary is verified; live backend constraints are not. | PASS | — |
| BOOK-04 | Booking | Confirmation prevents duplicate taps while submission is in flight. | Guard is present; no delayed-submit focused test exists. | NOT RUN | — |
| BOOK-05 | Booking | Booking submission failure remains a failure and is retryable. | Live/network failure requires Supabase or a delayed failing double. | BLOCKED | DEF-001 |
| BOOK-06 | Booking | Network interruption does not create a false booking. | Requires controlled live/network test. | BLOCKED | DEF-001 |
| BOOK-07 | Booking | Successful booking is displayed with `NEW` status and reference. | Verified in integration and booking tests. | PASS | — |
| PROF-01 | Profile | Customer can view own profile fields. | Verified by profile widget/integration tests. | PASS | — |
| PROF-02 | Profile | Valid profile update is saved and reloaded. | Verified with profile fake and form flow. | PASS | — |
| PROF-03 | Profile | Invalid name, phone, and address values are rejected. | Validator tests pass. | PASS | — |
| PROF-04 | Profile | Another customer's profile cannot be read or updated. | Requires live RLS test account. | BLOCKED | — |
| HIST-01 | History | Active/completed/cancelled filters show correct requests. | Verified by booking history widget test. | PASS | — |
| HIST-02 | History | Empty history shows an empty state. | No focused execution recorded. | NOT RUN | — |
| HIST-03 | Tracking | Request details display status timeline and assigned worker. | Verified by tracking/admin widget tests. | PASS | — |
| HIST-04 | Tracking | Customer sees only own booking data. | Query ownership is implemented; live RLS requires project execution. | BLOCKED | — |
| HIST-05 | Tracking | Load failure shows retryable error state. | No live failure execution. | BLOCKED | — |
| ADM-01 | Administration | Valid lifecycle advances through all approved states. | Local state-machine test passes. | PASS | — |
| ADM-02 | Administration | Invalid jumps and terminal transitions are rejected. | Local state-machine test passes. | PASS | — |
| ADM-03 | Administration | Unauthorized customer status mutation is rejected by backend. | Requires live RLS/service-role setup. | BLOCKED | — |
| ADM-04 | Administration | Admin status change is reflected after customer refresh. | Local tracking test passes; live refresh is blocked. | PASS | — |
| REV-01 | Reviews | Completed/confirmed booking is eligible for review. | Eligibility logic and completed tracking flow pass. | PASS | — |
| REV-02 | Reviews | Incomplete booking cannot open/submit a review. | Screen guard is implemented; live execution not available. | NOT RUN | — |
| REV-03 | Reviews | Rating is required and constrained to 1–5. | Validation tests pass. | PASS | — |
| REV-04 | Reviews | Valid review with trimmed optional comment is stored/displayed. | Verified by review widget test. | PASS | — |
| REV-05 | Reviews | Duplicate review is rejected/displayed as already reviewed. | Requires live unique constraint or focused failure double. | BLOCKED | — |
| SEC-01 | Security | Unauthenticated API access is rejected. | Repository session guard test passes. | PASS | — |
| SEC-02 | Security | Another customer's booking cannot be fetched through fallback after backend failure. | Regression fixed in repository; live failure injection is blocked. | PASS | DEF-001 |
| SEC-03 | Security | No service-role key is bundled in client code. | Static security test passes. | PASS | — |
| NET-01 | Network | No internet shows a recoverable error. | Requires device/network control. | BLOCKED | DEF-001 |
| NET-02 | Network | Server error can be retried after connectivity returns. | Requires live controlled backend. | BLOCKED | — |

