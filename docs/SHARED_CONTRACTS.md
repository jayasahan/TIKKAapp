# TIKKA Shared Contracts and Decision Register

**Review state:** Phase 01 architecture established; Phase 02 backend schema, RLS, and storage contracts finalized by Member 2.

## Status key

- **Confirmed** — stated in the current project brief, established guidance, or approved by the owning member.
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

**Confirmed backend contract (Phase 02 / Member 2).**

- Canonical customer identity: the UUID from Supabase Auth (`auth.uid()`), not email or phone.
- Profile relation: `public.profiles`.
- Primary key and auth relationship: `profiles.id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE`.
- Profile fields: `full_name`, `phone_number`, `saved_address`, and `avatar_url`. `saved_address` starts `NULL`.
- Creation mechanism: PostgreSQL trigger `handle_new_user()` on `auth.users` automatically creates the profile row after user registration, extracting `full_name` and `phone_number` from `raw_user_meta_data`.
- Row Level Security:
  - `SELECT`: `auth.uid() = id` (User can read own profile).
  - `UPDATE`: `auth.uid() = id` (User can edit own profile).

## Booking data proposal

**Confirmed backend contract (Phase 02 / Member 2).**

| Logical value | Column name | Purpose | Handling |
|---|---|---|---|
| customer_id | `customer_id` | Owning customer | Supabase Auth UUID (`auth.uid()`) |
| service_id | `service_id` | Selected service | Foreign key to `public.services(id)` |
| booking_reference | `booking_reference` | Readable code | Auto-generated via trigger (`TK-1001`...) |
| description | `problem_description` | Problem/job description | Collected in Booking Step 1 |
| service_address_snapshot | `service_address_snapshot` | Address for this request | Preserved immutable request address |
| preferred_date | `preferred_date` | Requested service date | `DATE` input |
| preferred_time | `preferred_time` | Requested service time | Time slot string |
| contact_name_snapshot | `contact_name_snapshot` | Name for the request | Immutable contact name snapshot |
| contact_phone_snapshot | `contact_phone_snapshot` | Phone for the request | Immutable contact phone snapshot |
| photo_storage_path | `photo_storage_path` | Optional photo path | Relative path in `booking-photos` bucket |
| status | `status` | Request lifecycle state | Starts at `NEW` upon submission |

## Booking lifecycle and actor proposal

**Confirmed lifecycle & RLS enforcement (Phase 02 / Member 2).**

The main timeline directly reflects Figma:

NEW → REVIEWING → SCHEDULED → ASSIGNED → IN_PROGRESS → COMPLETED → CONFIRMED

Terminal states: `CONFIRMED`, `CANCELLED`, `REJECTED`.

| From | To | Authorized actor | Enforcement |
|---|---|---|---|
| No request | NEW | Authenticated customer | RLS `INSERT` policy with `status = 'NEW'` |
| NEW | REVIEWING | Authorized operator | Admin/Dashboard testing workflow |
| NEW | CANCELLED | Customer | RLS `UPDATE` policy (`status IN ('NEW', 'REVIEWING')`) |
| REVIEWING | SCHEDULED | Authorized operator | Admin/Dashboard testing workflow |
| REVIEWING | REJECTED | Authorized operator | Admin/Dashboard testing workflow |
| REVIEWING | CANCELLED | Customer | RLS `UPDATE` policy (`status IN ('NEW', 'REVIEWING')`) |
| SCHEDULED | ASSIGNED | Authorized operator | Admin/Dashboard testing workflow |
| ASSIGNED | IN_PROGRESS | Authorized operator | Admin/Dashboard testing workflow |
| IN_PROGRESS | COMPLETED | Authorized operator | Admin/Dashboard testing workflow |
| COMPLETED | CONFIRMED | Customer | RLS `UPDATE` policy (`status = 'COMPLETED'`) |

## Reviews proposal

**Confirmed backend contract (Phase 02 / Member 2).**

- Table: `public.reviews`
- Constraint: `booking_id UNIQUE REFERENCES public.bookings(id) ON DELETE CASCADE` (strictly 1 review per booking).
- Rating scale: `CHECK (rating >= 1 AND rating <= 5)`.
- Eligibility: Customer can insert a review only for bookings in `COMPLETED` or `CONFIRMED` status where `auth.uid() = customer_id`.
- Review display: Publicly readable for service feedback.

## Supabase and security conventions

- The Flutter app uses only client-safe Supabase configuration (`SUPABASE_URL` and `SUPABASE_ANON_KEY`). Never bundle the service-role key.
- Row Level Security (RLS) is enabled on all tables (`profiles`, `service_categories`, `services`, `bookings`, `reviews`).
- Storage bucket `booking-photos` is configured with user-scoped RLS (`(storage.foldername(name))[1] = auth.uid()::text`).
- No administrative portal inside the mobile app; administrative testing is conducted via Supabase Studio or authorized SQL helpers (documented in `docs/BACKEND_SPECIFICATION.md`).

## Decision register

| ID | Decision | Initial proposal or evidence | Responsible members | Status |
|---|---|---|---|---|
| D01 | Feature-first architecture and feature ownership | Structure and owners in docs/ARCHITECTURE.md and docs/DEVELOPMENT_PLAN.md | All; Member 1 coordinates | Confirmed baseline |
| D02 | Main customer navigation | Home, Services, Requests, Profile; directly visible in Figma | Member 1; Member 2 and Member 3 review their destinations | Observed; route contract pending |
| D03 | Router package | Centralized router; consider go_router | Member 1 | Proposed; no dependency added |
| D04 | State management | Consider Riverpod; prefer the simplest state that meets needs | Member 1 | Proposed; no dependency added |
| D05 | Auth provider and registration fields | Email/password; full name, email, phone, password, confirm password | Member 1; Member 2 configures backend | Proposed; approval pending |
| D06 | Verification, recovery, Google auth | Email verification and password recovery; defer Google unless required | Member 1 and Member 2 | Proposed; screen designs missing |
| D07 | Session restore and logout routing | Restore valid session to Home; logout to a clean public auth stack | Member 1 | Proposed; approval pending |
| D08 | Customer identity | Supabase Auth UUID as customer identity | Member 1, Member 2, Member 3 | Confirmed; enforced across schema and RLS |
| D09 | Profile fields and creation | profiles.id references auth.users.id; full name, phone, saved address; DB trigger | Member 2 schema/trigger, Member 3 profile UI, Member 1 signup | Confirmed by Member 2 in Phase 02 migrations |
| D10 | Booking payload and contact snapshots | Two-step flow; customer/service/description/address/date/time; name and phone snapshots | Member 2 schema, Member 1 shared contract, Member 3 profile handoff | Confirmed by Member 2 in Phase 02 migrations |
| D11 | Booking photo storage | Optional one photo in Supabase Storage; store object path | Member 2; Member 1 and Member 3 review | Confirmed by Member 2 (bucket 'booking-photos' + folder RLS) |
| D12 | Status values, transitions, actors | Main Figma sequence plus CANCELLED and REJECTED terminal states | Member 2 backend, Member 3 tracking, Member 1 app contract | Confirmed by Member 2 (CHECK constraint + status lifecycle) |
| D13 | Customer cancellation | Permit cancellation only in NEW or REVIEWING | All; Member 2 enforces, Member 3 presents | Confirmed by Member 2 (enforced via RLS update policy) |
| D14 | Review eligibility | One review per booking after COMPLETED or CONFIRMED | Member 3, Member 2 schema, Member 1 route | Confirmed by Member 2 (enforced via RLS insert policy) |
| D15 | Admin testing mechanism | Authorized Dashboard or restricted backend flow, outside the app | Member 2; all review access boundary | Confirmed by Member 2 in docs/BACKEND_SPECIFICATION.md |
| D16 | Release internet permission | Main manifest in scaffold lacks INTERNET; debug/profile contain it | Member 2 | Observed implementation requirement; resolve before release networking |
