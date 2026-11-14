# AGENTS.md — Agent & AI Assistant Guide for TIKKA

This repository contains the **TIKKA** Home Services Mobile Application developed for module **EC5208 – Mobile Application Development** at the **Faculty of Engineering, University of Ruhuna, Sri Lanka**.

All AI coding assistants (OpenAI Codex, GitHub Copilot, Antigravity, Claude, Cursor, etc.) working on this repository **must** strictly adhere to the instructions, constraints, and development standards below.

---

## 1. Critical Governance & GitHub Rules

### 1.1 Never Add Agents as Contributors
- **NEVER** add AI agents or bots as GitHub contributors, commit authors, or co-authors.
- **DO NOT** append `Co-authored-by: <agent/bot>` trailers to commit messages.
- **DO NOT** alter `git config user.name` or `git config user.email` to represent an AI agent.
- **Reason:** This is an academic group project evaluated by university examiners who grade individual students based on GitHub commit history and contribution metrics. All commits must be attributed cleanly to the human student developer.

### 1.2 GitHub MCP & Remote Actions
- If GitHub MCP or remote tools (e.g., git push, PR creation, issue modifications) are available, **always request explicit user confirmation** before executing any write or remote operation.
- Never push directly to remote branches or merge pull requests autonomously without explicit user approval.

---

## 2. Git Workflow & Branching Strategy

### 2.1 Branching Convention
- **Never commit directly to `main`**. `main` is protected and represents the verified, shared integration branch.
- **Always create a dedicated branch** for any new feature, bugfix, or task:
  - Feature branches: `feature/<feature-name>` (e.g., `feature/authentication`, `feature/service-booking`, `feature/request-tracking`)
  - Fix branches: `fix/<issue-name>` (e.g., `fix/validation-error-display`, `fix/route-guard-session`)
  - Chore branches: `chore/<task-name>` (e.g., `chore/supabase-setup`, `chore/theme-update`)
  - Docs branches: `docs/<doc-name>` (e.g., `docs/api-specifications`)
  - Test branches: `test/<test-name>` (e.g., `test/booking-form-unit-tests`)
- Before starting work on any task, ensure the working branch is branched off the latest `main`.

### 2.2 Standard Commit Messages (Conventional Commits)
All commit messages must follow the Conventional Commits specification:
```text
<type>(<optional scope>): <imperative description>
```

- **Allowed Types**:
  - `feat`: A new feature or screen
  - `fix`: A bug fix
  - `chore`: Changes to build process, tooling, dependencies, or configuration
  - `docs`: Documentation updates
  - `style`: Formatting, whitespace, semicolon changes (no code logic change)
  - `refactor`: Code reorganization without changing external behavior or fixing bugs
  - `test`: Adding or correcting tests
  - `perf`: Performance improvements
- **Format Rules**:
  - Use imperative mood in present tense (e.g., `feat(auth): add login form validation`, **not** `added login form validation`).
  - All lowercase description.
  - Do not end the description with a period.
  - Keep the subject line concise (under 72 characters).

---

## 3. Project Overview & Requirements

### 3.1 Academic Details
- **Module**: EC5208 – Mobile Application Development (5th Semester)
- **Institution**: Department of Electrical and Information Engineering, Faculty of Engineering, University of Ruhuna
- **Group**: Group 10
- **Team**:
  - EG/2023/5624 – Hansana H.A.J (Request Tracking, Profile, Reviews, QA)
  - EG/2023/5634 – Herath H.M.K.U.A / Kavindu (Services and Booking)
  - EG/2023/5821 – Ranawaka P.S. (Project Lead, Flutter Architecture, Authentication)
- **Evaluation**: Project replaces the End Semester Examination and accounts for 50% of the course grade.
- **Strict Final Deadline**: Tuesday, 15th December 2026.

### 3.2 Application Concept
- **Product Name**: TIKKA (Home Services Mobile Application)
- **Target Platform**: Android (built with Flutter for cross-platform readiness)
- **Package Name**: `tikka`
- **Application ID**: `com.tikka.app`
- **Goal**: Provide a clean, structured customer mobile workflow for discovering household services (cleaning, electrical, plumbing, painting, repairs, etc.), submitting service requests, tracking progress, and submitting post-service reviews.

### 3.3 Target Technology Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **Target Platform**: Android
- **Backend & Database**: REST API / Supabase with PostgreSQL
- **UI/UX Design**: Figma Prototype (`https://www.figma.com/design/bD3SdH2CC3THMDWD2eZnkf/TIKKA-Mobile-App-%E2%80%94-Flutter-MVP`)
- **Version Control**: Git & GitHub

### 3.4 Core MVP Scope (In-Scope)
1. **Authentication (FR-01, FR-02)**: Customer sign-up, login, logout, and secure session management.
2. **Service Browsing (FR-03)**: Browse categories (Cleaning, Electrical, Gardening, Handyman, Moving, Painting, Plumbing, Repairs) and view details.
3. **Service Request Submission (FR-04)**: Structured booking form (service type, problem description, preferred date & time, address, contact details, optional photo upload).
4. **Request History & Status Tracking (FR-05, FR-06)**: Filter requests (Active, Completed, Cancelled) and track status:
   `NEW` → `REVIEWING` → `SCHEDULED` → `ASSIGNED` → `IN_PROGRESS` → `COMPLETED` → `CONFIRMED`.
5. **Customer Profile (FR-07)**: View and update customer personal details and address.
6. **Rating & Reviews (FR-08)**: Submit star ratings and feedback for completed services.

### 3.5 Out of Scope for MVP
- No online payment processing / payment gateways (handled offline/cash on completion).
- No real-time chat between customer and worker.
- No live GPS tracking of service personnel.
- No worker/service-provider mobile app (customer client only).
- No administrative portal inside the mobile app.

---

## 4. Codebase Architecture & Standards

### 4.1 Folder Structure
The codebase follows a **feature-first** modular architecture:
```text
TIKKAapp/
├── lib/
│   ├── main.dart             # Application entry point
│   ├── app/                  # App setup, top-level routing, theme
│   │   ├── app.dart
│   │   ├── router/
│   │   └── theme/
│   ├── core/                 # Shared cross-cutting concerns
│   │   ├── constants/        # App colors, strings, asset paths, API endpoints
│   │   ├── utils/            # Validators, formatters, helpers
│   │   └── widgets/          # Reusable UI components (buttons, input fields, cards)
│   └── features/             # Business domain features
│       ├── auth/             # Login, registration, session
│       ├── services/         # Service discovery & category catalog
│       ├── bookings/         # Service request form & submission
│       ├── tracking/         # Request history, status timeline
│       ├── profile/          # User profile view & edit
│       └── reviews/          # Service rating and feedback
├── test/                     # Unit, widget, and integration tests
└── android/                  # Android native project configuration
```

### 4.2 Flutter / Dart Code Quality Guidelines
1. **Formatting**: Every change must be formatted using:
   ```bash
   dart format lib test
   ```
2. **Static Analysis**: All code must pass without errors or warnings:
   ```bash
   flutter analyze
   ```
3. **Tests**: All tests must pass before opening a PR:
   ```bash
   flutter test
   ```
4. **Error Handling**: Never let network or validation failures crash the app. Display user-friendly snackbars, banners, or inline error text.
5. **UI Consistency**: Match the colors, typography, and layout specified in `lib/app/theme/app_theme.dart` and the Figma design.

---

## 5. Agent Instructions Checklist
Before completing any task:
1. [ ] Was a separate branch created (`feature/*`, `fix/*`, `chore/*`) instead of committing to `main`?
2. [ ] Is the commit message formatted with Conventional Commits (`feat:`, `fix:`, `chore:`, etc.)?
3. [ ] Are commit author and trailers free of any agent/bot attribution?
4. [ ] Was user permission requested before any GitHub MCP or remote action?
5. [ ] Did the code pass `dart format`, `flutter analyze`, and `flutter test`?
