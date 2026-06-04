# Contract — Dart APIs (data source, repository, cubits)

> Signatures only — implementation comes in Phase 3 (`/speckit-implement`).

## `StatusRemoteDataSource`

```dart
class StatusRemoteDataSource {
  StatusRemoteDataSource(this._db, this._storage);
  final DataBaseService _db;
  final SupabaseStorageService _storage;

  String newStatusId(); // wraps the only direct FirebaseFirestore.instance call

  Future<({String mediaUrl, String storagePath})> uploadStatusImage({
    required String userId,
    required File file,
  });

  Future<void> createStatus(StatusModel status);

  Stream<List<StatusModel>> watchActiveStatusesForUsers(List<String> userIds);

  Stream<List<StatusModel>> watchMyActiveStatuses(String userId);

  Future<void> markStatusViewed({
    required String statusId,
    required String viewerUid,
  });

  Future<void> deleteStatus(StatusModel status);

  Stream<List<String>> watchContactUserIds(String currentUserId);
}
```

## `StatusRepo`

```dart
class StatusRepo {
  StatusRepo(this._ds);
  final StatusRemoteDataSource _ds;

  Stream<List<StatusModel>> watchActiveStatusesForContacts(String currentUserId);

  Stream<List<StatusModel>> watchMyActiveStatuses(String currentUserId);

  Future<ApiResult<StatusModel>> createImageStatus({
    required CurrentUserModel author,
    required File image,
  });

  Future<ApiResult<StatusModel>> createTextStatus({
    required CurrentUserModel author,
    required String text,
    required int backgroundColor,
  });

  Future<ApiResult<void>> markStatusViewed({
    required String statusId,
    required String viewerUid,
  });

  Future<ApiResult<void>> deleteStatus(StatusModel status);
}
```

## Cubits

### `StatusCubit`
```dart
sealed class StatusState with _$StatusState {
  const factory StatusState.initial()                                     = _Initial;
  const factory StatusState.loading()                                     = _Loading;
  const factory StatusState.loaded({
    required List<StatusModel> recent,
    required List<StatusModel> viewed,
  })                                                                       = _Loaded;
  const factory StatusState.empty()                                       = _Empty;
  const factory StatusState.error(String message)                        = _Error;
}

class StatusCubit extends Cubit<StatusState> {
  StatusCubit(this._repo) : super(const StatusState.initial());
  final StatusRepo _repo;

  void subscribe(String currentUserId);
  Future<void> close();
}
```

### `CreateStatusCubit`
```dart
sealed class CreateStatusState with _$CreateStatusState {
  const factory CreateStatusState.initial()                              = _Initial;
  const factory CreateStatusState.uploadingImage()                       = _Uploading;
  const factory CreateStatusState.savingDoc()                            = _Saving;
  const factory CreateStatusState.success(StatusModel status)            = _Success;
  const factory CreateStatusState.error(String message)                  = _Error;
}

class CreateStatusCubit extends Cubit<CreateStatusState> {
  Future<void> createImageStatus(File image);
  Future<void> createTextStatus({required String text, required int backgroundColor});
  void reset();
}
```

### `MyStatusCubit`
```dart
sealed class MyStatusState with _$MyStatusState {
  const factory MyStatusState.initial()                                  = _Initial;
  const factory MyStatusState.loading()                                  = _Loading;
  const factory MyStatusState.loaded(List<StatusModel> mine)             = _Loaded;
  const factory MyStatusState.empty()                                    = _Empty;
  const factory MyStatusState.error(String message)                      = _Error;
  const factory MyStatusState.deleting(String statusId)                  = _Deleting;
  const factory MyStatusState.deleted(String statusId)                   = _Deleted;
  const factory MyStatusState.deleteError(String message)                = _DeleteError;
}

class MyStatusCubit extends Cubit<MyStatusState> {
  void subscribe(String currentUserId);
  Future<void> delete(StatusModel status);
}
```

## Loading independence (FR-016)

- `StatusCubit.loading` MUST NOT be emitted by `CreateStatusCubit` or `MyStatusCubit` actions.
- `CreateStatusCubit.uploadingImage` / `savingDoc` MUST NOT pause the list stream.
- `MyStatusCubit.deleting` MUST NOT block the contacts list. Each Cubit owns its own state machine.
