# TIKKA Development Plan

**Planning state:** Phase owners and milestone targets reflect the project brief. Dates are targets. Phase 01–03 are merged; Phase 04 authentication is in progress on `feature/customer-authentication` under the approved auth proposals. Live Supabase Auth configuration remains unverified.

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
| 01 | #2 | Architecture and Shared Contracts | Member 1 — PrabodhaRanawaka | M1 | Feature boundaries, shared contracts, routes, conventions, and agent guidance. Phase 01 PR merged; proposals remain reviewable. |
| 02 | #3 | Supabase Backend Setup | Member 2 — ashuraweismann | M1 | Phase 02 schema/RLS/storage migrations, seed data, and specification merged in PR #18; verify deployment to the live Supabase project and auth provider configuration. |
| 03 | #4 | Shared UI Components and Navigation | Member 1 — PrabodhaRanawaka | M1 | Implemented and merged in PR #19; no Android device/emulator was available for on-device preview. |
| 04 | #5 | Customer Authentication | Member 1 — PrabodhaRanawaka | M2 | Implementation and local verification complete on `feature/customer-authentication`; analyzer and all 13 widget/repository tests pass. Live Auth settings and design alignment remain pending. |
| 05 | #6 | Service Browsing and Details | Member 2 — ashuraweismann | M2 | Implement catalog browsing and service details. |
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

## Phase 02 delivery status

PR #18 is merged to `main` as commit `137cbc1`. The repository includes SQL migrations, an all-in-one setup script, seed data, `.env.example`, and `docs/BACKEND_SPECIFICATION.md`. This confirms the backend artifacts are in source control; it does not prove that a Supabase project was provisioned or that the migrations and Auth settings were applied there.

## Phase 01 acceptance checklist

| Issue #2 criterion | State |
|---|---|
| Review the Flutter structure and dependencies | Completed during Phase 01 review. |
| Document feature-first structure and naming standards | Documented in `docs/ARCHITECTURE.md`; backend contracts were finalized in Phase 02, while auth/navigation proposals remain subject to team agreement. |
| Document route, auth, identity, profile, booking, and status contracts | Recorded in `docs/SHARED_CONTRACTS.md` and `docs/DESIGN_REFERENCE.md`; Phase 02 backend contracts are confirmed, and auth proposals are approved for Member 1's implementation while live project settings remain pending. |
| Document responsibilities and integration points | Completed in architecture and phase assignment tables. |
| Add root `AGENTS.md` and project documentation | Merged to `main` with Phase 01. |
| Run Flutter analysis and tests | Passed in Phase 01. |
| Link and merge the Phase 01 PR | Merged by the user; issue #2 closed by the user. |

## Phase 03 progress and acceptance checklist

Phase 03 implementation and automated verification are complete and merged in PR #19. See [SHARED_UI.md](SHARED_UI.md) for the route catalog, component usage, and current placeholder boundary.

| Issue #4 criterion | State |
|---|---|
| Review Figma screens and shared design tokens | Completed from the updated Figma reference; design gaps and spacing discrepancy are documented. |
| Apply shared colors, typography, and theme | Implemented in `AppTheme`; bundled Inter font and Figma loading SVG are registered; analysis passes. |
| Add reusable buttons, input, app bar, and shared states | Implemented in `lib/core/widgets/`; analyzer passes and widget coverage checks field error/loading states. |
| Add shared page layout and responsive customer shell | Implemented with a constrained content width and four-tab shell; widget tests pass. No Android device/emulator was detected for device preview. |
| Centralize destinations and route names; add feature placeholders | Implemented with Flutter Navigator; widget tests verify auth and feature route placeholders. Route guards and feature screens remain Phase 04/feature-owner work. |
| Replace the starter counter and add tests | Counter removed; widget tests pass for shell tabs, route placeholders, text-field error, and loading state. |
| Update usage documentation | Added `docs/SHARED_UI.md` and updated README/architecture; documentation consistency review completed. |
| `flutter analyze` and `flutter test` pass | Passed: no analyzer issues; all 5 widget tests passed. |

## Follow-up requirements and blockers

- Registration, verification, and password reset screens are absent from Figma; Phase 04 implements them as drafts from the approved proposals, pending design alignment. Profile editing and customer review designs remain open for their owners.
- Phase 02 schema, triggers, RLS, storage policies, seed data, and backend specification are merged via PR #18. Confirm the migrations are applied to the actual Supabase project and verify Auth provider settings and the authorized admin/testing workflow.
- Phase 04 added INTERNET permission to the main manifest for Supabase networking. Member 2 should verify it in the final merged release manifest.
- Agree proposed cross-feature contracts before consuming them as business rules. Phase numbers provide a recommended sequence, while independent work may proceed after relevant contracts are accepted.
