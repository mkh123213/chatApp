# Quickstart: Status / Updates Feature

**Feature Branch**: `004-status-updates` | **Date**: 2026-05-07

## Prerequisites

- Flutter SDK ≥ 3.3.0
- Firebase project configured (Auth + Firestore)
- Supabase project configured with `chatapp` bucket
- Existing app with `DataBaseService`, `SupabaseStorageService`, and `GetIt` setup

## Integration Scenario 1: Create an Image Status

```text
1. User taps FAB / add button on StatusScreen
2. CreateStatusBottomSheet opens → user taps "Image" option
3. image_picker opens (gallery or camera)
4. File returned → CreateStatusCubit.createImageStatus() called
5. SupabaseStorageService.uploadStatusImage() uploads file
6. UploadedFileData { url, storagePath } returned
7. DataBaseService.setData() writes StatusModel to Firestore
8. CreateStatusCubit emits CreateStatusState.success()
9. UI shows ShowToast.showToastSuccessTop()
10. StatusCubit / MyStatusCubit refresh their streams automatically (real-time)
```

## Integration Scenario 2: Create a Text Status

```text
1. User taps FAB → CreateStatusBottomSheet → "Text" option
2. Navigator pushes TextStatusScreen
3. User types text, picks background color
4. Taps "Create" → CreateStatusCubit.createTextStatus() called
5. DataBaseService.setData() writes StatusModel (no upload needed)
6. CreateStatusCubit emits CreateStatusState.success()
7. Navigator pops back, ShowToast shown
```

## Integration Scenario 3: View Active Statuses

```text
1. StatusScreen loads → StatusCubit.getActiveStatuses() called
2. Cubit queries chats collection to get contact UIDs
3. Cubit queries statuses collection: expiresAt > now, userId in contactUIDs
4. Statuses split into recentUpdates (unviewed) and viewedUpdates
5. UI renders MyStatusCard at top, then sections
6. User taps a StatusUserCard → Navigator pushes StatusViewerScreen
7. StatusViewerScreen displays full-screen image/text
8. On open, StatusCubit.markAsViewed() → FieldValue.arrayUnion([currentUid])
```

## Integration Scenario 4: Delete Own Status

```text
1. User views own statuses via MyStatusCard
2. Long-press or delete button on a status item
3. MyStatusCubit.deleteStatus() called
4. If type == 'image': SupabaseStorageService.removeFile(storagePath)
5. DataBaseService.deleteData(path: 'statuses/$statusId')
6. MyStatusCubit emits updated list
7. ShowToast.showToastSuccessTop()
```

## Key Routes

| Route             | Screen               | Args                          |
|-------------------|-----------------------|-------------------------------|
| `/status`         | `StatusScreen`        | None (tab in MainScreen)      |
| `/text-status`    | `TextStatusScreen`    | None                          |
| `/status-viewer`  | `StatusViewerScreen`  | `List<StatusModel>` + index   |

## Build Commands

```bash
# Generate json_serializable + freezed code
dart run build_runner build --delete-conflicting-outputs
```
