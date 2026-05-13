# Tasks: Profile & Settings Screen

**Input**: Design documents from `specs/002-profile-settings-screen/`
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅

**User Stories**:
- US1 (P1): View Profile & Settings — render profile card + sections from local cache
- US2 (P2): Navigate to Profile Sub-Screens — all four tiles route to placeholder
- US3 (P3): Logout — full logout flow with loading / success / error states

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Localization strings, DI registration, and folder skeleton — blocks all user stories.

- [X] T001 Add 13 new constants to `lib/core/language/lang_keys.dart`
  - **Goal**: All profile screen labels available as `LangKeys.xxx` constants.
  - **Details**: Add `profile`, `editProfileInfo`, `editProfileSubtitle`, `accountSecurity`, `accountSecuritySubtitle`, `notifications`, `notificationsSubtitle`, `languageSubtitle`, `logout`, `logoutSubtitle`, `profileSection`, `appPreferences`, `loggedOutSuccessfully`. Note: `language` and `settings` already exist — do NOT duplicate them.
  - **Avoid**: Adding keys with values (that goes in JSON). `LangKeys` is string-constant-only.
  - **Acceptance**: Running `dart analyze` passes; each constant maps to the snake_case key matching `en.json`.

- [X] T002 [P] Add 13 English translation entries to `lang/en.json`
  - **Goal**: English strings available for all new `LangKeys` constants.
  - **Details**: `"profile": "Profile"`, `"edit_profile_info": "Edit Profile Info"`, `"edit_profile_subtitle": "Update your name, photo and bio"`, `"account_security": "Account & Security"`, `"account_security_subtitle": "Password, two-step verification"`, `"notifications": "Notifications"`, `"notifications_subtitle": "Manage notification preferences"`, `"language_subtitle": "Change app language"`, `"logout": "Logout"`, `"logout_subtitle": "Sign out of your account"`, `"profile_section": "PROFILE"`, `"app_preferences": "APP PREFERENCES"`, `"logged_out_successfully": "Logged out successfully"`.
  - **Avoid**: Duplicating the existing `"language"` or `"settings"` keys.
  - **Acceptance**: JSON parses without error; each key matches its `LangKeys` constant.

- [X] T003 [P] Add 13 Arabic translation entries to `lang/ar.json`
  - **Goal**: Arabic strings for all new `LangKeys` constants.
  - **Details**: `"profile": "الملف الشخصي"`, `"edit_profile_info": "تعديل معلومات الملف"`, `"edit_profile_subtitle": "تحديث الاسم والصورة والنبذة"`, `"account_security": "الحساب والأمان"`, `"account_security_subtitle": "كلمة المرور، التحقق بخطوتين"`, `"notifications": "الإشعارات"`, `"notifications_subtitle": "إدارة تفضيلات الإشعارات"`, `"language_subtitle": "تغيير لغة التطبيق"`, `"logout": "تسجيل الخروج"`, `"logout_subtitle": "الخروج من حسابك"`, `"profile_section": "الملف الشخصي"`, `"app_preferences": "تفضيلات التطبيق"`, `"logged_out_successfully": "تم تسجيل الخروج بنجاح"`.
  - **Avoid**: Duplicating existing Arabic keys already in the file.
  - **Acceptance**: JSON parses without error; same key set as `en.json`.

- [X] T004 Create `ProfileState` with Freezed in `lib/features/profile/presentation/bloc/profile_state.dart`
  - **Goal**: Typed sealed state union for the profile cubit covering all state variants.
  - **Details**: Use `@freezed` following the pattern in `create_group_state.dart`. States: `initial()`, `profileLoaded({required CurrentUserModel user})`, `logoutLoading()`, `logoutSuccess()`, `logoutError({required String message})`. File must be `part of 'profile_cubit.dart'`.
  - **Avoid**: Using `sealed class` without Freezed — this project uses Freezed for all cubits.
  - **Acceptance**: File is syntactically valid Dart; `part of` declaration matches cubit filename.

- [X] T005 Create `ProfileCubit` in `lib/features/profile/presentation/bloc/profile_cubit.dart`
  - **Goal**: Cubit that loads user from SharedPreferences, triggers background Firestore refresh, and handles logout.
  - **Details**:
    - Constructor: `ProfileCubit({required ProfileRemoteDataSource profileRemoteDataSource})`.
    - `void loadUser()`: reads SharedPreferences via `getCurrentUser()` in a try/catch (emit `profileLoaded(user)` on success; emit `profileLoaded` with a minimal `CurrentUserModel` built from `FirebaseAuth.instance.currentUser?.uid` if SharedPref throws); then call `_refreshFromFirestore()` unawaited.
    - `Future<void> _refreshFromFirestore()`: calls `profileRemoteDataSource.refreshCurrentUser()`; on non-null result emits `profileLoaded(refreshedUser)`; swallows exceptions silently.
    - `Future<void> logout()`: guard `if (state is _LogoutLoading) return;`; store last user locally before emitting `logoutLoading`; call `await AppLogout().logout()`; on success emit `logoutSuccess`; on catch emit `logoutError(message: e.toString())` then re-emit `profileLoaded(lastUser)`.
    - Run `dart pub run build_runner build --delete-conflicting-outputs` after this task.
  - **Avoid**: Calling `AppLogout().logout()` more than once; calling navigation from inside the cubit; importing Flutter widgets.
  - **Acceptance**: `flutter analyze` passes; generated `.freezed.dart` file exists.

- [X] T006 Create `ProfileRemoteDataSource` in `lib/features/profile/data/datasources/profile_remote_data_source.dart`
  - **Goal**: Thin data source that reloads Firebase user and returns a fresh `CurrentUserModel`.
  - **Details**:
    - Abstract interface: `abstract interface class ProfileRemoteDataSource { Future<CurrentUserModel?> refreshCurrentUser(); }`.
    - Implementation class `ProfileRemoteDataSourceImpl` with no constructor parameters:
      1. Call `await FirebaseAuth.instance.currentUser?.reload()`.
      2. Read `final user = FirebaseAuth.instance.currentUser;`.
      3. If `user == null` return `null`.
      4. Map: `final model = CurrentUserModel.fromFirebaseUser(user)`.
      5. Persist: `await SharedPref().setString(PrefKeys.currentUser, jsonEncode(model.toJson()))`.
      6. Return `model`.
  - **Avoid**: Direct Firestore document reads (FR-002 says Firebase Auth refresh is sufficient for this feature).
  - **Acceptance**: Class compiles; method signature matches interface.

- [X] T007 Register `ProfileRemoteDataSource` and `ProfileCubit` in `lib/core/di/injection_container.dart`
  - **Goal**: Both types available via `sl<>()` for use in `BlocProvider`.
  - **Details**: Add a new private function `Future<void> _initProfile()` and call it inside `setupInjector()` after `_initGroups()`. Register: `sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl())` then `sl.registerFactory<ProfileCubit>(() => ProfileCubit(profileRemoteDataSource: sl()))`.
  - **Avoid**: Using `registerLazySingleton` for `ProfileCubit` — it must be `registerFactory` so each tab visit gets a fresh instance with `loadUser()` called.
  - **Acceptance**: `flutter analyze` passes; no `GetIt` registration conflict at runtime.

**Checkpoint**: Localization, state, cubit, data source, and DI complete. User story implementation can begin.

---

## Phase 2: Foundational Widgets (Blocking Prerequisites)

**Purpose**: Reusable widgets required by multiple user stories. Must be done before any screen is assembled.

- [X] T008 [P] Create `ProfileSectionTitle` widget in `lib/features/profile/presentation/widgets/profile_section_title.dart`
  - **Goal**: Uppercase section header label reused between PROFILE and APP PREFERENCES sections.
  - **Details**: `StatelessWidget`, `const` constructor, single required `String title` param. Body: `Padding` (horizontal `16.w`, vertical `8.h`) wrapping `TextApp(text: title, theme: context.textStyle.copyWith(fontSize: 12.sp, color: context.color.grey, fontWeight: FontWeight.w600))`. No trailing widgets.
  - **Avoid**: Hardcoding the title string inside the widget; importing business logic.
  - **Acceptance**: Widget renders given any string; uses `ScreenUtil` for sizing; no hardcoded text.

- [X] T009 [P] Create `ProfileSettingTile` widget in `lib/features/profile/presentation/widgets/profile_setting_tile.dart`
  - **Goal**: Reusable settings row with icon, title, subtitle, and trailing arrow — used for all four settings tiles.
  - **Details**: `StatelessWidget`, `const` constructor. Required params: `IconData icon`, `String title`, `String subtitle`, `VoidCallback onTap`. Build: `ListTile(leading: Icon(icon, color: context.color.primary), title: TextApp(text: title, theme: context.textStyle), subtitle: TextApp(text: subtitle, theme: context.textStyle.copyWith(fontSize: 12.sp, color: context.color.grey)), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: onTap)` wrapped in an `InkWell` or use `ListTile.onTap` directly.
  - **Avoid**: Hardcoding title/subtitle strings; creating any object inside `build()`; using `Text` instead of `TextApp`.
  - **Acceptance**: Widget renders with all passed params; tapping triggers `onTap`; no hardcoded strings.

- [X] T010 [P] Create `ProfileLogoutTile` widget in `lib/features/profile/presentation/widgets/profile_logout_tile.dart`
  - **Goal**: Logout row styled in red/error color with a loading state that disables tap.
  - **Details**: `StatelessWidget`, `const` constructor. Required params: `VoidCallback onTap`, `bool isLoading`. Build: `ListTile(leading: Icon(Icons.logout, color: Colors.red), title: TextApp(text: /* title passed as param */, theme: context.textStyle.copyWith(color: Colors.red)), subtitle: TextApp(text: /* subtitle passed as param */, theme: context.textStyle.copyWith(fontSize: 12.sp, color: Colors.red.shade300)), trailing: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red), onTap: isLoading ? null : onTap)`. Pass `title` and `subtitle` as `String` constructor params for full reusability.
  - **Avoid**: Using `setState` inside this widget for any state; hardcoding logout text inside the widget.
  - **Acceptance**: When `isLoading: true` the tap is null and spinner shows; when `false` tap is active and arrow shows.

- [X] T011 [P] Create `ProfileUserCard` widget in `lib/features/profile/presentation/widgets/profile_user_card.dart`
  - **Goal**: Displays user avatar, display name, and email — top section of the settings screen.
  - **Details**: `StatelessWidget`, `const` constructor, required `CurrentUserModel user`. Avatar logic: if `user.photoUrl != null` use `CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!), radius: 40.r)`; else use `CircleAvatar(radius: 40.r, backgroundColor: context.color.primary.withOpacity(0.2), child: TextApp(text: _initials(user), theme: context.textStyle.copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold)))`. Private helper `String _initials(CurrentUserModel u)` returns first character of `u.name?.trim()` uppercased, or `"?"` if null/empty. Display name: `u.name ?? u.uid`. Email: `u.email ?? ""`. All text via `TextApp`.
  - **Avoid**: Creating any controller or animation inside `build()`; using plain `Text` instead of `TextApp`; crashing when `name`, `email`, and `photoUrl` are all null simultaneously.
  - **Acceptance**: Renders initials when `photoUrl` is null; renders `"?"` when both `photoUrl` and `name` are null; renders network image when `photoUrl` is provided; uses `ScreenUtil` for all dimensions.

**Checkpoint**: All four reusable widgets exist. Screen assembly can now begin.

---

## Phase 3: User Story 1 — View Profile & Settings (Priority: P1) 🎯 MVP

**Goal**: Logged-in user opens Settings tab and immediately sees their profile card and all settings sections rendered from local cache — no network spinner.

**Independent Test**: Navigate to the Settings tab; confirm the profile card shows name/email/avatar (or fallback), PROFILE section with two tiles, APP PREFERENCES section with two tiles, and logout tile are all visible — without any network request.

### Implementation for User Story 1

- [X] T012 [US1] Create `ProfileBody` widget in `lib/features/profile/presentation/refactor/profile_body.dart`
  - **Goal**: Assembles the full settings screen layout from the reusable widget building blocks.
  - **Details**: `StatelessWidget`, `const`, required `CurrentUserModel user`. Build: `SingleChildScrollView` → `Column` children:
    1. `ProfileUserCard(user: user)`
    2. `SizedBox(height: 16.h)`
    3. `ProfileSectionTitle(title: context.translate(LangKeys.profileSection))`
    4. `Card` containing `Column` with: `ProfileSettingTile(icon: Icons.person_outline, title: context.translate(LangKeys.editProfileInfo), subtitle: context.translate(LangKeys.editProfileSubtitle), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PageUnderBuildScreen())))` and a `Divider(height: 1)` then `ProfileSettingTile(icon: Icons.security_outlined, title: context.translate(LangKeys.accountSecurity), subtitle: context.translate(LangKeys.accountSecuritySubtitle), onTap: () => Navigator.push(...))`.
    5. `SizedBox(height: 12.h)`
    6. `ProfileSectionTitle(title: context.translate(LangKeys.appPreferences))`
    7. `Card` containing `Column` with Notifications tile + Divider + Language tile (same pattern).
    8. `SizedBox(height: 16.h)`
    9. `ProfileLogoutTile(title: context.translate(LangKeys.logout), subtitle: context.translate(LangKeys.logoutSubtitle), isLoading: false, onTap: () => context.read<ProfileCubit>().logout())`
    10. `SizedBox(height: 24.h)`
  - **Avoid**: Hardcoding any string; creating `TextEditingController` or any stateful object; nesting `Scaffold` inside.
  - **Acceptance**: Widget builds without errors; all strings go through `context.translate(LangKeys.xxx)`; layout scrollable.

- [X] T013 [US1] Create `ProfileBlocConsumer` widget in `lib/features/profile/presentation/widgets/profile_bloc_consumer.dart`
  - **Goal**: Bridges `ProfileCubit` state to the UI — handles logout side effects in the listener; renders body in the builder.
  - **Details**: `StatelessWidget`. Build: `BlocConsumer<ProfileCubit, ProfileState>(listener: (context, state) { state.whenOrNull(logoutSuccess: () { ShowToast.showToastSuccessTop(message: context.translate(LangKeys.loggedOutSuccessfully)); /* No navigation here — AppLogout already navigated */ }, logoutError: (message) => ShowToast.showToastErrorTop(message: message)); }, builder: (context, state) { return state.maybeWhen(profileLoaded: (user) => ProfileBody(user: user), logoutLoading: () => /* get last user from cubit and pass to ProfileBody, with isLoading:true on logout tile */ ..., orElse: () => const SizedBox.shrink()); })`.
  - **Notes on logout loading**: To keep the profile visible during logout, the cubit should store the last loaded user; the builder can call `context.read<ProfileCubit>().lastUser` (add a `CurrentUserModel? lastUser` field to `ProfileCubit`). Pass `isLoading: state is _LogoutLoading` to `ProfileBody` (add `bool isLogoutLoading` param to `ProfileBody` and thread it down to `ProfileLogoutTile`).
  - **Avoid**: Calling navigation after `logoutSuccess` — `AppLogout().logout()` already handles it; duplicating navigation causes back-stack corruption.
  - **Acceptance**: On `profileLoaded` the body renders; on `logoutLoading` the body remains visible with logout tile spinner; on `logoutSuccess` success toast appears; on `logoutError` error toast appears.

- [X] T014 [US1] Create `ProfileScreen` in `lib/features/profile/presentation/screens/profile_screen.dart`
  - **Goal**: Entry-point `StatelessWidget` that provides the cubit and triggers initial data load.
  - **Details**: `StatelessWidget`. Build: `BlocProvider<ProfileCubit>(create: (context) => sl<ProfileCubit>()..loadUser(), child: const ProfileBlocConsumer())`. No `Scaffold`, no `AppBar` — the screen lives inside `MainScreen` which provides both.
  - **Avoid**: Adding a `Scaffold` (would double-wrap with `MainScreen`'s scaffold); calling `loadUser()` anywhere except in `create`.
  - **Acceptance**: Screen renders inside Settings tab without double app-bar or nested scaffold; profile card appears immediately on tab tap.

- [X] T015 [US1] Swap legacy `ProfileScreen` import in `lib/features/main/presentation/screens/main_screen.dart`
  - **Goal**: `MainScreen` now uses the new feature-layer `ProfileScreen` instead of the old stub.
  - **Details**: Remove `import 'package:chat_material3/screens/settings/profile.dart';`. Add `import 'package:chat_material3/features/profile/presentation/screens/profile_screen.dart';`. The call site `return const ProfileScreen();` stays unchanged.
  - **Avoid**: Changing any other logic in `main_screen.dart`.
  - **Acceptance**: Hot restart; Settings tab renders the new profile screen without errors.

- [X] T016 [US1] Delete legacy stub `lib/screens/settings/profile.dart`
  - **Goal**: Remove the old `ProfileScreen` stub that is now replaced.
  - **Details**: Delete file. Verify no other file imports it (`grep -r "screens/settings/profile"` should return no results).
  - **Avoid**: Deleting other files in `lib/screens/settings/`.
  - **Acceptance**: `flutter analyze` reports no dangling imports; project compiles.

### Tests for User Story 1

- [ ] T017 [P] [US1] Widget test: `ProfileUserCard` null-safety in `test/features/profile/widgets/profile_user_card_test.dart`
  - **Goal**: Verify that `ProfileUserCard` never throws when fields are null.
  - **Details**: Three test cases: (1) all fields non-null — check avatar image shown; (2) `photoUrl` null, `name` set — check initials shown; (3) `photoUrl` null and `name` null — check `"?"` shown. Use `flutter_test`.
  - **Acceptance**: All three cases pass; no `Null check operator used on null value` exceptions.

- [ ] T018 [P] [US1] Widget test: `ProfileBody` uses localization for all strings in `test/features/profile/widgets/profile_body_test.dart`
  - **Goal**: Ensure no hardcoded strings are present; all section titles and tile labels pass through localization.
  - **Details**: Pump `ProfileBody` with a mock `CurrentUserModel`; verify `find.text` does NOT find raw English strings outside localization; verify `find.byType(TextApp)` finds at least 9 `TextApp` widgets.
  - **Acceptance**: Test passes; widget tree contains no plain `Text` widgets with hardcoded strings.

**Checkpoint**: User Story 1 complete — Settings tab renders profile card and all four section tiles from local cache.

---

## Phase 4: User Story 2 — Navigate to Profile Sub-Screens (Priority: P2)

**Goal**: Tapping each of the four settings tiles navigates without crashing. All route to `PageUnderBuildScreen` in this iteration.

**Independent Test**: Tap each of the four setting tiles in turn; confirm each navigates without crashing.

### Implementation for User Story 2

- [X] T019 [US2] Verify navigation routes for all four tiles in `lib/features/profile/presentation/refactor/profile_body.dart`
  - **Goal**: Confirm each tile's `onTap` pushes `PageUnderBuildScreen` correctly.
  - **Details**: In T012's `ProfileBody`, each of the four `ProfileSettingTile.onTap` callbacks should call `Navigator.push(context, MaterialPageRoute(builder: (_) => const PageUnderBuildScreen()))`. This task is a verification / fix pass — if T012 already implemented this correctly it is a quick confirm. If not, update each tile's `onTap`.
  - **Avoid**: Adding placeholder `AppRoutes` constants for sub-screens not yet designed; using `Navigator.pushNamed` with a non-existent route constant.
  - **Acceptance**: Each of the four tiles navigates to a screen that displays "Page Under Construction" text without exceptions.

### Tests for User Story 2

- [ ] T020 [P] [US2] Widget test: navigation tiles in `test/features/profile/widgets/profile_setting_tile_test.dart`
  - **Goal**: Confirm tapping `ProfileSettingTile` triggers the `onTap` callback.
  - **Details**: Pump `ProfileSettingTile` with a mock `onTap`; call `tester.tap(find.byType(ProfileSettingTile))`; verify the mock was called exactly once.
  - **Acceptance**: Test passes; tap registers correctly.

**Checkpoint**: User Story 2 complete — all four tiles navigate without crash.

---

## Phase 5: User Story 3 — Logout (Priority: P3)

**Goal**: Tapping the Logout tile invokes `AppLogout().logout()`, shows a loading spinner, shows a success toast, and lands on Login screen with no back-stack to main app.

**Independent Test**: Tap Logout; loading indicator appears; after completion user is on Login screen; back button does not return to main app.

### Implementation for User Story 3

- [X] T021 [US3] Update `ProfileBody` to accept and thread `isLogoutLoading` in `lib/features/profile/presentation/refactor/profile_body.dart`
  - **Goal**: `ProfileBody` needs to know whether logout is in progress so it can pass `isLoading` to `ProfileLogoutTile`.
  - **Details**: Add required `bool isLogoutLoading` param to `ProfileBody` constructor. Pass `isLoading: isLogoutLoading` to `ProfileLogoutTile`. The `ProfileBlocConsumer` builder already knows the state — pass `isLogoutLoading: state is _LogoutLoading` when constructing `ProfileBody`.
  - **Avoid**: Using `setState` to track loading in a widget; duplicating state from the cubit.
  - **Acceptance**: When `ProfileCubit` emits `logoutLoading`, the logout tile shows the spinner and tap is disabled; the rest of the screen remains interactive.

- [X] T022 [US3] Verify `AppLogout` clears SharedPreferences in `lib/core/utils/app_logout.dart`
  - **Goal**: Confirm `AppLogout.logout()` clears `PrefKeys.currentUser` (or at minimum all tokens). This feature does NOT add this logic — per clarification Q4 it is `AppLogout`'s responsibility.
  - **Details**: Read `app_logout.dart`. If `PrefKeys.currentUser` is NOT cleared there, add `await SharedPref().removePreference(PrefKeys.currentUser);` alongside the existing `removePreference` calls for `accessToken`, `userId`, and `userRole`. This is a one-line fix if needed.
  - **Avoid**: Adding this logic in `ProfileCubit` instead — it belongs in `AppLogout`.
  - **Acceptance**: After logout, `SharedPref().getString(PrefKeys.currentUser)` returns null.

### Tests for User Story 3

- [ ] T023 [P] [US3] Unit test: `ProfileCubit.logout()` success in `test/features/profile/bloc/profile_cubit_test.dart`
  - **Goal**: Verify state sequence `[logoutLoading, logoutSuccess]` on successful logout.
  - **Details**: Mock `AppLogout` using `mocktail`; mock `ProfileRemoteDataSource`. Use `bloc_test`'s `blocTest` helper: `act: (cubit) => cubit.logout()`, `expect: () => [isA<_LogoutLoading>(), isA<_LogoutSuccess>()]`.
  - **Avoid**: Testing internal `AppLogout` navigation in this unit test — only test state emission.
  - **Acceptance**: Test passes without hitting Firebase.

- [ ] T024 [P] [US3] Unit test: `ProfileCubit.logout()` error in `test/features/profile/bloc/profile_cubit_test.dart`
  - **Goal**: Verify state sequence `[logoutLoading, logoutError, profileLoaded]` when logout throws.
  - **Details**: Mock `AppLogout.logout()` to throw `Exception('network error')`. Verify states: `logoutLoading` → `logoutError(message: 'Exception: network error')` → `profileLoaded(user)`.
  - **Acceptance**: Test passes; after error the last known user is re-emitted in `profileLoaded`.

- [ ] T025 [P] [US3] Unit test: duplicate logout is no-op in `test/features/profile/bloc/profile_cubit_test.dart`
  - **Goal**: Verify calling `logout()` while already in `logoutLoading` state emits no additional states.
  - **Details**: Emit `logoutLoading` manually; call `cubit.logout()` a second time; verify no extra states emitted.
  - **Acceptance**: Test passes; only one set of logout state transitions fires.

**Checkpoint**: All three user stories complete. Profile screen is fully functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T026 Polish `ProfileUserCard` spacing and sizing in `lib/features/profile/presentation/widgets/profile_user_card.dart`
  - **Goal**: Match the reference visual: centered avatar, name below, email below name, adequate vertical padding.
  - **Details**: Use `ScreenUtil` (`r`, `w`, `h`, `sp`) for all sizes; no hardcoded pixel values. Wrap card in `Container` with `Padding(padding: EdgeInsets.all(24.w))`. Center the avatar with `Column(crossAxisAlignment: CrossAxisAlignment.center)`. Name: `fontSize: 18.sp, fontWeight: FontWeight.bold`. Email: `fontSize: 14.sp, color: context.color.grey`.
  - **Avoid**: Using raw double literals like `EdgeInsets.all(24.0)`; mixing `ScreenUtil` and raw values.
  - **Acceptance**: Visual matches reference image; no pixel overflow on small screens.

- [X] T027 [P] Polish section card grouping and elevation in `lib/features/profile/presentation/refactor/profile_body.dart`
  - **Goal**: Each section's tiles share a single `Card` with rounded corners, and a `Divider` between tiles.
  - **Details**: Wrap each group of two tiles in `Card(margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)))`. Add `const Divider(height: 1, indent: 16, endIndent: 16)` between the two tiles inside each card. Logout tile gets its own card with the same shape.
  - **Acceptance**: Visual matches reference; cards have uniform rounding; dividers are subtle.

- [ ] T028 Cleanup imports and run `dart fix` across new files
  - **Goal**: No unused imports, consistent formatting, no `dart analyze` warnings.
  - **Details**: Run `dart fix --apply` and `dart format lib/features/profile/` from repo root. Remove any unused imports. Confirm no `// ignore:` directives were added as shortcuts.
  - **Acceptance**: `flutter analyze` exits with 0 issues in the profile feature folder.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately. T002 and T003 can run in parallel; T001 must precede T004/T005 since `LangKeys` constants are referenced in the cubit's tests.
- **Phase 2 (Foundational Widgets)**: Depends on Phase 1 completion. T008, T009, T010, T011 can all run in parallel.
- **Phase 3 (US1)**: Depends on Phase 1 + Phase 2. T012–T016 must run in order (body → consumer → screen → wire → delete). T017/T018 can run in parallel after T012.
- **Phase 4 (US2)**: Depends on Phase 3 completion (needs `ProfileBody` to exist). T019 is a fast verification pass.
- **Phase 5 (US3)**: Depends on Phase 3 (needs `ProfileBody` + `ProfileBlocConsumer`). T021 is a body update; T022–T025 can run after T021.
- **Phase 6 (Polish)**: Depends on all stories being complete.

### Within-Phase Parallel Opportunities

```
Phase 1:   T001 → (T002 [P], T003 [P]) → T004 → T005 → T006 → T007
Phase 2:   (T008 [P], T009 [P], T010 [P], T011 [P])
Phase 3:   T012 → T013 → T014 → T015 → T016, and (T017 [P], T018 [P])
Phase 4:   T019, T020 [P]
Phase 5:   T021 → T022, (T023 [P], T024 [P], T025 [P])
Phase 6:   (T026, T027 [P]) → T028
```

---

## Mistakes to Avoid (Referenced Per Task)

| Mistake | Relevant Tasks | Consequence |
|---|---|---|
| Creating `TextEditingController` inside `build()` | T011–T014 | Recreated every frame; causes memory leaks and UI glitches |
| Hardcoded label strings instead of `context.translate(LangKeys.xxx)` | T008–T014 | Fails SC-004; strings break under locale changes |
| Using `Text` instead of `TextApp` | T008–T014 | Inconsistent typography; breaks theming |
| Not clearing `PrefKeys.currentUser` on logout | T022 | Stale user displayed on next login |
| Calling navigation after `logoutSuccess` in BlocConsumer listener | T013 | `AppLogout` already navigated; double call corrupts back-stack |
| Using `registerLazySingleton` for `ProfileCubit` | T007 | Cubit is shared across navigation, `loadUser()` only fires once |
| Ignoring null `name` / `email` / `photoUrl` | T011, T017 | Runtime null-dereference crash on SC-005 validation |
| Adding a new `LogoutCubit` instead of using `ProfileCubit` | T005 | Unnecessary cubit; coordination overhead; violates project conventions |

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Complete Phase 1 (T001–T007)
2. Complete Phase 2 (T008–T011)
3. Complete Phase 3 (T012–T018)
4. **STOP and VALIDATE**: Settings tab renders profile + all tiles from local cache
5. Ship MVP — user can see their profile

### Incremental Delivery

1. Phase 1 + 2 + 3 → MVP: profile card visible ✅
2. Phase 4 → All tiles navigate without crash ✅
3. Phase 5 → Full logout flow ✅
4. Phase 6 → Polished UI ✅

---

## Summary

| Phase | Story | Tasks | Parallel? |
|---|---|---|---|
| Phase 1: Setup | — | T001–T007 | T002, T003 |
| Phase 2: Widgets | — | T008–T011 | All four |
| Phase 3: US1 View Profile | P1 🎯 | T012–T018 | T017, T018 |
| Phase 4: US2 Navigation | P2 | T019–T020 | T020 |
| Phase 5: US3 Logout | P3 | T021–T025 | T023–T025 |
| Phase 6: Polish | — | T026–T028 | T026, T027 |
| **Total** | | **28 tasks** | |

