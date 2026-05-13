# Research: Sign Up Screen

**Date**: 2026-05-12 | **Branch**: `007-signup-screen`

## R1: Authentication Method for Sign Up

- **Decision**: Use Firebase Auth `createUserWithEmailAndPassword` — already available in `AuthService` and `AuthCubit.createUserWithEmailAndPassword()`
- **Rationale**: Method exists but currently does NOT save user profile data (name, phone, photoUrl) to Firestore after creation. The `signInWithEmailAndPassword` method does. The sign-up flow must be enhanced to also persist the full `CurrentUserModel` to Firestore and SharedPreferences after account creation.
- **Alternatives considered**: None — Firebase Auth is the project's auth provider.

## R2: User Profile Data Storage After Registration

- **Decision**: After Firebase Auth account creation, update the user's displayName via `authService.updateUserName()`, then build a `CurrentUserModel` with name, email, phone, and photoUrl, save to Firestore `users/{uid}` and SharedPreferences (same pattern as `signInWithEmailAndPassword` in `AuthCubit`).
- **Rationale**: The login flow already saves to Firestore + SharedPref. Sign-up must do the same so the user is immediately usable throughout the app.
- **Alternatives considered**: Separate profile setup screen after sign-up — rejected because user provides all data on the sign-up form already.

## R3: Profile Image Upload During Sign Up

- **Decision**: Reuse the existing `UserAvatarImage` widget (from groups feature) which uses `UploadImageCubit`. The cubit uploads to Supabase storage and exposes `getImageUrl`. This URL is saved into the user profile after account creation.
- **Rationale**: Widget and upload infrastructure already exist and are proven in the groups feature.
- **Alternatives considered**: None — user explicitly requested reusing this widget.

## R4: Form Validation

- **Decision**: Use existing `AppRegex` validators: `isEmailValid`, `isPasswordValid`, `isPhoneValid`. Add confirm-password match validation inline. Name validation: non-empty check.
- **Rationale**: All regex validators already exist. Lang keys for error messages exist (`invalidEmail`, `invalidPassword`, `invalidPhoneNumber`, `passwordsDoNotMatch`, `phoneCannotBeEmpty`).
- **Alternatives considered**: None.

## R5: Localization Keys

- **Decision**: Most required keys already exist in `lang_keys.dart` and `en.json`/`ar.json`: `signUp`, `email`, `password`, `confirmPassword`, `phone`, `name`, `invalidEmail`, `invalidPassword`, `invalidPhoneNumber`, `passwordsDoNotMatch`, `phoneCannotBeEmpty`. May need to add: `nameCannotBeEmpty`, `accountCreatedSuccessfully`, `createAccount` (for submit button text).
- **Rationale**: Consistent with existing localization pattern.

## R6: Routing

- **Decision**: The route `AppRoutes.signUp` already exists as a string constant. The `onGenerateRoute` case is commented out — just uncomment and wire it to the new `SignUpScreen`. Login form already navigates to `AppRoutes.signUp`.
- **Rationale**: Route infrastructure is already in place.
