# TIKKA Shared Contracts and Decision Register

**Review state:** Working draft for Phase 01. Confirmed requirements and direct Figma observations are separated from proposals. Nothing marked Proposed has team approval yet.

## Status key

- **Confirmed** — stated in the current project brief or already established project guidance.
- **Observed** — directly visible in the current Figma file; it describes the design, not a backend rule.
- **Proposed** — an initial technical recommendation awaiting team approval.
- **Pending** — a requirement or implementation detail still needs an owner decision or evidence.

## Confirmed project constraints

- Flutter/Dart Android customer application; Supabase Auth and PostgreSQL are the intended backend.
- Feature-first organization.
- Member 1 owns architecture, shared UI, auth, integration, and final UI consistency.
- Member 2 owns backend setup, services, bookings, admin testing, and release preparation.
- Member 3 owns profile, tracking, reviews, QA, and final documentation.
- The current Figma prototype visually shows Splash → Login/Register → Home and a four-destination navigation shell. See docs/DESIGN_REFERENCE.md.
- No service-role key or privileged credential belongs in the client. Backend security and database rules are Member 2’s responsibility.
- No admin mobile app is in scope. The project requires only a minimal authorized administrative testing workflow outside the customer app; the mechanism remains pending.

## Authentication contract proposal

**Proposed, pending team approval.**

- Provider: Supabase Auth with email and password.
- Registration inputs: full name, email, phone number, password, and confirm password. Confirm password is client-side validation only and is never sent to Supabase.
- Email verification is enabled. Until the email is verified and a usable session is established, the app shows a verification-pending state. The screen and exact SDK behavior need confirmation.
- Password recovery is supported. The Figma screen includes a Forgot password link but no recovery form or completion screen.
- Google sign-in is deferred unless the team confirms it is required. The Figma button is visible but has no prototype interaction.
- Persist sessions using the Supabase Flutter SDK session behavior; do not hand-roll token storage.
- On startup, restore a valid session and route to Home. Without a valid session, use the public splash/auth path.
- Logout clears the Supabase session and replaces the protected navigation stack with the public auth entry. The exact return screen is pending.
- Map recoverable auth failures to inline or otherwise user-readable messages. Do not expose raw credentials or log passwords/tokens.

## Customer identity and profile proposal

**Proposed logical contract; not a migration or approved schema.**

- Canonical customer identity: the UUID from Supabase Auth, not email or phone.
- Proposed profile relation: public.profiles.
- Proposed primary key and auth relationship: profiles.id UUID, primary key and foreign key to auth.users.id, with deletion behavior to be decided by Member 2.
- Logical profile fields: full_name, phone_number, and saved_address. saved_address should begin unset because it is not a proposed registration field.
- Figma displays the customer email on Profile. Proposed UI should read it from the Auth user; duplicating email into public.profiles is not assumed.
- Member 2 owns the database relation, trigger, constraints, RLS, and backend policies. Member 3 owns viewing and editing profile data. Member 1 owns auth registration and identity handoff.
- Proposed creation mechanism: a database trigger creates a profile after an auth user is created, copying full_name and phone_number from validated auth user metadata. Member 2 must review trigger safety and failure behavior.
- Require user-scoped reads and updates: the signed-in user may access only the row whose id matches auth.uid(). Public profile exposure is not assumed.
- Exact column names, nullability, phone format, address representation, trigger details, and policies remain pending.

## Booking data proposal

**Logical request contract from the proposed two-step Figma flow; physical names and types are pending Member 2’s schema design.**

| Logical value | Purpose | Proposed source/handling |
|---|---|---|
| customer_id | Owning customer | Supabase Auth UUID |
| service_id or service key | Selected service | Member 2’s approved service catalog contract |
| description | Problem/job description | Booking step 1 |
| service_address_snapshot | Address for this request | Booking input; preserve the submitted value for the request |
| preferred_date | Requested service date | Booking step 1; allowed range/time zone pending |
| preferred_time | Requested service time | Booking step 1; allowed slots/time zone pending |
| contact_name_snapshot | Name for the request | Copy from the profile at submission, subject to team approval |
| contact_phone_snapshot | Phone for the request | Copy from the profile at submission, subject to team approval |
| photo_storage_path | Optional single photo object path | Upload to Supabase Storage; store an object path, not a privileged or assumed-public URL |
| status | Current request status | Start at NEW if the proposed lifecycle is approved |

The Figma step 2 displays customer name and phone but step 1 does not collect them. Reusing profile values as immutable booking contact snapshots is a proposal. Required-field rules, edit behavior before confirmation, time representation, table name, column names, identifiers, and retention are pending. The booking form and summary are UI evidence, not a database schema.

## Booking lifecycle and actor proposal

**Proposed lifecycle, pending Member 2 backend review and agreement from all three members.** Figma directly shows this main timeline:

NEW → REVIEWING → SCHEDULED → ASSIGNED → IN_PROGRESS → COMPLETED → CONFIRMED

The Status Badge component also shows CANCELLED and REJECTED. It does not define transitions or who can perform them.

| From | To | Proposed authorized actor | Notes |
|---|---|---|---|
| No request | NEW | Authenticated customer | Created after booking confirmation |
| NEW | REVIEWING | Authorized operator through an approved backend workflow | Never a client-selected status |
| NEW | CANCELLED | Customer | Recommended cancellation window; approval pending |
| REVIEWING | SCHEDULED | Authorized operator | Schedule details and notice behavior pending |
| REVIEWING | REJECTED | Authorized operator | Terminal outcome; reason/notice behavior pending |
| REVIEWING | CANCELLED | Customer | Recommended cancellation window; approval pending |
| SCHEDULED | ASSIGNED | Authorized operator | Assignment record and actor model pending |
| ASSIGNED | IN_PROGRESS | Authorized operator | No worker mobile app is in scope |
| IN_PROGRESS | COMPLETED | Authorized operator | Completion evidence/confirmation behavior pending |
| COMPLETED | CONFIRMED | Customer | Proposed customer acknowledgement after service |

Proposed terminal states are CONFIRMED, CANCELLED, and REJECTED. Do not permit clients to set arbitrary statuses or skip steps. Other transitions are disallowed unless the team approves a revised matrix. The admin/operator identity, permissions, use of Supabase Dashboard versus a restricted backend mechanism, status audit trail, and rejection reason are unresolved backend decisions.

Customer cancellation of NEW and REVIEWING requests is recommended, not approved. Cancellation after REVIEWING and the point at which the cancel action disappears require team agreement.

## Reviews proposal

**Proposed, pending Member 3 design and team approval.**

- One customer review per booking.
- Eligible after COMPLETED or CONFIRMED; the team must choose the precise eligibility point.
- Link a review to the booking and authenticated customer UUID.
- Rating scale, comment requirements, edit/delete policy, moderation, and review screen are not specified. The current Figma has no post-service rating/review screen. Do not implement by inferring these values.

## Supabase and security conventions

**Security principles are project requirements; concrete schema and policy design is Member 2’s work.**

- The Flutter app uses only client-safe Supabase configuration. Never bundle the service-role key.
- Enable and test Row Level Security for customer-owned records. Policies should use the authenticated UUID and restrict reads/writes to the owning customer.
- Booking status changes and administrative actions must be validated outside untrusted client input.
- Storage bucket, object path format, file validation, and Storage RLS remain pending. The proposed photo path should be scoped to the owning customer and booking.
- Database triggers, policies, and migrations must be reviewed by Member 2; Phase 01 creates no database objects.
- Client-side route protection improves navigation but does not replace database authorization.

## Decision register

| ID | Decision | Initial proposal or evidence | Responsible members | Status |
|---|---|---|---|---|
| D01 | Feature-first architecture and feature ownership | Structure and owners in docs/ARCHITECTURE.md and docs/DEVELOPMENT_PLAN.md | All; Member 1 coordinates | Confirmed baseline; detailed folder layout for review |
| D02 | Main customer navigation | Home, Services, Requests, Profile; directly visible in Figma | Member 1; Member 2 and Member 3 review their destinations | Observed; route contract pending |
| D03 | Router package | Centralized router; consider go_router | Member 1 | Proposed; no dependency added |
| D04 | State management | Consider Riverpod; prefer the simplest state that meets needs | Member 1 | Proposed; no dependency added |
| D05 | Auth provider and registration fields | Email/password; full name, email, phone, password, confirm password | Member 1; Member 2 configures backend | Proposed; approval pending |
| D06 | Verification, recovery, Google auth | Email verification and password recovery; defer Google unless required | Member 1 and Member 2 | Proposed; screen designs missing |
| D07 | Session restore and logout routing | Restore valid session to Home; logout to a clean public auth stack | Member 1 | Proposed; approval pending |
| D08 | Customer identity | Supabase Auth UUID as customer identity | Member 1, Member 2, Member 3 | Proposed; approval pending |
| D09 | Profile fields and creation | profiles.id references auth.users.id; full name, phone, saved address; DB trigger | Member 2 schema/trigger, Member 3 profile UI, Member 1 signup | Proposed; schema and trigger review pending |
| D10 | Booking payload and contact snapshots | Two-step flow; customer/service/description/address/date/time; name and phone snapshots | Member 2 schema, Member 1 shared contract, Member 3 profile handoff | Proposed; approval pending |
| D11 | Booking photo storage | Optional one photo in Supabase Storage; store object path | Member 2; Member 1 and Member 3 review | Proposed; bucket and policies pending |
| D12 | Status values, transitions, actors | Main Figma sequence plus CANCELLED and REJECTED terminal states | Member 2 backend, Member 3 tracking, Member 1 app contract | Proposed; approval pending |
| D13 | Customer cancellation | Permit cancellation only in NEW or REVIEWING | All; Member 2 enforces, Member 3 presents | Recommended; approval pending |
| D14 | Review eligibility | One review per booking after COMPLETED or CONFIRMED | Member 3, Member 2 schema, Member 1 route | Recommended; approval and design pending |
| D15 | Admin testing mechanism | Authorized Dashboard or restricted backend flow, outside the app | Member 2; all review access boundary | Scope confirmed; mechanism pending |
| D16 | Release internet permission | Main manifest in scaffold lacks INTERNET; debug/profile contain it | Member 2 | Observed implementation requirement; resolve before release networking |
