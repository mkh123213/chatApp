# Quickstart: Sign Up Screen

**Date**: 2026-05-12 | **Branch**: `007-signup-screen`

## Prerequisites

- Flutter SDK installed
- Firebase project configured (already done)
- Supabase configured for image upload (already done)

## What to Build

### New Files

1. **`lib/features/auth/presentation/screens/sign_up_screen.dart`** — Screen widget (mirrors `LoginScreen` structure)
2. **`lib/features/auth/presentation/widgets/sign_up/sign_up_form.dart`** — Form widget with all fields (mirrors `LogInForm` structure)
3. **`lib/features/auth/presentation/widgets/sign_up/sign_up_bloc_consumer.dart`** — BlocConsumer for submit button (mirrors `LogInBlocConsumer`)

### Files to Modify

1. **`lib/core/app/auth_cubit/auth_cubit.dart`** — Enhance `createUserWithEmailAndPassword` to accept name, phone, photoUrl and persist full profile to Firestore + SharedPref (like `signInWithEmailAndPassword` does)
2. **`lib/core/routes/app_routes.dart`** — Uncomment and wire the `signUp` route case
3. **`lib/core/language/lang_keys.dart`** — Add missing keys: `nameCannotBeEmpty`, `accountCreatedSuccessfully`, `createAccount`
4. **`lang/en.json`** — Add English translations for new keys
5. **`lang/ar.json`** — Add Arabic translations for new keys

### No Changes Needed

- `CurrentUserModel` — already has all fields
- `AuthState` — already has all states
- `AuthService` / `FirebaseAuthService` — `createUserWithEmailAndPassword` already exists
- `AppRegex` — `isEmailValid`, `isPasswordValid`, `isPhoneValid` all exist
- `UserAvatarImage` widget — reuse as-is
- `UploadImageCubit` — reuse as-is
- `CustomTextField`, `CustomLinearButton`, `TextApp` — reuse as-is

## Design Pattern

Follow the exact same pattern as the login screen:
- `SignUpScreen` → `StatefulWidget` with controllers, provides `AuthCubit`
- `SignUpForm` → `StatefulWidget` with `SingleChildScrollView` > `Padding` > `Form` > `Column`
- `SignUpBlocConsumer` → `StatelessWidget` with `BlocConsumer<AuthCubit, AuthState>`
- Use `context.translate(LangKeys.xxx)` for all strings
- Use `context.color.xxx` for theme colors
- Use `CustomTextField` with validators and `Iconsax` icons
- Use `CustomLinearButton` for submit and "Already have an account? Login" buttons

## Build Commands

```shell
# After modifying freezed classes (not needed for this feature — no state changes)
# dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```
