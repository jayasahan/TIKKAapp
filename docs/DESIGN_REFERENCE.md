# TIKKA Figma Design Reference

**Review date:** 12 November 2026

**Reference:** [TIKKA Mobile App — Flutter MVP](https://www.figma.com/design/ZkL4pUNzpc3cJ1groSn2KT/TIKKA-Mobile-App-%E2%80%94-Flutter-MVP--Copy-?node-id=0-1&m=dev&t=mo3oijoMwRdsSb6r-1)

This review used the read-only Figma integration. The supplied URL opens node 0:1, the page named “01 — Foundations.” The file also contains “02 — Components,” “03 — Screens,” and “04 — Prototype.” Its ten screen frames are on the Screens and Prototype pages. Figma observations below describe the current design only; they do not establish backend schema, validation, authorization, or product behavior beyond recorded prototype links.

## Screen inventory

| Screen | Directly observed content and purpose |
|---|---|
| 01 Splash | TIKKA logo, “Get it done.” tagline, Sinhala tagline, and trust message. The Prototype page starts its main flow here. |
| 02 Login Register | Email and Password fields; Login; Forgot password?; Continue with Google; Create account. |
| 03 Home | Greeting, service request hero, four featured categories, an active request card, and bottom navigation. |
| 04 Services | Search field and service-category cards. |
| 05 Service Details | Plumbing example: service description, common jobs, and Request Service action. |
| 06 Request Service | Booking step 1 of 2: selected service, job description, address, preferred date/time, and optional photo. |
| 07 Review Confirmation | Booking step 2 of 2: summary of service, job, address, date, time, and customer contact; Edit and Confirm Request actions. This is a pre-submission booking summary, not a service-rating screen. |
| 08 My Requests | Active, Completed, and Cancelled filters; request cards and status badges. |
| 09 Request Tracking | Request summary, progress timeline, worker assignment placeholder, and Contact Support action. |
| 10 Profile | Customer summary, saved address, Edit Profile, Notifications, Language, Help & Support, Privacy, and Logout rows. |

No separate registration, email-verification, password-reset, profile-edit, or customer-review screen is present. Some menu/action labels have no destination in the Prototype page.

## Prototype flow observed

The recorded prototype start point is named “TIKKA Main Flow” and targets the Splash frame.

- Tapping Splash opens Login/Register.
- Login opens Home.
- Home’s Request a Service action opens Services.
- Service cards lead to the Plumbing Service Details example.
- Request Service opens booking step 1; Continue opens the step 2 summary.
- Confirm Request opens Request Tracking.
- A My Requests card opens Request Tracking.
- Bottom navigation shows Home, Services, Requests, and Profile destinations.

The prototype does not connect Create account, Forgot password?, Continue with Google, Edit, Logout, or Contact Support to destination screens. The four-tab navigation is not wired consistently on every prototype screen. Existing-session restoration and auth guards are not demonstrated.

## Authentication and onboarding observations

- The only visible credential fields are Email and Password on Login/Register.
- Continue with Google is visible, but the prototype has no interaction for it.
- Create account and Forgot password? are visible links without destinations.
- There is no registration form, verification notice, password-reset form, loading state, or auth error screen.
- Splash is the only onboarding/welcome-style screen. The Login/Register subtitle says “Sign in to request trusted local services.”

Registration fields, verification, recovery behavior, supported providers, and logout routing remain proposed or unresolved in docs/SHARED_CONTRACTS.md.

## Services and booking observations

The Services screen shows eight categories: Cleaning, Electrical, Gardening, Handyman, Moving, Painting, Plumbing, and Repairs. Home features Cleaning, Electrical, Plumbing, and Repairs.

The only detailed service example is Plumbing. It has a short description and lists leaking taps/pipes, blocked sinks/drains, fitting/replacing fixtures, and minor repairs.

Booking step 1 visibly contains:

- Selected service
- Problem/job description
- Address
- Preferred date
- Preferred time
- Optional photo, with copy indicating one photo

The step 2 summary repeats the job, address, date, and time, and displays a customer name and phone number. It provides Edit and Confirm Request buttons. The prototype records Continue to step 2 and Confirm Request to Tracking. It does not record an Edit destination or a separate post-submit success page.

No price, service duration, location picker/map, address subfields, date/time constraints, required-field markers, or photo upload validation is visible.

## Profile, tracking, and status observations

The Profile summary displays a name, email, masked phone number, and saved address. Edit Profile is a menu row, but its screen is absent. The screen also lists Notifications, Language (English selected), Help & Support, Privacy, and Logout. English, Sinhala, and Tamil are named in language-support copy.

The request list filters are Active, Completed, and Cancelled. Example cards show SCHEDULED, REVIEWING, and COMPLETED.

The Tracking timeline displays:

NEW → REVIEWING → SCHEDULED → ASSIGNED → IN PROGRESS → COMPLETED → CONFIRMED

The summary card shows scheduled date/time and address. Worker details are replaced with “Worker not assigned yet,” and the screen offers Contact Support. The Status Badge component sheet additionally shows CANCELLED and REJECTED. No cancellation control, transition rule, support destination, GPS view, or review-eligibility behavior is wired in this design.

The visible “IN PROGRESS” label is presentation text. The proposed canonical application/backend spelling IN_PROGRESS is not a decision made by Figma.

## Ratings and reviews

No post-service rating or review screen is present. There is no visible star scale, comment field, eligibility rule, or navigation to a review. The screen titled Review Confirmation is a booking-summary step. Add the review UI to the design before implementing Phase 09 requirements; do not infer its fields from the title.

## Shared UI and design tokens

The Foundations page presents these values:

| Token | Value |
|---|---|
| Brand Yellow | #FCE314 |
| Black | #000000 |
| White | #FFFFFF |
| Success | #17803D |
| Warning | #B85C00 |
| Error | #C92A2A |
| Info | #1F66D1 |
| Default background | #F7F7F5 |
| Secondary text | #777770 |
| Default border | #D4D4D0 |

Typography is Inter. The type specimens show Display 36/44 Bold, H1 28/36 Bold, H2 22/30 Semi Bold, H3 18/26 Semi Bold, Body 16/24 Regular, Body Small 14/20 Regular, Label 14/20 Medium, and Caption 12/16 Regular. Values are size/line-height in pixels.

The Foundations page states a 390 × 844 reference frame, 8-point spacing rhythm, 20 px default screen margin, 48 px minimum touch targets, and 16 px default card radius. The Components page shows 14 px button radius, 12 px input radius, and 20 px outer bottom-navigation radius.

Reusable patterns shown:

- Yellow primary, outlined secondary, text/link, and disabled button variants.
- Input states: default, focused, populated, invalid, and disabled. The invalid example says “invalid email.”
- White rounded service/request cards.
- Status badge variants for NEW, REVIEWING, SCHEDULED, ASSIGNED, IN PROGRESS, COMPLETED, CONFIRMED, CANCELLED, and REJECTED, with blue, orange, yellow, green, gray, and red semantic treatments.
- Four-item bottom navigation with a yellow selected-tab background.

A yellow “Request ready to submit” panel appears on the booking review step before the Confirm Request action. It is not evidence of a successful backend submission. No app-level loading, empty-list, or network-failure state is shown.

## Design follow-ups and quality notes

- The Foundations guidance says 20 px default screen margin, while screen frames commonly place content 16 px from the edge. Clarify the intended margin before shared UI is standardized.
- In the rendered Home frame, the hero heading appears clipped at the right edge. Confirm and correct during Phase 13 visual consistency work.
- Registration, verification, password reset, profile edit, and post-service review flows need design references. The visible Forgot password, Create account, and Logout controls need defined destinations/behavior.
- The Figma UI is a visual and interaction reference only. Member 2 must define database schema, RLS, Storage rules, status authorization, and the administrative testing workflow.
