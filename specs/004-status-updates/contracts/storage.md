# Contract — Supabase Storage

## Bucket: `statuses`

- **Public read**: yes (URLs are bearer-of-link; UIDs are not enumerable).
- **Authenticated write**: yes, restricted to objects whose key starts with `statuses/{auth.uid}/`.
- **Authenticated delete**: same.

## Object key scheme

```text
statuses/{userId}/{millisSinceEpoch}_{shortUuid}.{ext}
```

- `userId` — author's Firebase UID. Allows RLS to validate ownership and lets us delete by `storagePath` without keeping a separate index.
- `millisSinceEpoch` — `DateTime.now().millisecondsSinceEpoch`. Sortable, unique-per-ms.
- `shortUuid` — first 8 chars of a UUID v4. Defends against same-ms collisions and obscures predictability.
- `ext` — taken from picked file (`.jpg`, `.png`, `.webp`).

## Operations (via `SupabaseStorageService`)

| Operation | Method (existing service) | Returns |
|-----------|---------------------------|---------|
| Upload    | `uploadFile(bucket: 'statuses', path: key, file: file)` | public URL (`String`) |
| Remove    | `removeFile(bucket: 'statuses', path: storagePath)` | `void` |

> The exact method names mirror the existing `SupabaseStorageService` API used by `upload_image_data_source.dart`. If the actual signatures differ, the data source adapts; the contract here is the bucket name, key scheme, and "upload returns public URL, remove takes the same key we stored."

## Failure modes

- **Upload OK, Firestore write fails** → orphaned object remains. Documented v1 limitation; no auto-cleanup.
- **Firestore delete OK, Supabase remove fails** → orphaned object remains. Logged; UX still reflects deletion.
- **Supabase remove called for already-missing key** → swallow (treat as already deleted).
