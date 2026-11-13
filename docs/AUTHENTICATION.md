# TIKKA Customer Authentication

Phase 04 implements customer authentication with Supabase Auth. It supports email/password sign-in and registration, email confirmation, password recovery, session restoration, protected customer routes, and logout. Google sign-in remains deferred. Registration, verification, and recovery layouts are implementation drafts because Figma does not contain those screens.

## Local configuration

1. Copy `config/supabase.example.json` to `config/supabase.local.json`.
2. Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` to the client-safe values for the team's Supabase project. The SDK initialization parameter is named `publishableKey`; the project's client-safe anon key can be supplied there.
3. Run the app from the repository root:

   ```sh
   flutter run --dart-define-from-file=config/supabase.local.json
   ```

`config/supabase.local.json` is git-ignored. Never put a service-role key in the app, a define file, or source control. The Flutter route guard improves navigation but is not a security boundary; keep Row Level Security enabled and enforce access in PostgreSQL policies.

## Supabase project settings

Member 2 must confirm these settings in the actual project before end-to-end auth use:

- Email confirmation is enabled for sign-up.
- `tikka://auth-callback` is included in the Auth allowed redirect URLs. The same URI is handled by the Android manifest.
- Confirmation and recovery email templates link back to the app and work with the configured redirect.
- The `handle_new_user()` trigger maps signup metadata keys `full_name` and `phone_number` to `public.profiles`.

The repository contains migration and seed files, but their presence does not establish that they were applied to a live Supabase project.

## Implemented behavior

- New accounts collect full name, email, phone number, password, and client-only password confirmation. Name and phone are sent as Supabase user metadata for the profile trigger.
- Unverified accounts are not treated as authenticated. The verification screen can resend the signup email.
- Password reset requests use a generic confirmation message so the UI does not disclose whether an email is registered. A recovery callback opens the reset-password form.
- A restored, email-verified Supabase session opens Home. Signed-out users enter through the splash/login flow. Logout clears the Supabase session and returns to the public login flow.
- Google sign-in is visible in the Figma login design but remains disabled pending provider setup and product confirmation.

## Configuration defines

| Define | Required | Purpose |
|---|---:|---|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Client-safe anon/publishable key |
| `TIKKA_AUTH_REDIRECT_URL` | No | Auth callback URI; defaults to `tikka://auth-callback` |

## Verification

`flutter analyze` reports no issues. All 13 widget and repository tests pass, covering Supabase request metadata and redirects, auth-state snapshots, user-readable failures, login validation, registration-to-verification navigation, and the generic recovery confirmation. The Android callback and live Supabase email settings still need on-device/project verification.
