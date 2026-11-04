# TIKKA - Home Services Mobile Application

TIKKA is an Android mobile application being developed for the
EC5208 Mobile Application Development module at the
Faculty of Engineering, University of Ruhuna, Sri Lanka.

The application aims to help users discover home services,
make bookings, track service requests, and submit reviews.

## Technology Stack

- Frontend: Flutter and Dart
- Platform: Android
- Backend (planned): Supabase
- Database (planned): PostgreSQL
- Authentication (planned): Supabase Authentication
- Version Control: Git and GitHub
- UI/UX Design: Figma

## Project Information

- Module: EC5208 - Mobile Application Development
- Project: TIKKA - Home Services Mobile Application
- Deadline: 15 December 2026
- Android Application ID: `com.tikka.app`
- Flutter Package Name: `tikka`

## Development Team

| Member | Responsibilities |
|--------|------------------|
| Prabodha Ranawaka | Project Lead, Flutter Architecture, Authentication |
| Kavindu | Services and Booking |
| Hansana | Request Tracking, Profile, Reviews and QA |

## Project Structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
└── features/
    ├── auth/
    ├── services/
    ├── bookings/
    ├── tracking/
    ├── profile/
    └── reviews/

test/
android/

The project follows a lightweight feature-first architecture.

Each feature will contain its own screens, widgets, models,
and data-access code as needed.

## Development Requirements

- Flutter 3.47.6 (stable)
- Dart 3.13.5
- Android SDK
- Android Studio or VS Code
- Git

## Getting Started

Clone the repository:

```bash
git clone https://github.com/jayasahan/TIKKAapp.git
cd TIKKAapp
```

Install Flutter dependencies:

```bash
flutter pub get
```

Check available devices:

```bash
flutter devices
```

Run the Android application:

```bash
flutter run -d <device-id>
```

## Code Quality

Format Dart code:

```bash
dart format lib test
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

All contributions should pass formatting, analysis,
and tests before a pull request is created.

## Git Workflow

- `main` is the shared integration branch.
- Each member develops changes on a separate feature branch.
- Do not commit directly to `main`.
- Open a pull request for teammate review before merging.
- Keep commits focused and descriptive.

Example branch names:

- `chore/flutter-scaffold`
- `feature/authentication`
- `feature/services-booking`
- `feature/request-tracking`

## Current Status

- [x] Flutter project initialized
- [x] Android application identifier configured
- [x] Feature-first folder structure established
- [x] Shared application theme created
- [x] Linting configured
- [x] Initial static analysis and widget tests passed
- [ ] Android emulator execution verified
- [ ] Supabase integration
- [ ] Authentication
- [ ] Services and booking
- [ ] Request tracking
- [ ] Profile and reviews

## Design Reference

Figma:
https://www.figma.com/design/bD3SdH2CC3THMDWD2eZnkf/TIKKA-Mobile-App-%E2%80%94-Flutter-MVP

## Notes

The initial scaffold retains Flutter's sample counter screen
temporarily to verify that the application builds and tests correctly.

Supabase integration and application features will be implemented
in subsequent development branches.

## License

This is an academic group project. No license has been selected yet.
