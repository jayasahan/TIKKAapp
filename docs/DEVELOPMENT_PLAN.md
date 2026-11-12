# TIKKA Development Plan

**Planning state:** This phase map and owner list reflect the current project brief. Dates are targets; phase dependencies permit parallel work after shared contracts are agreed. The Phase 01 contract proposals remain pending until the team records approval in docs/SHARED_CONTRACTS.md.

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
| 01 | #2 | Architecture and Shared Contracts | Member 1 — PrabodhaRanawaka | M1 | Document feature boundaries, shared contracts, routes, conventions, and agent guidance. Team agreement remains required. |
| 02 | #3 | Supabase Backend Setup | Member 2 — ashuraweismann | M1 | Configure the project, schema, auth provider, policies, and storage based on approved contracts. |
| 03 | #4 | Shared UI Components and Navigation | Member 1 — PrabodhaRanawaka | M1 | Build shared UI and route shell from approved Figma and architecture decisions. |
| 04 | #5 | Customer Authentication | Member 1 — PrabodhaRanawaka | M2 | Implement approved login, registration, recovery, verification, and session behavior. |
| 05 | #6 | Service Browsing and Details | Member 2 — ashuraweismann | M2 | Implement catalog browsing and service details. |
| 06 | #7 | Customer Booking Flow | Member 2 — ashuraweismann | M2 | Implement approved booking fields, two-step confirmation, and optional photo upload. |
| 07 | #8 | Customer Profile Management | Member 3 — jayasahan | M2 | Implement approved profile view/edit contract. |
| 08 | #9 | Booking History and Request Tracking | Member 3 — jayasahan | M2 | Implement request filters, status display, and tracking timeline. |
| 09 | #10 | Ratings and Reviews | Member 3 — jayasahan | M3 | Implement after eligibility, rating/comment fields, and design are agreed. |
| 10 | #11 | Admin and Backend Testing | Member 2 — ashuraweismann | M3 | Verify backend and use the approved authorized administrative testing workflow; no admin mobile app. |
| 11 | #12 | Application Integration | Member 1 — PrabodhaRanawaka | M3 | Connect owned feature routes/contracts and resolve integration issues without taking over other features. |
| 12 | #13 | Functional Testing | Member 3 — jayasahan | M3 | Run agreed end-to-end functional QA across the customer workflow. |
| 13 | #14 | UI Consistency and Usability | Member 1 — PrabodhaRanawaka | M4 | Reconcile implemented screens against the accepted Figma design and shared components. |
| 14 | #15 | Android Release Build | Member 2 — ashuraweismann | M4 | Prepare and verify release configuration, permissions, signing, and Android build output. |
| 15 | #16 | Final Documentation and Submission | Member 3 — jayasahan | M4 | Complete project report, evidence, and submission packaging. |

## Phase 01 work plan

1. Review scaffold structure, dependencies, Figma, and current Git conventions. This read-only review is complete for the current Phase 01 worktree.
2. Finalize and record feature boundaries, naming conventions, data-access separation, and integration points with all owners.
3. Agree route names, four tab destinations, public/protected boundaries, session restoration, and the post-login landing screen.
4. Agree auth fields/provider/verification/recovery and the Supabase UUID identity contract.
5. Agree the logical profile contract and creation owner with Members 2 and 3.
6. Agree the booking request payload, contact snapshots, photo path handoff, status lifecycle, transitions, cancellation rule, and review eligibility with Members 2 and 3.
7. Add root AGENTS.md and update README plus architecture, contracts, design-reference, and development-plan docs.
8. Run flutter analyze and flutter test. Review Phase 01 issue #2 acceptance criteria and prepare a linked PR only after the user approves the remote action.

## Phase 01 acceptance checklist

| Issue #2 criterion | Current Phase 01 worktree state |
|---|---|
| Review existing Flutter structure and dependencies | Reviewed against scaffold; no package was added in this phase. |
| Finalize feature-first structure | Target structure documented; detailed team approval still pending. |
| Establish naming and coding standards | Draft conventions documented; team approval pending. |
| Define routes and navigation structure | Route proposal documents Figma destinations and missing screens; team approval pending. |
| Agree auth, identity, profile, booking, and status contracts | Proposals and responsible reviewers documented; agreement not claimed. |
| Document team responsibilities and integration points | Included in architecture and phase assignment table. |
| Root AGENTS.md available | Created on feature/app-foundation; not yet merged to main. |
| Update architecture/development documentation | Drafts created on feature/app-foundation. |
| Flutter analysis and tests pass | Pass: `flutter analyze` and `flutter test` both exited 0 on Flutter 3.47.6 / Dart 3.13.5. |
| PR linked to issue #2 | Not created; user explicitly deferred PR creation. |

## Explicit follow-up requirements

- Resolve missing Figma designs for registration, verification, password reset, profile editing, and customer reviews.
- Member 2 must confirm the Supabase project, auth provider settings, schema, triggers, Row Level Security, Storage bucket, and authorized admin/testing mechanism.
- The scaffold main manifest lacks INTERNET permission although debug and profile manifests include it. Member 2 should resolve and verify the merged release manifest during backend/release work; do not treat debug-only permission as release readiness.
- Agree all proposed contracts before implementation phases consume them. Phase numbers provide recommended order, while independent feature work may proceed after relevant contracts are accepted.
