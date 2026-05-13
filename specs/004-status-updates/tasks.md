# Tasks: Status / Updates

**Feature Branch**: `004-status-updates` | **Date**: 2026-05-07
**Input**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

> Task format follows the user-supplied template:
> ```
> - [ ] TXXX: Task title
>   - Goal:
>   - Files:
>   - Details:
>   - Acceptance criteria:
> ```
> Story labels (`[US1]`..`[US5]`) map to spec.md user stories. `[P]` = parallelizable with other `[P]` tasks in the same phase.

---

## User Story → Priority Mapping

| Label | Story | Priority |
|-------|-------|----------|
| US1   | Create Image Status | P1 |
| US2   | Create Text Status | P2 |
| US3   | View Active Statuses | P1 |
| US4   | View Status in Full-Screen Viewer | P2 |
| US5   | My Status Card and Delete Own Status | P2 |

---

## Phase 1 — Setup

- [X] T001: Create feature folder structure
  - Goal: Establish empty folders so subsequent tasks can drop files in.
  - Files: `lib/features/status/data/datasources/`, `lib/features/status/data/models/`, `lib/features/status/data/repositories/`, `lib/features/status/presentation/bloc/status_cubit/`, `lib/features/status/presentation/bloc/create_status_cubit/`, `lib/features/status/presentation/bloc/my_status_cubit/`, `lib/features/status/presentation/screens/`, `lib/features/status/presentation/widgets/`
  - Details: Create directories only; commit a `.gitkeep` if needed.
  - Acceptance criteria: All folders exist on `004-status-updates` branch; `flutter analyze` still passes.

- [X] T002: Firestore and storage constants
  - Goal: Centralize collection name and storage bucket/path prefix to avoid magic strings.
  - Files: `lib/constants/fierstore_paths.dart`
  - Details: Add `static const statuses = 'statuses';` to the Firestore paths constants class. Add `static const statusBucket = 'chatapp';` and `static const statusFolder = 'statuses';` (reusing the existing bucket per `research.md` R-003).
  - Acceptance criteria: New constants are referenced from the data source — zero literal `'statuses'` strings outside the constants file.

---

## Phase 2 — Foundational (blocking prerequisites)

- [ ] T003: StatusModel
  - Goal: Define the canonical Status data model with json_serializable + Timestamp converter.
  - Files: `lib/features/status/data/models/status_model.dart`
  - Details: `@JsonSerializable(explicitToJson: true)` plain Dart class with all fields from `data-model.md`. Add `_dateTimeFromJson` / `_dateTimeToJson` helpers handling both `Timestamp` and ISO string. Add helpers `isExpired`, `isImage`, `isText`, `isViewedBy(uid)`. Add `static const typeImage = 'image'; static const typeText = 'text';`. Constructor uses required named params; nullable for `mediaUrl`/`storagePath`/`text`/`backgroundColor`/`userPhotoUrl`. Provide manual `copyWith` (no Freezed for models).
  - Acceptance criteria: `StatusModel.fromJson(toJson(...))` round-trips for both image and text variants.

- [ ] T004: Run build_runner for json_serializable (StatusModel)
  - Goal: Generate `status_model.g.dart`.
  - Files: `lib/features/status/data/models/status_model.g.dart` (generated)
  - Details: Run `dart run build_runner build --delete-conflicting-outputs`.
  - Acceptance criteria: Generated file exists; `flutter analyze` is clean.

- [ ] T005: SupabaseStorageService status upload helper
  - Goal: Add a typed method for uploading status images and removing them.
  - Files: `lib/core/service/supabase_storage_service.dart` (existing; extend)
  - Details: Add `Future<({String url, String storagePath})> uploadStatusImage({required String userId, required File file})` that builds path `statuses/{userId}/{millis}{ext}` and returns both public URL and the storage path. Add `Future<void> removeStatusFile(String storagePath)` (or reuse generic remove). Do NOT touch Firestore here.
  - Acceptance criteria: New method exists, follows existing service style, throws on Supabase error (data source maps to ApiResult).

- [ ] T006: StatusRemoteDataSource
  - Goal: Encapsulate every Firestore + Supabase call for the feature.
  - Files: `lib/features/status/data/datasources/status_remote_data_source.dart`
  - Details: Constructor `(DataBaseService db, SupabaseStorageService storage)`. Methods per `contracts/repository.md`: `newStatusId()` is the *only* `FirebaseFirestore.instance.collection('statuses').doc().id` call; `uploadStatusImage` delegates; `createStatus` via `DataBaseService.setData`; `watchActiveStatusesForUsers` chunks `whereIn` to ≤30 and merges streams (`StreamGroup.merge`); `watchMyActiveStatuses`; `markStatusViewed` uses `FieldValue.arrayUnion([uid])`; `deleteStatus` removes Supabase file first if `storagePath` non-empty, then deletes the doc; `watchContactUserIds` queries `chats` where `users` array-contains current uid and maps to other participant.
  - Acceptance criteria: No `FirebaseFirestore.instance` reference outside the single `newStatusId()` line. All Firestore reads/writes via `DataBaseService`. All file ops via `SupabaseStorageService`.

- [ ] T007: StatusRepo
  - Goal: Map data source errors to `ApiResult<T>`; expose composed contact stream.
  - Files: `lib/features/status/data/repositories/status_repo.dart`
  - Details: Wrap one-shot calls in try/catch → `ApiResult.success/failure`. `watchActiveStatusesForContacts(uid)` = `watchContactUserIds(uid).switchMap(watchActiveStatusesForUsers)`. `createImageStatus(author, file)` performs upload → mints id → builds StatusModel (denormalized author fields with null-safe fallbacks, `viewers: []`, `createdAt = now.toUtc()`, `expiresAt = createdAt + 24h`, `type: 'image'`) → `createStatus`. `createTextStatus` skips upload. Document orphan-on-failure limitation in code comment if needed.
  - Acceptance criteria: Repository compiles; no Firestore/Supabase imports leak past it.

---

## Phase 3 — User Story 3: View Active Statuses (P1, foundational consumer flow)

> **Independent test**: With seed statuses present, opening the Status screen lists only `expiresAt > now`, split into Recent / Viewed.

- [ ] T008: [P] [US3] StatusState (Freezed sealed)
  - Goal: Declare the union of states for the contacts list cubit.
  - Files: `lib/features/status/presentation/bloc/status_cubit/status_state.dart`
  - Details: `@freezed sealed class StatusState with _$StatusState` — variants `initial`, `loading`, `loaded(List<StatusModel> recent, List<StatusModel> viewed)`, `empty`, `error(String message)`.
  - Acceptance criteria: Compiles after T015.

- [ ] T009: [US3] StatusCubit
  - Goal: Subscribe to contacts' active statuses; partition by viewers membership.
  - Files: `lib/features/status/presentation/bloc/status_cubit/status_cubit.dart`
  - Details: Constructor `(StatusRepo repo)`. `subscribe(currentUserId)` emits `loading`, opens `repo.watchActiveStatusesForContacts(currentUserId)`. On data: filter `!status.isExpired` (defense-in-depth), partition by `status.isViewedBy(currentUserId)`. Emit `empty` if both empty else `loaded`. On error: emit `error`. Cancel subscription on `close()`.
  - Acceptance criteria: Cubit never emits any state owned by `CreateStatusCubit`/`MyStatusCubit`; subscription cancelled on close.

- [ ] T010: [P] [US3] StatusBlocConsumer
  - Goal: Centralize listener+builder for `StatusCubit` (matches existing `*BlocConsumer` pattern).
  - Files: `lib/features/status/presentation/widgets/status_bloc_consumer.dart`
  - Details: `BlocConsumer<StatusCubit, StatusState>` switching on the sealed state — loading spinner, empty state widget, error toast via listener, and `loaded` rendering with two `ListView`s separated by `StatusSectionHeader`s.
  - Acceptance criteria: Uses `context.translate` for every label; `ShowToast.error` fires on `error` state.

- [ ] T011: [P] [US3] StatusUserCard widget
  - Goal: Render one contact-status row.
  - Files: `lib/features/status/presentation/widgets/status_user_card.dart`
  - Details: Avatar (handle null `userPhotoUrl` → fallback initial/asset), `TextApp` for name (handle empty → fallback to email), relative time of latest status, tap callback. Use `ScreenUtil` (`.w/.h/.sp`).
  - Acceptance criteria: Renders cleanly with all-null author fields without crash; no hardcoded strings; `const` constructors where possible.

- [ ] T012: [US3] StatusBody
  - Goal: Compose the screen body — My Status card + Recent + Viewed sections.
  - Files: `lib/features/status/presentation/widgets/status_body.dart`
  - Details: Vertical scroll. Top: `MyStatusCard` (US5 — stub if not yet done). Then `StatusBlocConsumer`. FAB triggers `CreateStatusBottomSheet` (wire when US1/US2 ready).
  - Acceptance criteria: Builds with only US3 wired; placeholders compile.

- [ ] T013: [US3] StatusScreen
  - Goal: Top-level screen; wires `MultiBlocProvider` for `StatusCubit` + `MyStatusCubit`, reads current user, calls `subscribe`.
  - Files: `lib/features/status/presentation/screens/status_screen.dart`
  - Details: `StatefulWidget`. In `initState` resolve `currentUser` from `AuthService` / cached `CurrentUserModel`, then `context.read<StatusCubit>().subscribe(uid)` and `context.read<MyStatusCubit>().subscribe(uid)`. Body = `StatusBody`. `Scaffold` with localized AppBar title (`LangKeys.statusTitle`).
  - Acceptance criteria: Mounts, subscribes, renders empty/loading/loaded/error correctly.

---

## Phase 4 — User Story 1: Create Image Status (P1)

> **Independent test**: Pick image → success toast → status appears in Recent on a contact device.

- [ ] T014: [P] [US1] CreateStatusState (Freezed sealed)
  - Goal: Distinct create-flow states; never blocks list cubit.
  - Files: `lib/features/status/presentation/bloc/create_status_cubit/create_status_state.dart`
  - Details: Variants `initial`, `uploadingImage`, `savingDoc`, `success(StatusModel)`, `error(String message)`.
  - Acceptance criteria: Compiles after T015.

- [ ] T015: Run build_runner for Freezed (all status states)
  - Goal: Generate `*.freezed.dart` for `StatusState`, `CreateStatusState`, `MyStatusState`.
  - Files: `*.freezed.dart` in each cubit folder.
  - Details: Run `dart run build_runner build --delete-conflicting-outputs` AFTER T008/T014/T021 are written.
  - Acceptance criteria: All freezed files generated; `flutter analyze` clean.

- [ ] T016: [US1] CreateStatusCubit
  - Goal: Implement upload + save state machine.
  - Files: `lib/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart`
  - Details: Constructor `(StatusRepo repo, AuthService auth)`. `createImageStatus(File file)`: emit `uploadingImage` → call `_repo.createImageStatus(...)` → on success emit `success(model)` else `error(message)`. (If finer-grained progress is desired, split repo to expose pre/post hooks; for v1 a single `uploadingImage` state is acceptable.) `createTextStatus(...)` emits `savingDoc` → success/error. `reset()` → `initial`.
  - Acceptance criteria: No `loading`/`loaded` states from `StatusState` are ever emitted here; failures surface readable messages.

- [ ] T017: [P] [US1] CreateStatusBlocConsumer
  - Goal: Listener for toasts + builder for in-progress UI.
  - Files: `lib/features/status/presentation/widgets/create_status_bloc_consumer.dart`
  - Details: `BlocListener<CreateStatusCubit, CreateStatusState>` showing `ShowToast.success(LangKeys.statusCreated)` on success and popping nav; `ShowToast.error(state.message)` on error. Builder returns inline progress with localized labels (`statusUploading`, `statusSaving`).
  - Acceptance criteria: Uses `ShowToast` per project convention; nothing hardcoded.

- [ ] T018: [US1] CreateStatusBottomSheet
  - Goal: Entry point UI for image vs text.
  - Files: `lib/features/status/presentation/widgets/create_status_bottom_sheet.dart`
  - Details: `showModalBottomSheet` body with two `CustomLinearButton` options: "Image" → opens `image_picker` (gallery/camera picker dialog) → on file: `context.read<CreateStatusCubit>().createImageStatus(file)`. "Text" → `Navigator.pushNamed(context, AppRoutes.textStatus)`. On permission denied: `ShowToast.error(LangKeys.statusPermissionDenied)`.
  - Acceptance criteria: All labels via `context.translate`; sheet closes on success.

---

## Phase 5 — User Story 2: Create Text Status (P2)

> **Independent test**: Type + pick color + tap Create → status appears in Recent.

- [ ] T019: [P] [US2] TextStatusForm widget
  - Goal: Text input + color palette in a `StatefulWidget`.
  - Files: `lib/features/status/presentation/widgets/text_status_form.dart`
  - Details: Declare `TextEditingController` and `ValueNotifier<int>` for selectedColor in `State` — NEVER inside `build`. Dispose properly. Use `CustomField` for the input. Palette is a horizontal `Row` of color circles. Top-right `CustomLinearButton` "Create" disabled when `controller.text.trim().isEmpty`. On submit: `context.read<CreateStatusCubit>().createTextStatus(text: text.trim(), backgroundColor: selectedColor)`.
  - Acceptance criteria: No controllers in `build`; uses `CustomField`/`CustomLinearButton`; localized labels.

- [ ] T020: [US2] TextStatusScreen
  - Goal: Hosts the form; provides `CreateStatusCubit`; listens for success/error.
  - Files: `lib/features/status/presentation/screens/text_status_screen.dart`
  - Details: `Scaffold` with background = currently selected color. Body = `TextStatusForm`. Wrap with `BlocProvider(create: (_) => sl<CreateStatusCubit>())` and `CreateStatusBlocConsumer` listener.
  - Acceptance criteria: On success pops back to status screen; on error stays put with toast.

---

## Phase 6 — User Story 5: My Status Card + Delete (P2)

> **Independent test**: Author sees own statuses on the My Status card; delete removes Firestore doc (and Supabase file for image).

- [ ] T021: [P] [US5] MyStatusState (Freezed sealed)
  - Goal: Distinct states for own statuses + delete lifecycle.
  - Files: `lib/features/status/presentation/bloc/my_status_cubit/my_status_state.dart`
  - Details: Variants `initial`, `loading`, `loaded(List<StatusModel>)`, `empty`, `error(String message)`, `deleting(String statusId)`, `deleted(String statusId)`, `deleteError(String message)`.
  - Acceptance criteria: Compiles after T015 re-run.

- [ ] T022: [US5] MyStatusCubit
  - Goal: Stream own statuses; perform deletes.
  - Files: `lib/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart`
  - Details: `subscribe(currentUserId)` emits `loading` → listens to `repo.watchMyActiveStatuses(uid)` → emits `loaded`/`empty`. `delete(StatusModel s)` emits `deleting(s.id)` → calls `repo.deleteStatus(s)` → emits `deleted(s.id)` on success or `deleteError` on failure. Cancel subscription on close.
  - Acceptance criteria: Delete state never affects `StatusCubit`/`CreateStatusCubit`.

- [ ] T023: [P] [US5] MyStatusCard widget
  - Goal: Top-of-screen card with avatar/count/preview + tap behavior.
  - Files: `lib/features/status/presentation/widgets/my_status_card.dart`
  - Details: `BlocBuilder<MyStatusCubit>`. If `empty` → tap opens `CreateStatusBottomSheet`. If `loaded` → tap opens `StatusViewerScreen` with own statuses list. Show count + latest preview thumbnail. Null-safe author fields.
  - Acceptance criteria: Renders empty / loading / loaded; localized.

- [ ] T024: [US5] Delete status flow + confirmation dialog
  - Goal: Confirm-then-delete UX inside the viewer.
  - Files: `lib/features/status/presentation/widgets/delete_status_confirm_dialog.dart` (new), wired from `StatusViewerScreen`.
  - Details: `AlertDialog` using `LangKeys.statusDeleteConfirm`. On confirm → `context.read<MyStatusCubit>().delete(status)`. Listener: success toast `statusDeleted`, error toast `statusDeleteError`. Pop the viewer if the deleted status was the only one.
  - Acceptance criteria: Image delete removes Supabase file; text delete leaves Supabase untouched; Firestore doc gone in both cases.

---

## Phase 7 — User Story 4: Full-Screen Viewer + Mark Viewed (P2)

> **Independent test**: Tap a status card → viewer opens → on open, current uid present in `viewers`; re-open does not duplicate.

- [ ] T025: [P] [US4] StatusViewerBody widget
  - Goal: Full-screen rendering of the user's statuses with PageView.
  - Files: `lib/features/status/presentation/widgets/status_viewer_body.dart`
  - Details: `PageView.builder` over `List<StatusModel>` from route args. Per page: image variant uses cached network image filling screen; text variant uses `Container(color: Color(backgroundColor))` + centered `TextApp(text, style: context.textStyle.headlineLarge)`. Top overlay: avatar + name + close `IconButton`. On `initState` (index 0) AND `onPageChanged`: call `sl<StatusRepo>().markStatusViewed(statusId, currentUid)` fire-and-forget.
  - Acceptance criteria: Renders both types; close works; `markStatusViewed` errors swallowed (logged only).

- [ ] T026: [US4] StatusViewerScreen
  - Goal: Route entry point reading args.
  - Files: `lib/features/status/presentation/screens/status_viewer_screen.dart`
  - Details: Reads `arguments` map `{ statuses, initialIndex, isOwn }` from `ModalRoute.of(context)!.settings.arguments`. Renders `StatusViewerBody`. If `isOwn == true`, top-right shows a delete `IconButton` wired to T024.
  - Acceptance criteria: Navigation works from `StatusUserCard` (US3) and `MyStatusCard` (US5); back gesture pops correctly.

- [ ] T027: [US4] Mark status as viewed (idempotency check)
  - Goal: Verify `arrayUnion` semantics end-to-end.
  - Files: (no new files) — covered in T025; this is a verification task.
  - Details: Open viewer with seed status not previously viewed. Inspect Firestore: `viewers` contains current uid exactly once. Close, re-open: still exactly once.
  - Acceptance criteria: Manual + Firestore console verification documented in `quickstart.md`.

---

## Phase 8 — Cross-Cutting Wiring

- [ ] T028: GetIt registration
  - Goal: Wire data source, repo, and three cubits into the DI container.
  - Files: `lib/core/di/injection_container.dart`
  - Details: `sl.registerLazySingleton<StatusRemoteDataSource>(...)`, `sl.registerLazySingleton<StatusRepo>(...)`, `sl.registerFactory<StatusCubit>(...)`, `<CreateStatusCubit>`, `<MyStatusCubit>`. Order after existing `DataBaseService` / `SupabaseStorageService` / `AuthService` registrations.
  - Acceptance criteria: `sl<StatusCubit>()` resolves at runtime; cold start has no missing-binding errors.

- [ ] T029: LangKeys additions
  - Goal: Centralize localization key strings.
  - Files: `lib/core/language/lang_keys.dart`
  - Details: Add the keys listed in `plan.md` §13: `statusTitle`, `statusRecentUpdates`, `statusViewedUpdates`, `statusMyStatus`, `statusTapToAdd`, `statusEmpty`, `statusAddImage`, `statusAddText`, `statusFromGallery`, `statusFromCamera`, `statusTextHint`, `statusCreate`, `statusCreated`, `statusCreateError`, `statusUploading`, `statusSaving`, `statusDelete`, `statusDeleteConfirm`, `statusDeleted`, `statusDeleteError`, `statusViewerClose`, `statusPermissionDenied`.
  - Acceptance criteria: All keys referenced in code resolve at compile time.

- [ ] T030: en.json and ar.json additions
  - Goal: English + Arabic translations for every new key.
  - Files: `lang/en.json`, `lang/ar.json`
  - Details: Add an entry per key in T029 to BOTH files. Validate JSON. Examples — `status_recent_updates` → "Recent updates" / "آخر التحديثات"; `status_viewed_updates` → "Viewed updates" / "تم عرضها".
  - Acceptance criteria: Switching device locale to Arabic shows Arabic labels everywhere; no `MISSING_KEY` placeholders.

- [ ] T031: Add route names
  - Goal: Register new routes in the central router.
  - Files: `lib/core/routes/app_routes.dart`
  - Details: Add `static const String status = '/status';`, `static const String textStatus = '/text-status';`, `static const String statusViewer = '/status-viewer';`. Register builders for each route. `StatusViewerScreen` extracts arguments from settings.
  - Acceptance criteria: `Navigator.pushNamed(context, AppRoutes.status)` works.

- [ ] T032: Connect to bottom navigation
  - Goal: Make Status reachable from the main shell.
  - Files: existing main shell / bottom-nav widget (project-specific).
  - Details: Add a tab item with the status icon + label `LangKeys.statusTitle`. Tab body = `StatusScreen`. If the project routes via named routes, push `AppRoutes.status` instead.
  - Acceptance criteria: Tab visible; tapping opens `StatusScreen`; existing tabs still work.

---

## Phase 9 — Manual Testing (executes `quickstart.md`)

- [ ] T033: [P] Test — create image status (US1)
  - Goal: Verify FR-001/FR-002/FR-004/FR-012.
  - Files: `specs/004-status-updates/quickstart.md` step 1.
  - Details: As account A → tap add → Image → pick file. Observe upload progress without list-blocking spinner. Success toast.
  - Acceptance criteria: Firestore doc with `type='image'`, `mediaUrl`, `storagePath`, `expiresAt ≈ now + 24h`, `viewers=[]`. Supabase object exists at `statuses/{A.uid}/...`.

- [ ] T034: [P] Test — create text status (US2)
  - Goal: Verify FR-003/FR-004.
  - Files: quickstart.md step 6.
  - Details: As A → add → Text → type + pick color → Create.
  - Acceptance criteria: Doc with `type='text'`, populated `text`/`backgroundColor`; no `mediaUrl`/`storagePath`. No Supabase upload.

- [ ] T035: [P] Test — active statuses load (US3)
  - Goal: Verify FR-005/FR-006/FR-017.
  - Files: quickstart.md steps 2 + 5.
  - Details: As contact B see A's status under Recent; as non-contact C see nothing. After viewing, status moves to Viewed Updates.
  - Acceptance criteria: Lists are correctly partitioned; non-contact sees zero of A's statuses.

- [ ] T036: [P] Test — my statuses load (US5)
  - Goal: Verify FR-007.
  - Files: quickstart.md step 8.
  - Details: As A, top of Status screen shows MyStatusCard with count + preview.
  - Acceptance criteria: Count matches active statuses count; tap opens viewer or bottom sheet appropriately.

- [ ] T037: [P] Test — expired statuses do not show (FR-005, SC-004)
  - Goal: Confirm both server query and client filter exclude expired docs.
  - Files: quickstart.md step 11.
  - Details: In Firestore console, set one status's `expiresAt` to a past Timestamp. Refresh on B's device.
  - Acceptance criteria: Status disappears from B's list within one stream emission.

- [ ] T038: [P] Test — open status viewer (US4)
  - Goal: Verify FR-008.
  - Files: quickstart.md step 3.
  - Details: As B, tap A's card.
  - Acceptance criteria: Full-screen viewer opens with image (or text+bg), name + photo overlay, close button.

- [ ] T039: [P] Test — mark status as viewed (FR-009, SC-007)
  - Goal: Verify idempotency of `arrayUnion`.
  - Files: quickstart.md step 4.
  - Details: Open the same status twice as B.
  - Acceptance criteria: `viewers` length increases by 1 on first open, stays the same on second open.

- [ ] T040: [P] Test — delete image status (US5, FR-010, FR-011)
  - Goal: Confirm Supabase file removal + Firestore doc removal.
  - Files: quickstart.md step 9.
  - Details: As A, delete an image status from the viewer.
  - Acceptance criteria: Firestore doc deleted; Supabase object at `storagePath` no longer exists; status disappears from B's list within 5 seconds (SC-005).

- [ ] T041: [P] Test — delete text status (FR-010)
  - Goal: Confirm Supabase is NOT touched for text deletes.
  - Files: quickstart.md step 10.
  - Details: As A, delete a text status.
  - Acceptance criteria: Firestore doc deleted; no Supabase API call made.

- [ ] T042: [P] Test — Supabase file removed correctly
  - Goal: Spot-check storage tab manually.
  - Files: Supabase dashboard.
  - Details: Cross-reference T040's `storagePath` with the storage browser — must be 404.
  - Acceptance criteria: Object enumeration returns no key matching the deleted status's `storagePath`.

- [ ] T043: [P] Test — Firestore document removed correctly
  - Goal: Spot-check Firestore console.
  - Files: Firebase console.
  - Details: After T040 and T041, verify both documents are gone from `statuses` collection.
  - Acceptance criteria: Document IDs not present.

- [ ] T044: [P] Test — empty / loading / error states work
  - Goal: Visual coverage of every state branch.
  - Files: quickstart.md step 12 + manual error injection.
  - Details: Fresh account D with no statuses → empty state visible. Force network off mid-load → error state with localized message. Throttled connection → loading spinner.
  - Acceptance criteria: Each state renders a localized widget without overflow / unbounded layout. No hardcoded strings.

---

## Phase 10 — Polish & Cleanup

- [ ] T045: Cleanup and refactor (common-mistakes audit)
  - Goal: Address every common-mistakes item.
  - Files: all status feature files.
  - Details: Walk the code and verify each item:
    - [ ] No mixing of `CreateStatusCubit` with `StatusCubit` (no listener emitting on the wrong cubit).
    - [ ] Zero `FirebaseFirestore.instance` references except the single `newStatusId()` line in the data source.
    - [ ] `storagePath` is set on every image status write.
    - [ ] Delete path removes Supabase file before Firestore doc (when `storagePath` non-empty).
    - [ ] `expiresAt > now` filter applied both server-side AND client-side.
    - [ ] `dart run build_runner build --delete-conflicting-outputs` documented and run after each generator-touching change.
    - [ ] Reads of `userName`/`userPhotoUrl`/`userEmail` are null-safe with sensible fallbacks.
    - [ ] No hardcoded user-visible strings — every label uses `context.translate(LangKeys.x)`.
    - [ ] No `TextEditingController` / `AnimationController` / `FocusNode` constructed inside any `build` method.
    - [ ] Every text widget is `TextApp`; every primary button is `CustomLinearButton`; every input is `CustomField`; every toast uses `ShowToast`.
    - [ ] Every dimension uses `ScreenUtil` (`.w`, `.h`, `.sp`).
  - Acceptance criteria: Every checkbox above ticked; `flutter analyze` clean; no new lint warnings.

- [ ] T046: Final build_runner pass + smoke run
  - Goal: One last regenerate + run.
  - Files: generated `*.g.dart` and `*.freezed.dart`.
  - Details: `dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter run`. Run quickstart end-to-end.
  - Acceptance criteria: Zero analyzer issues; quickstart steps 1–14 all pass.

---

## Dependency Graph

```
Phase 1 (T001–T002)
      ↓
Phase 2 (T003 → T004 → T005 → T006 → T007)         [foundational, blocks all stories]
      ↓
  ┌───┴──────────────┬──────────────┬────────────────┐
Phase 3 (US3)    Phase 4 (US1)   Phase 6 (US5)    Phase 7 (US4)
T008–T013        T014–T018       T021–T024        T025–T027
                  Phase 5 (US2) depends on Phase 4 cubit:
                  T019–T020
      ↓
Phase 8 (T028–T032)  [DI + i18n + routes + bottom nav]
      ↓
Phase 9 (T033–T044)  [manual tests, all [P]]
      ↓
Phase 10 (T045–T046)
```

- **MVP scope**: Phases 1+2+3+4 → users can create image statuses (P1) and contacts can view them (P1).
- **build_runner runs**: T004 (json_serializable for model), T015 (Freezed for all states — single combined run after T008/T014/T021).
- **Story independence**: US3 and US1 ship as MVP; US2/US4/US5 layer on without changing US3/US1 code.

## Parallel Execution Opportunities

- T008 / T010 / T011 within Phase 3 — different files, all `[P]`.
- T014 / T017 within Phase 4 — different files, `[P]`.
- T019 within Phase 5 — `[P]`.
- T021 / T023 within Phase 6 — `[P]`.
- T025 within Phase 7 — `[P]`.
- All Phase 9 manual tests T033–T044 — `[P]`.

## Format Validation

All 46 tasks follow `- [ ] TXXX: …` with Goal / Files / Details / Acceptance criteria sub-bullets. Story labels `[US1]..[US5]` applied to Phases 3–7; `[P]` markers applied where files are independent. Setup, Foundational, Cross-Cutting, and Polish phases carry no story label per the rules.
