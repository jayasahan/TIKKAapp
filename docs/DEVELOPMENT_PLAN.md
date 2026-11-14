# TIKKA Development Plan

**Planning state:** Phase owners and milestone targets reflect the project brief. Dates are targets. Phases 01–04 are merged; Phase 05 (Service Browsing and Details) implementation is complete on `feature/service-browsing`.

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
| 05 | #6 | Service Browsing and Details | Member 2 — ashuraweismann | M2 | Implemented on `feature/service-browsing`; catalog browsing, category filtering, search, and service details matching Figma. |
| 06 | #7 | Customer Booking Flow | Member 2 — ashuraweismann | M2 | Implement approved booking fields, two-step confirmation, and optional photo upload. |
| 07 | #8 | Customer Profile Management | Member 3 — jayasahan | M2 | Implement approved profile view/edit contract. |
| 08 | #9 | Booking History and Request Tracking | Member 3 — jayasahan | M2 | Implement request filters, status display, and tracking timeline. |
| 09 | #10 | Ratings and Reviews | Member 3 — jayasahan | M3 | Implement after eligibility, rating/comment fields, and design are agreed. |
| 10 | #11 | Admin and Backend Testing | Member 2 — ashuraweismann | M3 | Verify backend and use the approved authorized administrative testing workflow; no admin mobile app. |
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

## Follow-up requirements and blockers

- Customer Booking Flow (Phase 06 / Issue #7) is the next phase owned by Member 2, connecting "Request Service" on `ServiceDetailsScreen` (`/bookings/new/:serviceId`) to the 2-step booking submission flow.
