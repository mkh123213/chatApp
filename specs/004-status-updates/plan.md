# Implementation Plan: Status / Updates

**Branch**: `004-status-updates` | **Date**: 2026-05-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-status-updates/spec.md`

## Summary

Add a WhatsApp-style Status feature: authenticated users can publish image and text statuses that auto-expire after 24 hours, view contacts' active statuses (split into "Recent Updates" / "Viewed Updates"), open a full-screen viewer that idempotently records views, and delete their own statuses (with Supabase file cleanup for image statuses). The feature reuses the existing Cubit + GetIt + Firebase Auth + Cloud Firestore + Supabase Storage stack and the existing `chats` collection to derive contact relationships.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: `flutter_bloc`, `freezed`, `json_serializable`, `get_it`, `cloud_firestore`, `firebase_auth`, `supabase_flutter`, `image_picker`, `shared_preferences`, `flutter_screenutil`
**Storage**: Cloud Firestore (`statuses` collection), Supabase Storage (`statuses` bucket), SharedPreferences (cached current user)
**Testing**: `flutter_test` for unit/widget; manual smoke per quickstart
**Target Platform**: Android + iOS (mobile)
**Project Type**: mobile-app (single Flutter project)
**Performance Goals**: Status list visible < 2s on warm cache; create text < 10s; create image < 30s on standard 4G
**Constraints**: 24h hard expiry filtered client-side via `expiresAt > now`; viewer write must be idempotent (`arrayUnion`); no shared loading state across the three Cubits
**Scale/Scope**: ~10s of statuses per user per day; ~6 screens/widgets; 3 Cubits; 1 model; 1 remote data source; 1 repository

## Constitution Check

The project constitution (`.specify/memory/constitution.md`) is an unfilled template (placeholders only) — no enforceable gates. The plan instead complies with the binding rules in `CLAUDE.md`:

- Layer separation (presentation → domain/repo → data) ✅
- Cubit/Bloc state management, no Riverpod/Provider/GetX ✅
- `get_it` for DI ✅
- Cubits depend on repositories (project convention — no use-case layer in current codebase) ✅ (matches existing features like `chats`/`auth`)
- Localization via `LangKeys` for every visible string ✅
- `DataBaseService` is the only Firestore entry point (except `.collection('statuses').doc().id` for new doc IDs) ✅
- `SupabaseStorageService` is the only storage entry point ✅
- No new packages added ✅
- Separate Cubits for list / create / my statuses — no shared loading ✅ (FR-016)

> **Note on `CLAUDE.md` "No Freezed" rule**: The user's `/speckit-plan` input explicitly lists Freezed as part of the stack to use, and the existing codebase already uses Freezed for `app_cubit.freezed.dart`, `auth_cubit.freezed.dart`, etc. The plan follows the user's explicit instruction and existing project convention; this is a documented deviation from the generic CLAUDE.md guidance, justified by user intent and codebase consistency.

## Project Structure

### Documentation (this feature)

```text
specs/004-status-updates/
├── plan.md              # This file
├── spec.md              # Feature spec
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── contracts/
    ├── firestore.md     # Firestore document & query contract
    ├── storage.md       # Supabase Storage path contract
    └── repository.md    # Dart repository / data-source method contract
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── di/injection_container.dart            # + status registrations
│   ├── language/lang_keys.dart                # + status keys
│   ├── routes/app_routes.dart                 # + /status, /text-status, /status-viewer
│   └── service/
│       ├── data_base_service/                 # existing — used as-is
│       └── supabase_storage_service/          # existing — used as-is
└── features/
    └── status/
        ├── data/
        │   ├── datasources/
        │   │   └── status_remote_data_source.dart
        │   ├── models/
        │   │   ├── status_model.dart
        │   │   └── status_model.g.dart        # generated
        │   └── repositories/
        │       └── status_repo.dart
        └── presentation/
            ├── bloc/
            │   ├── status_cubit/
            │   │   ├── status_cubit.dart
            │   │   ├── status_cubit.freezed.dart   # generated
            │   │   └── status_state.dart
            │   ├── create_status_cubit/
            │   │   ├── create_status_cubit.dart
            │   │   ├── create_status_cubit.freezed.dart
            │   │   └── create_status_state.dart
            │   └── my_status_cubit/
            │       ├── my_status_cubit.dart
            │       ├── my_status_cubit.freezed.dart
            │       └── my_status_state.dart
            ├── screens/
            │   ├── status_screen.dart
            │   ├── status_viewer_screen.dart
            │   └── text_status_screen.dart
            └── widgets/
                ├── my_status_card.dart
                ├── status_user_card.dart
                ├── status_section_header.dart
                └── create_status_bottom_sheet.dart

lang/
├── ar.json              # + status keys
└── en.json              # + status keys
```

**Structure Decision**: Single Flutter project, feature-first layout under `lib/features/status/`, mirroring the existing `chats` and `auth` features. No use-case layer is introduced — Cubits depend directly on `StatusRepo`, matching existing project convention (deviation from generic CLAUDE.md justified by codebase consistency).

---

## Phase 0 — Research (see `research.md`)

All technology choices are pre-decided by user input and existing codebase. `research.md` records the decisions and the alternatives rejected. No outstanding `NEEDS CLARIFICATION`.

## Phase 1 — Design Artifacts

- `data-model.md` — `StatusModel` field-by-field, with validation, derived state, transitions.
- `contracts/firestore.md` — collection name, document shape, query filters, indexes.
- `contracts/storage.md` — Supabase bucket and path scheme.
- `contracts/repository.md` — Dart method signatures for data source, repository, and the three Cubits' public APIs.
- `quickstart.md` — manual smoke test the developer runs after implementation.

---

## 1) Folder / File Structure

See "Source Code" tree above. Conventions:
- `data/datasources/` → raw I/O, throws on error.
- `data/repositories/` → catches, maps to `ApiResult<T>`, returns to Cubit.
- `presentation/bloc/<name>_cubit/` → one folder per Cubit (state + freezed file co-located).

## 2) Firestore Data Design

**Collection**: `statuses` (top-level, flat — easy to query across users and to filter on `expiresAt`).

**Document ID**: auto-generated via `FirebaseFirestore.instance.collection('statuses').doc().id` (the *only* sanctioned direct use of `FirebaseFirestore.instance`, used to mint an ID before write so the model carries it).

**Document fields**:

| Field            | Type        | Notes |
|------------------|-------------|-------|
| `id`             | string      | Mirrors document ID for client convenience |
| `userId`         | string      | `currentUser.uid` |
| `userName`       | string      | Denormalized for fast list rendering |
| `userEmail`      | string      | Denormalized |
| `userPhotoUrl`   | string?     | Denormalized; nullable |
| `type`           | string      | `"image"` or `"text"` |
| `mediaUrl`       | string?     | Public Supabase URL (image only) |
| `storagePath`    | string?     | Supabase object key (image only) for delete |
| `text`           | string?     | Text content (text only) |
| `backgroundColor`| int?        | ARGB int (text only) |
| `viewers`        | array<string> | UIDs that opened the viewer; updated via `arrayUnion` |
| `createdAt`      | Timestamp   | `FieldValue.serverTimestamp()` on write |
| `expiresAt`      | Timestamp   | `Timestamp.fromDate(DateTime.now().add(24h))` |

**Queries**:
- Active statuses for contacts: `where('userId', whereIn: contactUids)` + `where('expiresAt', isGreaterThan: Timestamp.now())` + `orderBy('expiresAt')` + `orderBy('createdAt', descending: true)`. `whereIn` caps at 30 — chunk if needed.
- My statuses: `where('userId', isEqualTo: currentUid)` + `where('expiresAt', isGreaterThan: Timestamp.now())` + `orderBy('expiresAt')` + `orderBy('createdAt', descending: true)`.

**Indexes** (composite, declared in `firestore.indexes.json` if not auto-prompted):
- `(userId ASC, expiresAt ASC, createdAt DESC)`
- `(expiresAt ASC, createdAt DESC)` — for the contacts `whereIn` query

**Security rules** (out of scope for this plan but documented in `contracts/firestore.md`): only the author may delete; only authenticated users may read; viewer update may use `arrayUnion(uid)` only on their own UID.

## 3) Supabase Storage Path Design

- **Bucket**: `statuses` (public read; insert/delete restricted to authenticated users with matching `userId` prefix via Supabase RLS).
- **Object key**: `statuses/{userId}/{timestampMillis}_{uuidShort}.{ext}`
  - Embeds `userId` so RLS can validate ownership and so deletes via `storagePath` are unambiguous.
  - Timestamp + short UUID prevents collisions on rapid uploads.
- **Returned URL**: public URL stored as `mediaUrl`; raw key stored as `storagePath` for delete.

## 4) StatusModel Design

`status_model.dart` — `@JsonSerializable(explicitToJson: true)` plain Dart class (NOT Freezed; Freezed is reserved for Cubit states in this project). Fields exactly as in §2. Helpers:

- `factory StatusModel.fromJson(Map<String, dynamic> json)` — generated.
- `Map<String, dynamic> toJson()` — generated.
- Custom `Timestamp` ↔ `DateTime` converter (`TimestampConverter implements JsonConverter<DateTime, Timestamp>`) since Firestore returns `Timestamp`, not ISO string.
- `bool get isExpired => DateTime.now().isAfter(expiresAt);`
- `bool get isImage => type == 'image';`
- `bool get isText => type == 'text';`
- `bool isViewedBy(String uid) => viewers.contains(uid);`
- `static const typeImage = 'image'; static const typeText = 'text';`

## 5) Remote Data Source Methods

`StatusRemoteDataSource` (constructor takes `DataBaseService` + `SupabaseStorageService`):

```text
Future<String> uploadStatusImage({required String userId, required File file});
  // returns public mediaUrl; also exposes storagePath via out-param OR return record (mediaUrl, storagePath)

Future<void> createStatusDoc({required StatusModel status});
  // writes to statuses/{status.id} via DataBaseService.setData

Stream<List<StatusModel>> watchActiveStatusesForUsers({required List<String> userIds});
  // chunks userIds into groups of <=30, merges streams, filters expiresAt > now client-side as safety net

Stream<List<StatusModel>> watchMyActiveStatuses({required String userId});

Future<void> markStatusViewed({required String statusId, required String viewerUid});
  // DataBaseService.updateData with {'viewers': FieldValue.arrayUnion([viewerUid])}

Future<void> deleteStatus({required StatusModel status});
  // 1) if storagePath != null && non-empty → SupabaseStorageService.removeFile(storagePath)
  // 2) DataBaseService.deleteData('statuses', status.id)

Stream<List<String>> watchContactUserIds({required String currentUserId});
  // queries existing chats collection, extracts the "other participant" uid per chat, returns distinct list
```

The data source NEVER touches `FirebaseFirestore.instance` directly except `…collection('statuses').doc().id` for ID minting before `setData`.

## 6) Repository Methods

`StatusRepo` wraps the data source and converts thrown errors to typed `ApiResult<T>` (existing project type). Returns/streams below mirror data source but with `ApiResult` envelopes for one-shot calls; streams pass through.

```text
Stream<List<StatusModel>> watchActiveStatusesForContacts(String currentUserId);
  // composes watchContactUserIds → switchMap → watchActiveStatusesForUsers
Stream<List<StatusModel>> watchMyActiveStatuses(String currentUserId);
Future<ApiResult<StatusModel>> createImageStatus({required CurrentUserModel author, required File image});
Future<ApiResult<StatusModel>> createTextStatus({required CurrentUserModel author, required String text, required int backgroundColor});
Future<ApiResult<void>> markStatusViewed({required String statusId, required String viewerUid});
Future<ApiResult<void>> deleteStatus(StatusModel status);
```

Edge case: image upload succeeds but `createStatusDoc` fails → repository returns failure; orphaned file is left (documented v1 limitation per spec).

## 7) Cubits and States

All states are `sealed`/Freezed unions with **separate** loading flags per concern (FR-016). Each Cubit has its own `emit` lifecycle.

### 7.1 `StatusCubit` — contacts' active statuses
- **State** (`StatusState`): `initial | loading | loaded(List<StatusModel> recent, List<StatusModel> viewed) | empty | error(String message)`.
  - `recent` = current user UID NOT in `viewers`.
  - `viewed` = current user UID IS in `viewers`.
- **Methods**: `subscribe(String currentUserId)`, `refresh()`, `close()` (cancels subscription).
- Uses `repo.watchActiveStatusesForContacts(currentUserId)`; partitions in Cubit, emits `loaded` or `empty`.

### 7.2 `CreateStatusCubit` — write path
- **State** (`CreateStatusState`): `initial | uploadingImage | savingDoc | success(StatusModel status) | error(String message)`.
  - Two distinct in-flight states allow the UI to show progress text differentiated from the list spinner (no shared loading).
- **Methods**: `createImageStatus(File image)`, `createTextStatus({required String text, required int backgroundColor})`, `reset()`.
- Resolves `CurrentUserModel` from injected `AuthService` / cached pref (matches existing pattern).

### 7.3 `MyStatusCubit` — current user's statuses
- **State** (`MyStatusState`): `initial | loading | loaded(List<StatusModel> mine) | empty | error(String message) | deleting(String statusId) | deleted(String statusId) | deleteError(String message)`.
- **Methods**: `subscribe(String currentUserId)`, `delete(StatusModel status)`, `close()`.
- Listens via `repo.watchMyActiveStatuses`. Delete invokes `repo.deleteStatus`; emits `deleting → deleted` and the stream subscription naturally drops the row.

`StatusCubit.loaded` and `MyStatusCubit.loaded` are **independent** — the screen owns both Cubits and uses `BlocBuilder` per section.

## 8) GetIt Registration (`core/di/injection_container.dart`)

Add inside the existing `setupGetIt()` (or feature-specific extension):

```text
// Data
sl.registerLazySingleton<StatusRemoteDataSource>(
  () => StatusRemoteDataSource(sl<DataBaseService>(), sl<SupabaseStorageService>()),
);
sl.registerLazySingleton<StatusRepo>(
  () => StatusRepo(sl<StatusRemoteDataSource>()),
);

// Cubits — factory so each screen mount gets a fresh instance & lifecycle
sl.registerFactory<StatusCubit>(() => StatusCubit(sl<StatusRepo>()));
sl.registerFactory<CreateStatusCubit>(() => CreateStatusCubit(sl<StatusRepo>(), sl<AuthService>()));
sl.registerFactory<MyStatusCubit>(() => MyStatusCubit(sl<StatusRepo>()));
```

`DataBaseService`, `SupabaseStorageService`, and `AuthService` are already registered.

## 9) UI Flow

### 9.1 `StatusScreen` (`/status`)
- Top: `MyStatusCard` (BlocProvider<MyStatusCubit>).
- Section header: `context.translate(LangKeys.statusRecentUpdates)`.
- List of `StatusUserCard` for `state.recent`.
- Section header: `context.translate(LangKeys.statusViewedUpdates)`.
- List of `StatusUserCard` for `state.viewed`.
- FAB or trailing icon → opens `CreateStatusBottomSheet`.
- Empty state: centered `TextApp` using `context.translate(LangKeys.statusEmpty)`.
- Wrapped in `MultiBlocProvider` for `StatusCubit` and `MyStatusCubit`; `subscribe(currentUid)` in `initState` of a small `StatefulWidget` shell.

### 9.2 `MyStatusCard`
- Shows current user avatar + count + latest preview.
- Tap → if `state` is `empty` → opens `CreateStatusBottomSheet`; else → navigates to `StatusViewerScreen` with own statuses list.
- Long-press / trailing menu on each viewer entry inside viewer → confirm dialog → `MyStatusCubit.delete(status)`.

### 9.3 `StatusUserCard`
- Avatar + name + relative time of latest status.
- Tap → navigates to `/status-viewer` with the list of that user's statuses (passed via route arguments).
- On tap, calls `StatusCubit.markCurrentItemViewed(...)` indirectly via the viewer screen.

### 9.4 `CreateStatusBottomSheet`
- Two big options: `CustomLinearButton` "Image" → opens `image_picker` (gallery/camera chooser dialog) → on pick calls `CreateStatusCubit.createImageStatus(file)`.
- `CustomLinearButton` "Text" → `Navigator.pushNamed(context, '/text-status')`.
- BlocListener on `CreateStatusCubit`: success → `ShowToast.success(LangKeys.statusCreated)` + close sheet; error → `ShowToast.error(state.message)`.

### 9.5 `StatusViewerScreen` (`/status-viewer`)
- Route arguments: `{ List<StatusModel> statuses, int initialIndex }`.
- Full-screen `PageView` (horizontal) over the user's statuses.
- Per page:
  - If `isImage` → cached network image filling screen.
  - If `isText` → `Container(color: Color(backgroundColor))` + centered `TextApp(text, style: context.textStyle.headlineLarge)`.
  - Top overlay: small avatar + name + close `IconButton`.
- On page settle: `repo.markStatusViewed(statusId, currentUid)` (fire-and-forget; failure tolerated per FR/spec).

### 9.6 `TextStatusScreen` (`/text-status`)
- Background = currently selected color (default first palette entry).
- Centered `CustomField` (multiline, auto-focus).
- Bottom: horizontal palette of color chips.
- Top-right `CustomLinearButton` "Create" — disabled until text is non-empty.
- On submit: `CreateStatusCubit.createTextStatus(...)`.
- BlocListener: success → pop to `/status`, success toast; error → toast, stay on screen.

### 9.7 Routes (`core/routes/app_routes.dart`)
```
'/status'         → StatusScreen
'/text-status'    → TextStatusScreen
'/status-viewer'  → StatusViewerScreen (reads arguments for statuses + index)
```

## 10) Status Expiration Logic

- **Write side**: `expiresAt = Timestamp.fromDate(DateTime.now().toUtc().add(const Duration(hours: 24)))`.
- **Read side (primary)**: Firestore query `where('expiresAt', isGreaterThan: Timestamp.now())`.
- **Read side (defense in depth)**: Repository also filters `!status.isExpired` after deserialization (handles devices with skewed clocks where the server query already returned a soon-to-expire row).
- **No background cleanup in v1** — expired docs simply stop appearing. (A scheduled Cloud Function for hard deletion is out of scope; documented as future work.)

## 11) Mark Status as Viewed Logic

- Triggered from `StatusViewerScreen` on each page settle.
- `StatusRemoteDataSource.markStatusViewed` does:
  ```
  DataBaseService.updateData(
    collection: 'statuses', docId: statusId,
    data: { 'viewers': FieldValue.arrayUnion([viewerUid]) },
  );
  ```
- `arrayUnion` makes the operation idempotent — re-views never duplicate the UID (FR-009).
- Fire-and-forget from the UI; errors are swallowed in repo (best-effort per spec edge case).
- Author viewing own status is a no-op for the recent/viewed split (My Status section is independent), but the write still happens for consistency.

## 12) Delete Status Logic

`StatusRepo.deleteStatus(status)`:
1. If `status.storagePath != null && status.storagePath!.isNotEmpty` → `SupabaseStorageService.remove(status.storagePath!)`. Failure here logs but proceeds (file may already be missing).
2. `DataBaseService.deleteData(collection: 'statuses', docId: status.id)`.
3. On success → `ApiResult.success(null)`. On Firestore failure → `ApiResult.failure(...)` (file may be orphaned; documented limitation symmetric to upload-then-write failure).

UI: confirmation `AlertDialog` before calling `MyStatusCubit.delete`. Success → `ShowToast.success(LangKeys.statusDeleted)`; error → `ShowToast.error(...)`.

## 13) Localization Keys and JSON Entries

Add to `lib/core/language/lang_keys.dart`:
```
static const String statusTitle             = 'status_title';
static const String statusRecentUpdates     = 'status_recent_updates';
static const String statusViewedUpdates     = 'status_viewed_updates';
static const String statusMyStatus          = 'status_my_status';
static const String statusTapToAdd          = 'status_tap_to_add';
static const String statusEmpty             = 'status_empty';
static const String statusAddImage          = 'status_add_image';
static const String statusAddText           = 'status_add_text';
static const String statusFromGallery       = 'status_from_gallery';
static const String statusFromCamera        = 'status_from_camera';
static const String statusTextHint          = 'status_text_hint';
static const String statusCreate            = 'status_create';
static const String statusCreated           = 'status_created';
static const String statusCreateError       = 'status_create_error';
static const String statusUploading         = 'status_uploading';
static const String statusSaving            = 'status_saving';
static const String statusDelete            = 'status_delete';
static const String statusDeleteConfirm     = 'status_delete_confirm';
static const String statusDeleted           = 'status_deleted';
static const String statusDeleteError       = 'status_delete_error';
static const String statusViewerClose       = 'status_viewer_close';
static const String statusPermissionDenied  = 'status_permission_denied';
```

Add entries to BOTH `lang/en.json` and `lang/ar.json` (Arabic translations supplied).

## 14) Build Runner Commands

Run after creating `status_model.dart` and any `*_state.dart` Freezed files:

```text
dart run build_runner build --delete-conflicting-outputs
```

For iterative dev:

```text
dart run build_runner watch --delete-conflicting-outputs
```

Generates: `status_model.g.dart`, `status_cubit.freezed.dart`, `create_status_cubit.freezed.dart`, `my_status_cubit.freezed.dart`.

## 15) Testing Checklist

**Unit**
- [ ] `StatusModel.fromJson` round-trips (incl. `Timestamp` ↔ `DateTime`, nullable `mediaUrl`/`text`).
- [ ] `isExpired`, `isViewedBy`, `isImage`, `isText` helpers.
- [ ] `StatusRepo.createImageStatus` returns failure when upload throws (no Firestore write attempted).
- [ ] `StatusRepo.deleteStatus` skips Supabase remove when `storagePath` is null/empty.
- [ ] `StatusCubit` partitions stream emissions into `recent` / `viewed` correctly based on `viewers` membership.
- [ ] `CreateStatusCubit` emits `uploadingImage → savingDoc → success` for image, and `savingDoc → success` for text.
- [ ] `MyStatusCubit.delete` emits `deleting → deleted`.
- [ ] Loading states across the three Cubits are independent (asserted by emitting on one and verifying others untouched).

**Widget**
- [ ] `StatusScreen` shows empty-state widget when both `recent` and `viewed` are empty.
- [ ] `StatusUserCard` triggers navigation with correct arguments on tap.
- [ ] `CreateStatusBottomSheet` shows success toast on `success` state.
- [ ] `TextStatusScreen` Create button is disabled when text is empty.
- [ ] `StatusViewerScreen` shows correct rendering for both `image` and `text` types.

**Manual / Integration** (via `quickstart.md`)
- [ ] Two test accounts that share a chat — A creates statuses, B sees them.
- [ ] Account that does NOT share a chat — does NOT see them (FR-006).
- [ ] Open viewer — `viewers` array contains current uid in Firestore console.
- [ ] Re-open viewer — array length unchanged.
- [ ] Manually edit `expiresAt` to past — status disappears on next refresh.
- [ ] Delete image status — Firestore doc gone, Supabase file gone.
- [ ] Delete text status — Firestore doc gone, Supabase untouched.
- [ ] Toggle locale ar ↔ en — every visible label translates (FR-015 / SC-006).

## 16) Common Mistakes to Avoid

1. **Don't call `FirebaseFirestore.instance` directly** — only `DataBaseService`. The single allowed exception is `…collection('statuses').doc().id` for ID minting; isolate it inside the data source.
2. **Don't share a single `StatusState`/loading flag across list + create + my-status flows** — FR-016 and the user input both forbid it.
3. **Don't write `viewers: [uid]` directly** — always `FieldValue.arrayUnion([uid])` to keep idempotency.
4. **Don't write the Firestore doc before the Supabase upload completes** for image statuses — leads to broken `mediaUrl`. Upload first, doc second.
5. **Don't forget the `storagePath`** — without it, image deletions cannot remove the file. Save it on create.
6. **Don't filter expiry only client-side or only server-side** — do both. Server query for cost/scale; client filter for clock skew.
7. **Don't put business logic in widgets** — Cubits orchestrate; widgets only render and dispatch.
8. **Don't instantiate Cubits manually** — always `sl<...>()` via GetIt; use `BlocProvider(create: (_) => sl<...>())`.
9. **Don't create `TextEditingController` inside `build()`** in `TextStatusScreen` — declare in `State` and dispose properly.
10. **Don't skip ScreenUtil sizing** — every padding/font/height must use `.w` / `.h` / `.sp`.
11. **Don't hardcode strings** — every visible label goes through `context.translate(LangKeys.x)`. Includes toasts, dialog titles, button labels, hints.
12. **Don't use `whereIn` with > 30 items** — chunk contact lists into batches of 30, merge streams.
13. **Don't forget to `cancel()` Firestore stream subscriptions** in Cubit `close()` — leaks otherwise.
14. **Don't show one big `CircularProgressIndicator`** that blocks the screen during status creation — `CreateStatusCubit` is independent; keep the list visible.
15. **Don't trust the device clock** — derive `expiresAt` from `DateTime.now().toUtc()` and always re-check `isExpired` post-fetch.
16. **Don't put Flutter imports in `data/` or `domain` types** — `StatusModel` must be pure Dart (only `cloud_firestore` for `Timestamp`).
17. **Don't overwrite `viewers` on update** — `arrayUnion` only. Setting the whole field would clobber other viewers.
18. **Don't forget the composite index** — Firestore will throw on first run; deploy the index before testing the contacts query.

---

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Use of Freezed (vs CLAUDE.md "no Freezed") | User input mandates it; existing codebase uses it for all Cubits | Switching the whole project to sealed classes is out of scope for this feature |
| No use-case layer between Cubit and Repo | Existing `chats`/`auth` features follow this pattern; user input lists Repo directly | Introducing use cases here only would create inconsistency in the codebase |

---

## Phase Status

- [x] Phase 0 — research.md
- [x] Phase 1 — data-model.md, contracts/, quickstart.md, agent context updated
- [ ] Phase 2 — tasks.md (run `/speckit-tasks` next)
