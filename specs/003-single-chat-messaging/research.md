# Research: Single Chat Messaging

## Decision 1: State Management Pattern
- **Decision**: Use Cubit (flutter_bloc) — one Cubit per concern: `MessagesCubit` (stream of messages), `SendMessageCubit` (send/upload lifecycle).
- **Rationale**: Matches every other feature in this codebase. Cubits depend only on use cases, never directly on data sources (CLAUDE.md §B-1).
- **Alternatives considered**: Single merged cubit — rejected because send/upload state is independent of the messages stream and merging would cause unnecessary rebuilds.

## Decision 2: Real-Time Message Delivery
- **Decision**: Use `DataBaseService.collectionStream()` (already wraps `FirebaseFirestore`) to stream messages for a given `chatId`, ordered by `sentAt` descending, paginated 20 at a time.
- **Rationale**: The `DataBaseService` abstraction is already in use across the project. Leveraging it avoids direct Firestore coupling in the domain layer.
- **Alternatives considered**: HTTP polling — rejected; Firestore real-time streams are already the project pattern.

## Decision 3: Media Storage Strategy
- **Decision**: `SupabaseStorageService` (already exists at `lib/core/service/supabase/supabase_storage_service.dart`) handles all binary uploads. New methods will be added: `uploadChatImage`, `uploadChatAudio`, `uploadChatFile`. Only the public URL + metadata are written to Firestore.
- **Rationale**: Supabase Storage bucket `chatapp` is already set up. The service already has `uploadMessageImage` and `uploadMessageFile` for groups — the single-chat variants follow the same pattern under path `chats/{chatId}/messages/{type}/`.
- **Alternatives considered**: Firebase Storage — rejected; the user explicitly chose Supabase.

## Decision 4: Message Model
- **Decision**: A new `MessageModel` in `lib/features/single_chat/data/models/` with fields: `id`, `chatId`, `senderId`, `type` (enum: text/image/audio/file), `content` (text or URL), `fileName`, `fileSize`, `duration` (audio, seconds), `sentAt` (Timestamp), `status` (stored locally only — Firestore doesn't store sending/failed state).
- **Rationale**: Mirrors the `ChatModel` pattern. Uses plain Dart 3 class with `fromFirestore` factory — no Freezed/build_runner per CLAUDE.md §B-2.
- **Alternatives considered**: Storing status in Firestore — rejected; optimistic UI is simpler and avoids extra writes.

## Decision 5: No Freezed — Dart 3 Sealed Classes
- **Decision**: All Cubit states use `sealed class` + exhaustive `switch` expressions (Dart 3 native).
- **Rationale**: CLAUDE.md §B-2 explicitly forbids Freezed and build_runner. The existing code that uses Freezed (legacy files) will not be touched.
- **Alternatives considered**: Freezed — explicitly prohibited.

## Decision 6: File Size Limit Enforcement
- **Decision**: Enforce 25 MB limit in the data source before upload begins. Use `File.length()` to check synchronously.
- **Rationale**: Fail fast at the boundary; no wasted upload bandwidth.

## Decision 7: Audio Recording
- **Decision**: Use `record` package (already a common choice for Flutter audio recording) for in-chat voice recording. The recorded file is saved to a temp path, then uploaded to Supabase.
- **Rationale**: Simple API, cross-platform. If `record` is not yet in pubspec.yaml it needs to be added (only addition needed).
- **Alternatives considered**: `flutter_sound` — heavier, more complex API.

## Decision 8: Firestore Path for Messages
- **Decision**: Messages stored at `chats/{chatId}/messages/{messageId}` (sub-collection of the existing chat document).
- **Rationale**: Natural sub-collection; matches `messagesCollection = 'messages'` constant already defined in `fierstore_paths.dart`. Enables Firestore security rules scoped per chat.
- **Alternatives considered**: Top-level `messages` collection with `chatId` field — rejected; sub-collections are idiomatic and already anticipated by the existing path constants.

## Decision 9: Existing Upload Infrastructure Reuse
- **Decision**: Do NOT reuse `UploadImageCubit` from `core/app/upload_image/` for chat media. Create a dedicated `SendMessageCubit` that handles the full "pick → upload → send" flow internally.
- **Rationale**: `UploadImageCubit` is designed for profile/product image uploads with a different state shape (multi-image lists, storagePath vs URL). Reusing it would couple unrelated concerns. The upload logic in `SendMessageCubit` is simple enough not to warrant shared infrastructure.
- **Alternatives considered**: Extending `UploadImageCubit` — rejected; would add complexity to a shared core component for feature-specific needs.
