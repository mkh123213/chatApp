# Implementation Plan: Profile & Settings Screen

**Branch**: `002-profile-settings-screen` | **Date**: 2026-05-05 | **Spec**: `specs/002-profile-settings-screen/spec.md`

## Summary

Replace the legacy `lib/screens/settings/profile.dart` stub with a fully-featured Profile / Settings screen that reads user data from `SharedPreferences` on first render, silently refreshes from Firestore in the background, presents two sections of navigable settings tiles (all routed to `PageUnderBuildScreen`), and provides a themed Logout tile that calls `AppLogout().logout()` with loading / success / error state feedback.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `get_it`, `freezed_annotation`, `shared_preferences`, `firebase_auth`, `cloud_firestore`, `flutter_screenutil`  
**Storage**: SharedPreferences (primary read), Firestore (background refresh)  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`  
**Target Platform**: Android / iOS (existing app)  
**Project Type**: Mobile app — feature screen inside bottom navigation  
**Performance Goals**: Profile card renders < 200 ms from local storage; no blocking spinner  
**Constraints**: No Freezed `build_runner` — wait, the project ALREADY uses Freezed (see `create_group_cubit.freezed.dart`). Freezed IS permitted in this project; CLAUDE.md restriction on code generation is overridden by existing project convention.  
**Scale/Scope**: Single feature screen; 7 new files, ~13 new LangKeys

---

## Constitution Check

Constitution file is a blank template — no project-specific gates are defined. The CLAUDE.md rules apply instead.

| Rule | Status |
|------|--------|
| Presentation → Domain → Data layers respected | ✅ — screen reads SharedPreferences via `getCurrentUser()` helper; Firestore refresh is a separate use case |
| No business logic in UI | ✅ — logout and refresh live in `ProfileCubit` |
| Cubit depends only on use cases / services, not repositories directly | ✅ — `ProfileCubit` calls `AppLogout()` (service) and `FirebaseAuth`/Firestore via injected service |
| Freezed used (existing convention) | ✅ — `ProfileState` uses `@freezed` matching existing cubits |
| `setState` scoped to local UI only | ✅ — no `setState` needed; all state via Cubit |
| No new packages without justification | ✅ — all dependencies already present |
| `const` constructors, no expensive objects in `build()` | ✅ — required in widget designs below |
| All strings via `LangKeys` / `context.translate` | ✅ — 13 new keys defined below |

---

## Project Structure

### Documentation (this feature)

```text
specs/002-profile-settings-screen/
├── plan.md          ← this file
├── research.md      ← Phase 0 output
├── data-model.md    ← Phase 1 output
└── tasks.md         ← Phase 2 output (/speckit-tasks)
```

### Source Code

```text
lib/
├── core/
│   └── language/
│       └── lang_keys.dart              ← add 13 new constants
├── lang/
│   ├── en.json                         ← add 13 new entries
│   └── ar.json                         ← add 13 Arabic entries
└── features/
    └── profile/
        ├── presentation/
        │   ├── bloc/
        │   │   ├── profile_cubit.dart
        │   │   ├── profile_state.dart
        │   │   └── profile_cubit.freezed.dart  (generated)
        │   ├── screens/
        │   │   └── profile_screen.dart
        │   ├── refactor/
        │   │   └── profile_body.dart
        │   └── widgets/
        │       ├── profile_user_card.dart
        │       ├── profile_section_title.dart
        │       ├── profile_setting_tile.dart
        │       ├── profile_logout_tile.dart
        │       └── profile_bloc_consumer.dart
        └── data/
            └── datasources/
                └── profile_remote_data_source.dart
```

**Migration note**: `lib/screens/settings/profile.dart` (legacy stub) will be **deleted** after the new `ProfileScreen` is wired in `main_screen.dart`.

---

## Phase 0: Research

### Decision: ProfileCubit — is it needed?

**Decision**: Yes — `ProfileCubit` is required.

**Rationale**:
- Logout is async and has 3 states (loading / success / error) that must be reflected in the UI without using `setState` at the screen level (CLAUDE.md rule).
- The background Firestore refresh needs to propagate a state change (`profileLoaded`) to update `ProfileUserCard` after the initial render.
- Without a Cubit the screen would need `setState` or mix async logic into the widget tree — both violate project rules.

**Alternatives rejected**:
- Pure `setState` inside `StatefulWidget` — violates "no business logic in UI" rule.
- `FutureBuilder` for logout — no way to cleanly represent the loading indicator on the tile without leaking state into the widget.

---

### Decision: Firestore refresh approach

**Decision**: Call `FirebaseAuth.instance.currentUser?.reload()` then re-read `FirebaseAuth.instance.currentUser` to get a fresh `User` object, convert to `CurrentUserModel`, update SharedPreferences cache, and emit `profileLoaded` with the refreshed model.

**Rationale**: `AuthService` (Firebase) is already registered in `get_it`. No new repository or data source is strictly necessary for a simple field refresh. However, to keep `ProfileCubit` free of direct Firebase imports (domain-layer purity), a thin `ProfileRemoteDataSource` is introduced.

**Alternatives rejected**:
- Direct Firestore document read in the cubit — adds Firebase dependency to the presentation layer.
- Skipping the update of SharedPreferences after refresh — next cold start would show stale data.

---

### Decision: Avatar fallback

**Decision**: Use a `CircleAvatar` with a `backgroundColor` derived from the user's UID hash (so the color is stable per user), showing the first letter of `name` or `"?"` as the child `Text`.

**Rationale**: Matches clarification answer; stable color prevents flicker on hot-reload. If `photoUrl` is non-null, use `CachedNetworkImage` (already in pubspec) as the `backgroundImage`.

---

## Phase 1: Design & Contracts

### data-model.md (inline)

#### ProfileState (Freezed union)

```dart
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial()                              = _Initial;
  const factory ProfileState.profileLoaded({
    required CurrentUserModel user,
  })                                                                = _ProfileLoaded;
  const factory ProfileState.logoutLoading()                        = _LogoutLoading;
  const factory ProfileState.logoutSuccess()                        = _LogoutSuccess;
  const factory ProfileState.logoutError({ required String message }) = _LogoutError;
}
```

State transitions:
1. Screen opens → cubit reads SharedPreferences → emits `profileLoaded(user)` synchronously before first frame.
2. Cubit fires background refresh → on success emits `profileLoaded(user)` again (UI updates silently).
3. Logout tapped → emits `logoutLoading` → on success emits `logoutSuccess` → `BlocConsumer` listener navigates + shows toast.
4. Logout fails → emits `logoutError(message)` → listener shows error toast; state falls back to `profileLoaded`.

#### ProfileCubit methods

| Method | Signature | Description |
|---|---|---|
| `loadUser` | `void loadUser()` | Reads SharedPreferences synchronously, emits `profileLoaded`, then fires async background refresh |
| `_refreshFromFirestore` | `Future<void> _refreshFromFirestore()` | Private; reads `FirebaseAuth.currentUser`, updates SP, re-emits `profileLoaded` |
| `logout` | `Future<void> logout()` | Emits `logoutLoading`, calls `AppLogout().logout()`, emits `logoutSuccess` or `logoutError` |

#### ProfileRemoteDataSource

Single method:
```dart
abstract interface class ProfileRemoteDataSource {
  Future<CurrentUserModel?> refreshCurrentUser();
}
```

Implementation reads from `FirebaseAuth.instance.currentUser` (already authenticated), maps to `CurrentUserModel`, and writes updated JSON to `SharedPref`.

---

### Widget Contracts

#### `ProfileScreen` (`profile_screen.dart`)
- `StatelessWidget`
- Provides `BlocProvider<ProfileCubit>` via `sl<ProfileCubit>()`
- Calls `context.read<ProfileCubit>().loadUser()` inside `BlocProvider.create`
- Child: `ProfileBlocConsumer`

#### `ProfileBlocConsumer` (`profile_bloc_consumer.dart`)
- `StatelessWidget`
- Wraps `BlocConsumer<ProfileCubit, ProfileState>`
- **listener**: handles `logoutSuccess` (ShowToast + `pushNamedAndRemoveUntil`) and `logoutError` (ShowToast error)
- **builder**: returns `ProfileBody` when state is `profileLoaded` or `logoutLoading`; shows `CircularProgressIndicator` for `logoutLoading` overlay (or disable logout tile)

#### `ProfileBody` (`profile_body.dart`)
- `StatelessWidget`, receives `CurrentUserModel user`
- Layout: `SingleChildScrollView` → `Column`:
  1. `ProfileUserCard(user: user)`
  2. `ProfileSectionTitle(title: context.translate(LangKeys.profileSection))`
  3. `ProfileSettingTile` × 2 (Edit Profile Info, Account & Security)
  4. `ProfileSectionTitle(title: context.translate(LangKeys.appPreferences))`
  5. `ProfileSettingTile` × 2 (Notifications, Language)
  6. `ProfileLogoutTile`

#### `ProfileUserCard` (`profile_user_card.dart`)
- `StatelessWidget`, `const` constructor, receives `CurrentUserModel user`
- Avatar: `CircleAvatar` with `backgroundImage: NetworkImage(user.photoUrl)` when non-null; else child `Text(initials)` with stable `backgroundColor`
- Initials helper: extract first character of `user.name`; fallback to `"?"` if null
- Display name: `user.name ?? user.uid`
- Email: `user.email ?? ""`
- Uses `TextApp` for all text; `ScreenUtil` for sizing

#### `ProfileSectionTitle` (`profile_section_title.dart`)
- `StatelessWidget`, `const`, receives `String title`
- Renders an uppercase label styled with `context.textStyle` (small, muted) and horizontal `Padding`

#### `ProfileSettingTile` (`profile_setting_tile.dart`)
- `StatelessWidget`, `const`
- Required params: `IconData icon`, `String title`, `String subtitle`, `VoidCallback onTap`
- Trailing: `Icon(Icons.arrow_forward_ios)`; leading: `Icon(icon)` in `context.color.primary`-tinted container
- Uses `ListTile` wrapped in `InkWell` or uses `ListTile.onTap`

#### `ProfileLogoutTile` (`profile_logout_tile.dart`)
- `StatelessWidget`, receives `VoidCallback onTap`, `bool isLoading`
- When `isLoading == true`: show `CircularProgressIndicator` in place of the arrow icon; disable tap
- Icon and text color: `Colors.red` (or `context.color.error`)
- Leading icon: `Icons.logout` (or similar)
- Title: `context.translate(LangKeys.logout)`
- Subtitle: `context.translate(LangKeys.logoutSubtitle)`

---

### Navigation Contracts

| Tile | Route |
|---|---|
| Edit Profile Info | `context.pushNamed(AppRoutes.underBuild)` (or default case) |
| Account & Security | same |
| Notifications | same |
| Language | same |

All four use `Navigator.pushNamed(context, AppRoutes.underBuild)` — the default case in `AppRoutes.onGenerateRoute` already returns `PageUnderBuildScreen`.

**Wiring in `main_screen.dart`**: The existing `NavBarEnum.settings` branch already renders `ProfileScreen` (old stub import). Change the import to the new `features/profile/presentation/screens/profile_screen.dart`. No other routing change needed.

---

### DI Registration

Add `_initProfile()` call in `setupInjector()`:

```dart
Future<void> _initProfile() async {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(profileRemoteDataSource: sl()),
    );
}
```

---

### Localization Keys & JSON Entries

#### `lang_keys.dart` additions

```dart
static const String profile             = 'profile';
static const String editProfileInfo     = 'edit_profile_info';
static const String editProfileSubtitle = 'edit_profile_subtitle';
static const String accountSecurity     = 'account_security';
static const String accountSecuritySubtitle = 'account_security_subtitle';
static const String notifications       = 'notifications';
static const String notificationsSubtitle = 'notifications_subtitle';
static const String languageSubtitle    = 'language_subtitle';
static const String logout              = 'logout';
static const String logoutSubtitle      = 'logout_subtitle';
static const String profileSection      = 'profile_section';
static const String appPreferences      = 'app_preferences';
static const String loggedOutSuccessfully = 'logged_out_successfully';
```

Note: `language` and `settings` already exist in `LangKeys`.

#### `lang/en.json` additions

```json
"profile":                   "Profile",
"edit_profile_info":         "Edit Profile Info",
"edit_profile_subtitle":     "Update your name, photo and bio",
"account_security":          "Account & Security",
"account_security_subtitle": "Password, two-step verification",
"notifications":             "Notifications",
"notifications_subtitle":    "Manage notification preferences",
"language_subtitle":         "Change app language",
"logout":                    "Logout",
"logout_subtitle":           "Sign out of your account",
"profile_section":           "PROFILE",
"app_preferences":           "APP PREFERENCES",
"logged_out_successfully":   "Logged out successfully"
```

#### `lang/ar.json` additions (Arabic)

```json
"profile":                   "الملف الشخصي",
"edit_profile_info":         "تعديل معلومات الملف",
"edit_profile_subtitle":     "تحديث الاسم والصورة والنبذة",
"account_security":          "الحساب والأمان",
"account_security_subtitle": "كلمة المرور، التحقق بخطوتين",
"notifications":             "الإشعارات",
"notifications_subtitle":    "إدارة تفضيلات الإشعارات",
"language_subtitle":         "تغيير لغة التطبيق",
"logout":                    "تسجيل الخروج",
"logout_subtitle":           "الخروج من حسابك",
"profile_section":           "الملف الشخصي",
"app_preferences":           "تفضيلات التطبيق",
"logged_out_successfully":   "تم تسجيل الخروج بنجاح"
```

---

## Logout Flow (Detailed)

1. User taps `ProfileLogoutTile`.
2. `ProfileBlocConsumer` calls `context.read<ProfileCubit>().logout()`.
3. Cubit checks current state — if already `logoutLoading`, return early (prevents duplicate requests).
4. Emits `logoutLoading`.
5. `ProfileLogoutTile` rebuilds with `isLoading: true` — arrow icon replaced by `CircularProgressIndicator`; tap disabled.
6. `await AppLogout().logout()` is called.
7. On success: emit `logoutSuccess`.
   - `BlocConsumer` listener fires: `ShowToast.showToastSuccessTop(message: context.translate(LangKeys.loggedOutSuccessfully))` then `AppLogout().logout()` has already navigated to login, so no additional navigation needed.
   - **Important**: `AppLogout().logout()` already calls `context.pushNamedAndRemoveUntil(AppRoutes.logIn)`. Do NOT call navigation again in the listener.
8. On error (exception): emit `logoutError(message: e.toString())`.
   - Listener fires: `ShowToast.showToastErrorTop(message: message)`.
   - State returns to `profileLoaded` (re-emit last user).

---

## Loading / Error / Success State Handling

| State | UI behaviour |
|---|---|
| `initial` | Invisible — `loadUser()` runs synchronously in `create`, so `initial` is never seen |
| `profileLoaded` | `ProfileBody` renders immediately with user data |
| `logoutLoading` | `ProfileLogoutTile` shows spinner, tile is disabled; rest of UI is unchanged |
| `logoutSuccess` | Listener shows success toast + `AppLogout` navigates to login (already handled inside `AppLogout`) |
| `logoutError` | Listener shows error toast; builder re-renders with last `profileLoaded` state |

The builder must guard against `logoutError` by storing the last user in the cubit and re-emitting `profileLoaded(lastUser)` after error.

---

## Common Mistakes to Avoid

1. **Calling navigation in the listener after `logoutSuccess`** — `AppLogout().logout()` already handles navigation. A second `pushNamedAndRemoveUntil` would crash or produce unpredictable back-stack behavior.

2. **Creating `TextEditingController` or other objects inside `build()`** — none are needed in this screen; if added later, always use `StatefulWidget` + `dispose()`.

3. **Using `getCurrentUser()` (throws on null) instead of a safe SharedPreferences read** — `getCurrentUser()` throws if the key is missing. `ProfileCubit.loadUser()` must wrap the call in try/catch and handle a missing model gracefully (e.g., emit a partially-populated `CurrentUserModel` with only the UID from `FirebaseAuth`).

4. **Listening to `logoutLoading` in the builder and replacing the whole screen with a spinner** — only the logout tile spinner should change; the profile card and settings tiles must remain visible.

5. **Hardcoding any string in a widget** — every visible string must go through `context.translate(LangKeys.xxx)`.

6. **Triggering the background Firestore refresh synchronously in `loadUser()`** — it must be `unawaited` (fire-and-forget) after the synchronous SharedPreferences read so it never blocks the first render.

7. **Registering `ProfileCubit` as a `LazySingleton`** — it must be `registerFactory` so each navigation to the Settings tab gets a fresh cubit with `loadUser()` called in `create`.

8. **Forgetting to run `flutter pub run build_runner build` after adding the Freezed `ProfileState`** — without the generated `.freezed.dart` file the cubit won't compile.

---

## Testing Checklist

### Unit tests (`test/features/profile/bloc/`)

- [ ] `loadUser` emits `profileLoaded` when SharedPreferences has valid JSON
- [ ] `loadUser` does not throw when SharedPreferences key is missing; emits `profileLoaded` with a fallback model
- [ ] `logout` emits `[logoutLoading, logoutSuccess]` on `AppLogout().logout()` success (mock `AppLogout`)
- [ ] `logout` emits `[logoutLoading, logoutError]` on `AppLogout().logout()` exception
- [ ] Second `logout()` call while `logoutLoading` is active is a no-op

### Widget tests (`test/features/profile/widgets/`)

- [ ] `ProfileUserCard` renders initials when `photoUrl` is null and `name` is set
- [ ] `ProfileUserCard` renders `"?"` when both `photoUrl` and `name` are null
- [ ] `ProfileLogoutTile` shows `CircularProgressIndicator` when `isLoading: true`
- [ ] `ProfileLogoutTile` tap is disabled when `isLoading: true`
- [ ] `ProfileSettingTile` navigates to `PageUnderBuildScreen` on tap (all four tiles)

### Integration / smoke tests

- [ ] Navigate to Settings tab → profile card shows cached user without network
- [ ] Tap Logout → loading indicator appears → navigate to Login; back button cannot return to main app
- [ ] Simulate Firestore refresh returning different name → profile card updates without full reload
- [ ] All four settings tiles tap without crash
