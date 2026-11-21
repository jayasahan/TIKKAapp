# TIKKA Development Plan

**Planning state:** Phase owners and milestone targets reflect the project brief. Dates are targets. Phases 01–09 are merged; Phase 10 (Admin and Backend Testing) is completed on `feature/admin-backend-testing`.

## Milestones

| Milestone | Target date | Phases | Focus |
|---|---|---|---|
| M1 — Foundation & Backend Setup | November 18, 2026 | 01–03 | Shared contracts, Supabase setup, shared UI and navigation |
| M2 — Core Application Features | November 29, 2026 | 04–08 | Authentication, services, booking, profile, tracking |
| M3 — Feature Completion & Integration | December 7, 2026 | 09–12 | Reviews, admin/backend testing, app integration, functional testing |
| M4 — Final Testing & Submission | December 13, 2026 | 13–15 | Usability/UI consistency, Android release, final documentation |
| Final submission | December 15, 2026 | — | Module submission deadline |

## Phase assignments

| Phase | GitHub issue | Work item | Owner | Milestone | Handoff / scope |
|---|---:|---|---|---|---|
| 01 | #2 | Architecture and Shared Contracts | Member 1 — PrabodhaRanawaka | M1 | Feature boundaries, shared contracts, routes, conventions, and agent guidance. Phase 01 PR merged. |
| 02 | #3 | Supabase Backend Setup | Member 2 — ashuraweismann | M1 | Phase 02 schema/RLS/storage migrations, seed data, and specification merged in PR #18. |
| 03 | #4 | Shared UI Components and Navigation | Member 1 — PrabodhaRanawaka | M1 | Implemented and merged in PR #19. |
| 04 | #5 | Customer Authentication | Member 1 — PrabodhaRanawaka | M2 | Implemented and merged in PR #20. |
| 05 | #6 | Service Browsing and Details | Member 2 — ashuraweismann | M2 | Implemented and merged in PR #21; catalog browsing, category filtering, search, and service details matching Figma. |
| 06 | #7 | Customer Booking Flow | Member 2 — ashuraweismann | M2 | Implemented and merged in PR #22; approved booking fields, two-step confirmation, and optional photo upload matching Figma Screens 06 & 07. |
| 07 | #8 | Customer Profile Management | Member 3 — jayasahan | M2 | Implemented and merged; profile view/edit contract. |
| 08 | #9 | Booking History and Request Tracking | Member 3 — jayasahan | M2 | Implemented and merged; request filters, status display, and tracking timeline. |
| 09 | #10 | Ratings and Reviews | Member 3 — jayasahan | M3 | Implemented and merged; 1-5 star ratings and reviews for completed requests. |
| 10 | #11 | Admin and Backend Testing | Member 2 — ashuraweismann | M3 | Implemented on `feature/admin-backend-testing`; authorized admin procedures, status transition engine, test booking catalog, security verification, and documentation. |
| 11 | #12 | Application Integration | Member 1 — PrabodhaRanawaka | M3 | Connect owned feature routes/contracts and resolve integration issues without taking over other features. |
| 12 | #13 | Functional Testing | Member 3 — jayasahan | M3 | Run agreed end-to-end functional QA across the customer workflow. |
| 13 | #14 | UI Consistency and Usability | Member 1 — PrabodhaRanawaka | M4 | Reconcile implemented screens against accepted Figma and shared components. |
| 14 | #15 | Android Release Build | Member 2 — ashuraweismann | M4 | Prepare and verify release configuration, permissions, signing, and Android build output. |
| 15 | #16 | Final Documentation and Submission | Member 3 — jayasahan | M4 | Complete project report, evidence, and submission packaging. |

## Phase 05 acceptance checklist

| Issue #6 criterion | State |
|---|---|
| Domain entities for categories and services | Implemented in `lib/features/services/domain/service_category.dart` and `service.dart`. |
| Repository contract and Supabase implementation | Implemented in `ServicesRepository` and `SupabaseServicesRepository`, with offline seed data fallback. |
| Services screen with search and 8 categories | Implemented in `ServicesScreen` matching Figma Screen 04 (Cleaning, Electrical, Gardening, Handyman, Moving, Painting, Plumbing, Repairs). |
| Service details screen with common jobs | Implemented in `ServiceDetailsScreen` matching Figma Screen 05 (Plumbing reference, common jobs, rate note, Request Service CTA). |
| Home screen integration with featured services | Implemented in `HomeScreen` with greeting, hero request CTA, 2x2 featured categories, and recent request card. |
| Centralized route wiring in `AppRouter` | Wired `/home` and `/services` in navigation shell; `/services/:serviceId` with back navigation. |
| Unit and widget test coverage | Passed: all 23 tests pass across authentication, services repository, services presentation flow, and app shell. |
| `flutter analyze` passes | Passed with 0 issues. |

## Phase 06 acceptance checklist

| Issue #7 criterion | State |
|---|---|
| Domain entity and draft validation model | Implemented in `lib/features/bookings/domain/booking.dart` and `booking_draft.dart`. |
| Bookings repository contract and Supabase implementation | Implemented in `BookingsRepository` and `SupabaseBookingsRepository`, writing to `public.bookings` with status `'NEW'`, generating references, and providing offline fallback. |
| Step 1 booking form screen matching Figma Screen 06 | Implemented in `BookingFormScreen` (`/bookings/new/:serviceId`) with yellow service highlight, problem description, address input, date picker, time slot selector, contact fields, optional photo attachment, and Continue CTA. |
| Step 2 booking review and confirmation screen matching Figma Screen 07 | Implemented in `BookingConfirmationScreen` (`/bookings/confirm`) with summary card (job, address, date, time, customer, photo), yellow "✓ Request ready to submit" notice, Edit button (returns to Step 1), and Confirm Request CTA. |
| Duplicate submission prevention | Implemented in `BookingConfirmationScreen` with in-flight loading state and disabled redundant taps. |
| Route integration and dependency wiring | Centralized routes wired in `AppRouter`, `MyApp`, and initialized in `main.dart`. |
| Unit and widget test coverage | Passed: all 31 tests pass across auth, services, bookings repository, booking presentation flow, and app shell. |
| `flutter analyze` passes | Passed with 0 issues. |

## Phase 10 acceptance checklist

| Issue #11 criterion | State |
|---|---|
| Minimum administrative operations defined | Defined in `docs/ADMIN_TESTING_WORKFLOW.md`: booking status progression, worker assignment, scheduling, rejection, and service catalog management. |
| Authorized administrative methods established | Implemented in `supabase/admin_workflow.sql` with state machine validator, `admin_update_booking_status`, `admin_list_bookings`, `admin_toggle_service_active`, and `admin_upsert_service`. |
| Customer administrative restriction enforced | Verified at PostgreSQL engine boundary: RLS denies status mutations to `ASSIGNED`, `IN_PROGRESS`, `COMPLETED` for customer client roles. |
| Zero privileged secrets in client application | Verified: Flutter codebase and configuration contain only public client credentials (`SUPABASE_URL`, `SUPABASE_ANON_KEY`); `service_role` and DB passwords are not present. |
| Representative test bookings across all statuses | Populated in `supabase/seed_test_bookings.sql` covering `NEW`, `REVIEWING`, `SCHEDULED`, `ASSIGNED`, `IN_PROGRESS`, `COMPLETED`, `CONFIRMED`, `CANCELLED`, `REJECTED`. |
| Status updates reflected in customer tracking | Verified: `BookingTrackingScreen` displays real-time status transitions, timeline node completion, and technician assignment. |
| Completed bookings support review workflow | Verified: `COMPLETED` and `CONFIRMED` bookings surface the "Review service" action and allow 1-5 star ratings. |
| Database constraints and RLS policies tested | Verified via `test/features/admin/backend_security_and_lifecycle_test.dart` (6 automated test suites passing). |
| Administrative testing and demonstration documentation | Comprehensive documentation deliverable in `docs/ADMIN_TESTING_WORKFLOW.md`. |
| `flutter analyze` and `flutter test` pass | Historical Phase 10 baseline: 52 / 52 tests passed with 0 analyzer issues. Phase 12 final run: 56 / 56 tests passed with 0 analyzer issues; see `docs/qa/test-execution-report.md`. |

## Follow-up requirements and blockers

- Application Integration (Phase 11 / Issue #12) is owned by Member 1 (`PrabodhaRanawaka`), connecting feature routes/contracts and verifying holistic client flows.
- Functional Testing (Phase 12 / Issue #13) is owned by Member 3 (`jayasahan`), running agreed end-to-end customer QA.
