# Tasks: Sign Up Screen

**Input**: Design documents from `specs/007-signup-screen/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Localization & Infrastructure)

**Purpose**: Add missing localization keys needed by the sign-up form

- [x] T001 [P] Add localization keys `nameCannotBeEmpty`, `accountCreatedSuccessfully`, `createAccount` to `lib/core/language/lang_keys.dart`
- [x] T002 [P] Add English translations for new keys in `lang/en.json`
- [x] T003 [P] Add Arabic translations for new keys in `lang/ar.json`

---

## Phase 2: Foundational (AuthCubit Enhancement)

**Purpose**: Enhance the sign-up method so it persists full user profile — MUST complete before UI work

**⚠️ CRITICAL**: UI tasks depend on this

- [x] T004 Enhance `createUserWithEmailAndPassword` in `lib/core/app/auth_cubit/auth_cubit.dart` to accept `name`, `phone`, `photoUrl` parameters and after account creation: call `authService.updateUserName`, build `CurrentUserModel`, save to Firestore `users/{uid}` and SharedPreferences, start `UserPresenceService`, save FCM token (mirror the `signInWithEmailAndPassword` flow)

**Checkpoint**: AuthCubit now handles full sign-up with profile persistence

---

## Phase 3: User Story 1 - Complete Account Registration (Priority: P1) 🎯 MVP

**Goal**: User can register with name, email, phone, password, optional avatar and land on home screen

**Independent Test**: Navigate to sign-up from login, fill all fields, submit, verify account created and navigated to main screen

### Implementation for User Story 1

- [x] T005 [P] [US1] Create `lib/features/auth/presentation/screens/sign_up_screen.dart` — StatefulWidget with controllers for name, email, phone, password, confirmPassword; dispose all controllers; layout mirrors `LoginScreen`
- [x] T006 [P] [US1] Create `lib/features/auth/presentation/widgets/sign_up/sign_up_bloc_consumer.dart` — BlocConsumer<AuthCubit, AuthState>: on `authenticated` navigate to `AppRoutes.mainScreen` with success toast, on `error` show error toast, on `loading` show CircularProgressIndicator, default show CustomLinearButton with `context.translate(LangKeys.createAccount)` text
- [x] T007 [US1] Create `lib/features/auth/presentation/widgets/sign_up/sign_up_form.dart` — SingleChildScrollView > Padding(20) > Form > Column with: UserAvatarImage (wrapped in BlocProvider<UploadImageCubit>), title text, 5 CustomTextField widgets (name/email/phone/password/confirmPassword) with Iconsax icons and validators using AppRegex, password visibility toggle, SignUpBlocConsumer, "Already have account? Login" CustomLinearButton. Use `context.color`, `context.translate` for all text/colors
- [x] T008 [US1] Wire sign-up route in `lib/core/routes/app_routes.dart` — uncomment the `signUp` case, provide `MultiBlocProvider` with `AuthCubit` and `UploadImageCubit`, point to `SignUpScreen`

**Checkpoint**: Full registration flow works end-to-end with profile data saved

---

## Phase 4: User Story 2 - Form Validation Feedback (Priority: P2)

**Goal**: Invalid input shows clear field-level error messages

**Independent Test**: Submit form with various invalid inputs, verify each field shows correct localized error

- [x] T009 [US2] Verify and refine all validators in `sign_up_form.dart`: email → `AppRegex.isEmailValid` / `LangKeys.invalidEmail`, password → `AppRegex.isPasswordValid` / `LangKeys.invalidPassword`, confirm password → match check / `LangKeys.passwordsDoNotMatch`, phone → `AppRegex.isPhoneValid` / `LangKeys.invalidPhoneNumber`, name → non-empty / `LangKeys.nameCannotBeEmpty`. Ensure empty-field submission shows all errors simultaneously

**Checkpoint**: All validation messages display correctly in both Arabic and English

---

## Phase 5: User Story 3 - Optional Profile Image (Priority: P3)

**Goal**: Registration succeeds with or without a profile image

**Independent Test**: Register without uploading image, verify account created with default avatar; register with image, verify photoUrl saved

- [x] T010 [US3] In `sign_up_bloc_consumer.dart`, read `UploadImageCubit.getImageUrl` before calling `createUserWithEmailAndPassword` and pass it as `photoUrl` parameter (empty string if no image uploaded)

**Checkpoint**: All 3 user stories independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T011 Test full flow on device: sign up → verify Firestore document → verify SharedPref → verify navigation to main screen → sign out → sign in with same credentials
- [ ] T012 Test RTL layout and Arabic translations on sign-up screen

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — T001, T002, T003 all parallel
- **Phase 2 (Foundational)**: No dependency on Phase 1 — can run in parallel with it
- **Phase 3 (US1)**: Depends on Phase 1 + Phase 2 completion
- **Phase 4 (US2)**: Depends on Phase 3 (validates form from US1)
- **Phase 5 (US3)**: Depends on Phase 3 (adds image URL passing to existing form)
- **Phase 6 (Polish)**: Depends on all previous phases

### Parallel Opportunities

```
T001 + T002 + T003 (all parallel — different files)
T004 can run parallel with T001-T003 (different file)
T005 + T006 (parallel — different files, both needed by T007)
T007 depends on T005, T006
T008 can run parallel with T007 (different file)
```

---

## Implementation Strategy

### MVP (User Story 1 Only)

1. Complete T001-T003 (lang keys) + T004 (AuthCubit) — in parallel
2. Complete T005 + T006 (screen + bloc consumer) — in parallel
3. Complete T007 (form) → T008 (route)
4. **STOP and VALIDATE**: Test registration end-to-end

### Full Feature

5. T009 (validation polish)
6. T010 (image URL wiring)
7. T011-T012 (testing)

---

## Notes

- No new models, states, or services needed — all infrastructure exists
- No build_runner needed — no freezed changes
- 12 total tasks, intentionally small and granular per user request
