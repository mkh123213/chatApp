# Implementation Plan: Sign Up Screen

**Branch**: `007-signup-screen` | **Date**: 2026-05-12 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/007-signup-screen/spec.md`

## Summary

Build a sign-up screen matching the login screen's Material 3 design theme, with fields for name, email, phone, password, and confirm password, plus the existing `UserAvatarImage` widget for optional profile photo upload. Uses Firebase Auth for account creation and Firestore for profile persistence.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: Flutter Bloc, Freezed, Firebase Auth, Cloud Firestore, Supabase (image storage), flutter_screenutil, iconsax
**Storage**: Firebase Firestore (`users/{uid}` collection), Supabase Storage (profile images), SharedPreferences (local cache)
**Testing**: Manual testing (project has no test framework configured)
**Target Platform**: Android & iOS
**Project Type**: Mobile app (Flutter)
**Constraints**: Must match login screen's visual design, use `context.color`, `context.translate`, `CustomTextField`, `CustomLinearButton`

## Constitution Check

*GATE: Constitution is the default template (not customized) — no specific gates to enforce.*

No violations.

## Project Structure

### Documentation (this feature)

```text
specs/007-signup-screen/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/features/auth/presentation/
├── screens/
│   ├── login_screen.dart          # Existing (reference)
│   └── sign_up_screen.dart        # NEW
├── widgets/
│   ├── log_in/                    # Existing (reference pattern)
│   │   ├── log_in_form.dart
│   │   └── log_in_bloc_consumer.dart
│   └── sign_up/                   # NEW directory
│       ├── sign_up_form.dart      # NEW
│       └── sign_up_bloc_consumer.dart  # NEW

lib/core/
├── app/auth_cubit/
│   └── auth_cubit.dart            # MODIFY — enhance createUserWithEmailAndPassword
├── language/
│   └── lang_keys.dart             # MODIFY — add new keys
└── routes/
    └── app_routes.dart            # MODIFY — uncomment signUp route

lang/
├── en.json                        # MODIFY — add translations
└── ar.json                        # MODIFY — add translations
```

**Structure Decision**: Follows the existing auth feature pattern — screen + widgets subfolder, mirroring the login feature's file organization exactly.

## Implementation Approach

### Step 1: Add Localization Keys
Add `nameCannotBeEmpty`, `accountCreatedSuccessfully`, `createAccount` to `lang_keys.dart`, `en.json`, `ar.json`.

### Step 2: Enhance AuthCubit.createUserWithEmailAndPassword
Expand to accept `name`, `phone`, `photoUrl` parameters. After Firebase Auth account creation:
1. Call `authService.updateUserName(name: name)`
2. Build `CurrentUserModel` with all fields
3. Save to Firestore `users/{uid}` (same as sign-in flow)
4. Save to SharedPreferences (same as sign-in flow)
5. Start presence service and save FCM token (same as sign-in flow)

### Step 3: Create SignUpScreen
`StatefulWidget` with controllers for name, email, phone, password, confirmPassword. Provides `AuthCubit` via route. Layout matches `LoginScreen`.

### Step 4: Create SignUpForm
`StatefulWidget` with:
- `UserAvatarImage` widget (wrapped in `BlocProvider<UploadImageCubit>`)
- Title text ("Create Account" / localized)
- 5 `CustomTextField` widgets with validators
- Password visibility toggle (same as login)
- `SignUpBlocConsumer` for submit button
- "Already have an account? Login" `CustomLinearButton` navigating back

### Step 5: Create SignUpBlocConsumer
`BlocConsumer<AuthCubit, AuthState>` — on `authenticated` navigate to `mainScreen` with success toast. On `error` show error toast. On `loading` show `CircularProgressIndicator`. On default show `CustomLinearButton` submit.

### Step 6: Wire Route
Uncomment the `signUp` case in `AppRoutes.onGenerateRoute` — provide both `AuthCubit` and `UploadImageCubit` via `MultiBlocProvider`.

## Complexity Tracking

No violations to justify.
