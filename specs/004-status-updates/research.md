# Research: Status / Updates Feature

**Feature Branch**: `004-status-updates` | **Date**: 2026-05-07

## R-001: Firestore Data Design — Flat Collection vs Subcollections

- **Decision**: Use a single flat `statuses` collection at root level.
- **Rationale**: Each status is an independent document with its own `userId`, `expiresAt`, and `viewers`. A flat collection makes it straightforward to query all active statuses with `expiresAt > now` in one query. Subcollections (e.g., `users/{uid}/statuses`) would require a collection group query and add complexity.
- **Alternatives considered**:
  - `users/{uid}/statuses` subcollection — rejected because querying across all users requires collection group indexes and complicates the "get all active statuses" flow.

## R-002: Status Expiration Strategy — Client-side Filtering

- **Decision**: Filter expired statuses client-side using Firestore `where('expiresAt', isGreaterThan: Timestamp.now())`.
- **Rationale**: Firestore does not support TTL-based automatic deletion. A Cloud Function could clean up periodically, but that is out of scope for v1. The `expiresAt > now` query ensures only active statuses are returned.
- **Alternatives considered**:
  - Cloud Function with scheduled cleanup — deferred to v2.
  - Client-side timer to remove stale items from UI — unnecessary since each screen load re-queries.

## R-003: Supabase Storage Path Convention

- **Decision**: Store status images at `statuses/{userId}/{timestamp}{ext}` inside the existing `chatapp` bucket.
- **Rationale**: Follows the existing convention used by `uploadGroupImage` and `uploadChatImage`. Uses `userId` as the folder key so all of a user's status media is co-located. The timestamp-based filename avoids collisions.
- **Alternatives considered**:
  - Using `statusId` as the folder — rejected because the status ID is generated after the upload path is needed. The `userId` + timestamp approach is simpler.

## R-004: Viewers Array vs Subcollection for View Tracking

- **Decision**: Use an array field `viewers: List<String>` on the status document itself.
- **Rationale**: The spec explicitly defines `viewers` as a list of UIDs. For a status feature where the viewer count is typically small (< 500 contacts), an array field is performant and avoids extra reads. Idempotent writes use `FieldValue.arrayUnion`.
- **Alternatives considered**:
  - Subcollection `statuses/{statusId}/viewers` — rejected for v1 due to extra reads; would only be needed at very high scale.

## R-005: Contact Derivation from Chats Collection

- **Decision**: Derive "contacts" by querying the `chats` collection for documents where `users` contains the current user's UID, then extracting the other user's UID from each chat.
- **Rationale**: The spec (FR-006) states that contacts are users who share a direct chat. No separate contacts collection exists. The `chats` collection already has an `arrayContains` query pattern established in `ChatsRemoteDataSource`.
- **Alternatives considered**:
  - Dedicated `contacts` collection — explicitly out of scope per spec.

## R-006: Separate Cubits Architecture

- **Decision**: Three separate cubits: `StatusCubit` (list active statuses), `CreateStatusCubit` (create image/text status), `MyStatusCubit` (own statuses management).
- **Rationale**: FR-016 explicitly requires separate loading states. This follows the existing pattern of `ChatsCubit` + `CreateChatCubit` separation. Each cubit has its own Freezed state union.
- **Alternatives considered**:
  - Single `StatusCubit` with multiple state flags — rejected per user requirement to keep loading states separate.

## R-007: StatusModel — json_serializable vs Freezed

- **Decision**: Use `@JsonSerializable()` with manual `copyWith`, matching the existing `StatusModel` already in the codebase.
- **Rationale**: The existing `StatusModel` in `lib/features/status/data/models/status_model.dart` already uses `json_serializable` with custom `_dateTimeFromJson`/`_dateTimeToJson` for Timestamp handling. Keep consistency. Freezed is used only for state classes.
- **Alternatives considered**:
  - Freezed for the model — rejected because the existing pattern uses `json_serializable` for data models and Freezed only for state/union types.

## R-008: SupabaseStorageService — New Method vs Existing uploadImage

- **Decision**: Add a new `uploadStatusImage` method to `SupabaseStorageService` following the same pattern as `uploadGroupImage` / `uploadChatImage`.
- **Rationale**: Each upload method in the service has a specific path convention. A dedicated method ensures the path `statuses/{userId}/{timestamp}{ext}` is consistently applied.
- **Alternatives considered**:
  - Reuse generic `uploadImage` with `folderName: 'statuses'` and `ownerId` — viable but less explicit; a dedicated method is clearer and matches existing conventions.

## R-009: UI Sections — Recent Updates vs Viewed Updates

- **Decision**: Split contacts' statuses in-memory after fetching, based on whether `currentUser.uid` is in the `viewers` array.
- **Rationale**: FR-017 requires two sections. This is a pure UI concern: the same query fetches all active statuses from contacts, then the cubit/UI splits them into `recentUpdates` (unviewed) and `viewedUpdates` (already viewed).
- **Alternatives considered**:
  - Two separate Firestore queries — not feasible since Firestore can't query "array does NOT contain".
