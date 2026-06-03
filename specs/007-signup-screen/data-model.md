# Data Model: Sign Up Screen

**Date**: 2026-05-12 | **Branch**: `007-signup-screen`

## Entities

### CurrentUserModel (existing — no changes needed)

Already contains all required fields at `lib/core/app/models/current_user_model.dart`:

| Field | Type | Source |
|-------|------|--------|
| uid | String | Firebase Auth |
| email | String? | Sign-up form |
| name | String? | Sign-up form |
| phoneNumber | String? | Sign-up form |
| photoUrl | String? | UserAvatarImage upload (Supabase) |
| emailVerified | bool | Firebase Auth |
| isAnonymous | bool | Firebase Auth |
| providerId | String? | Firebase Auth |
| creationTime | DateTime? | Firebase Auth |
| lastSignInTime | DateTime? | Firebase Auth |

### Firestore Document: `users/{uid}`

Same structure as `CurrentUserModel.toFirestore()` — already used by sign-in flow. Sign-up will write the same document with additional `name`, `phoneNumber`, and `photoUrl` populated from the form.

## State

### AuthState (existing — no changes needed)

Already has all needed states at `lib/core/app/auth_cubit/auth_state.dart`:
- `loading` — during account creation
- `authenticated` — on success
- `error(message)` — on failure (e.g., email already in use)

## Validation Rules

| Field | Rule | Regex/Logic | Error Key |
|-------|------|-------------|-----------|
| Email | Valid email format | `AppRegex.isEmailValid` | `LangKeys.invalidEmail` |
| Password | Min 8 chars, upper+lower+digit+special | `AppRegex.isPasswordValid` | `LangKeys.invalidPassword` |
| Confirm Password | Must match password | `== password` | `LangKeys.passwordsDoNotMatch` |
| Phone | 8-15 digits, optional + prefix | `AppRegex.isPhoneValid` | `LangKeys.invalidPhoneNumber` |
| Name | Non-empty | `trim().isNotEmpty` | New: `LangKeys.nameCannotBeEmpty` |
