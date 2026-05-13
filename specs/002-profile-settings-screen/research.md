# Phase 0 Research: Profile & Settings Screen

All five clarifications were resolved in `/speckit-clarify` (see `spec.md` Clarifications section). This document captures the technical research that resulted from those answers and from project-convention scanning.

## R-01 — Profile data loading strategy

**Decision**: Cache-first read from SharedPreferences, then silent Firestore refresh in the background. On change, emit a new state and write back to SharedPref.

**Rationale**:

- Clarification answer Q1 = B.
- Matches SC-001 (200 ms render budget) by avoiding any blocking network on tab tap.
- Keeps cached `CurrentUserModel` fresh across sessions without forcing a spinner.

**Alternatives considered**:

- *Pure SharedPref* (Q1 = A): rejected per user choice — would let stale profile data persist after server-side updates.
- *Firestore-first* (Q1 = C): rejected — no offline rendering, breaks SC-001, contradicts the existing `getCurrentUser()` helper which is already SharedPref-based.

## R-02 — State management approach

**Decision**: Single `ProfileCubit` with a Freezed sealed state union covering profile load, profile refresh, and logout sub-flows.

**Rationale**:

- The project already standardizes on Cubit + Freezed (groups feature has `groups_cubit.freezed.dart`, `selected_group_chat_cubit.freezed.dart`, etc.).
- A single cubit per feature avoids cross-cubit coordination for what is conceptually one screen.
- `state.maybeWhen` from Freezed gives exhaustive UI handling without the boilerplate of explicit `is` checks.

**Alternatives considered**:

- *Two separate cubits (`ProfileCubit` + `LogoutCubit`)*: rejected — coordination overhead, no real separation of concerns since both flows share the same screen lifecycle.
- *No cubit, just `setState`*: rejected — violates the project's Cubit-only rule and mixes UI with side-effects.
- *Hand-rolled sealed class without Freezed* (per parent CLAUDE.md "no Freezed"): rejected — the project itself uses Freezed everywhere; the user explicitly asked for Freezed.

## R-03 — Avatar fallback rendering

**Decision**: When `photoUrl` is null, render a colored `CircleAvatar` containing the first uppercase letter of `name`. If `name` is also null, render `"?"`.

**Rationale**:

- Clarification answer Q3 = B.
- Standard pattern in modern chat/UX (Google, Slack, Teams).
- No new asset dependencies.

**Implementation note**: Use `context.color.bluePinkDark` or a deterministic hash of the UID to colorize the circle; either works. For simplicity, use a single color token across all users in v1.

## R-04 — Logout integration

**Decision**: Call `AppLogout().logout()` directly from `ProfileCubit.logout()`. Do not modify `AppLogout`.

**Rationale**:

- The existing singleton already handles Firebase sign-out, token cleanup, Hive cleanup, and navigation to login via `pushNamedAndRemoveUntil(AppRoutes.logIn)`.
- Per clarification Q4 = B, this screen does not pre-clear `PrefKeys.currentUser`. If currentUser cleanup is desired later, it belongs inside `AppLogout`.

**Alternatives considered**:

- *Re-implement logout inside the cubit*: rejected — duplicates logic, risks drift.
- *Add `PrefKeys.currentUser` removal in `ProfileCubit.logout()`*: rejected per Q4.

**Side-effect**: `AppLogout.logout()` itself throws on `if (!context.mounted) return;` only after navigation, so the cubit's try/catch covers Firebase sign-out failures from inside `AppLogout`. Confirmed by reading `lib/core/utils/app_logout.dart`.

## R-05 — Sub-screen routing

**Decision**: All four navigable tiles (Edit Profile, Account & Security, Notifications, Language) push `PageUnderBuildScreen` directly via `Navigator.push(MaterialPageRoute(...))`. No new constants in `AppRoutes`.

**Rationale**:

- Clarification answer Q5 = A.
- Adding route constants now would create dead code that ages poorly before the sub-features are designed.
- Existing default-case in `AppRoutes.onGenerateRoute` already returns `PageUnderBuildScreen` for unknown routes, but pushing directly avoids hitting the route generator at all.

**Alternatives considered**:

- *Add `editProfileInfo`, `accountSecurity`, etc. to `AppRoutes` now*: rejected — premature.
- *Push by route name with non-existent constants*: rejected — fragile string-typed coupling.

## R-06 — Screen mounting location

**Decision**: The screen mounts inside `MainScreen`'s body via the existing `NavBarEnum.settings` branch in `_buildBody`. The current `lib/screens/settings/profile.dart` is replaced.

**Rationale**:

- The bottom navigation already routes `NavBarEnum.settings` → `ProfileScreen()` (in `MainScreen`).
- The `MainAppBar` already shows the "Settings" title when `NavBarEnum.settings` is active.
- The screen must NOT include its own `Scaffold` or `AppBar`.

**Migration step**: In `main_screen.dart` swap:

```text
// before
import 'package:chat_material3/screens/settings/profile.dart';
// after
import 'package:chat_material3/features/profile/presentation/screens/profile_screen.dart';
```

The class name `ProfileScreen` is reused, so the call site (`return const ProfileScreen();`) does not change.

## R-07 — DI registration ordering

**Decision**: Add `_initProfile()` to `injection_container.dart` after `_initGroups()`. Register: `ProfileRemoteDataSource` → lazy singleton; `ProfileRepo` → lazy singleton; `ProfileCubit` → factory.

**Rationale**:

- `ProfileCubit` must be registered as `Factory` so each `BlocProvider` gets a fresh instance (matches groups feature).
- Repo and data source are stateless and can be lazy singletons.
- `DataBaseService` is already registered in `_initCore()` and is consumed by the new data source.

## R-08 — Localization JSON convention

**Decision**: Use snake_case for the JSON keys, camelCase for the `LangKeys` static constants (matches existing `editProfileInfo` → `'edit_profile_info'`).

**Rationale**:

- Confirmed by reading `lang_keys.dart` and `lang/en.json`: e.g., `LangKeys.welcomeBack = 'welcome_back'`.

## R-09 — Card / tile composition

**Decision**: Each section's two tiles share a single `Card` parent so the rounded corners and white background are continuous, with a 1-pixel divider between tiles. The logout tile gets its own dedicated `Card`.

**Rationale**:

- Matches the iOS Settings reference where grouped tiles sit in one rounded container.
- Reuses Flutter's `Card` defaults; no custom container required.

## R-10 — Test framework

**Decision**: `bloc_test` for cubit unit tests, `flutter_test` for widget tests. No integration tests in this iteration.

**Rationale**:

- Logout side-effects (Firebase + navigator) are hard to integration-test without a full e2e harness which is out of scope.
- Cubit + widget tests give adequate coverage for the spec's acceptance scenarios.
