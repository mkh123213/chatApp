# Research: Single Chat Feature

**Branch**: `005-single-chat-feature` | **Date**: 2026-05-07

## Existing Codebase Analysis

### Decision: Reuse existing data layer vs. rebuild
- **Chosen**: Extend existing code — the project already has `ChatsRemoteDataSource`, `MessagesRemoteDataSource`, `ChatsRepo`, `ChatModel`, `MessageModel`, `ChatsCubit`, `CreateChatCubit`, `MessagesCubit`, `SendMessageCubit`
- **Rationale**: Existing code covers ~70% of the spec. Missing: edit/delete messages, `lastMessageType` field, `isEdited`/`isDeleted` fields on messages, `senderEmail`/`receiverId`/`storagePath`/`fileName` on messages, file/image upload integration in messages data source
- **Alternatives**: Full rewrite — rejected as wasteful given solid existing foundation

### Decision: Message deletion strategy
- **Chosen**: Hard delete from Firestore + remove storage file if applicable
- **Rationale**: One-to-one chat has no need to preserve deleted messages for other viewers. Reduces storage costs and query complexity.
- **Alternatives**: Soft delete (`isDeleted: true`) — adds query overhead and UI complexity for placeholder display

### Decision: Search approach
- **Chosen**: Client-side filtering of cached `_allChats` list (already implemented in `ChatsCubit`)
- **Rationale**: Already working. Chat volumes per user are small enough that client-side filtering is performant.
- **Alternatives**: Server-side Firestore text search — Firestore lacks full-text search; would need Algolia or similar

### Decision: Message model fields
- **Chosen**: Extend `MessageModel` to add `senderEmail`, `receiverId`, `mediaUrl`, `storagePath`, `fileName`, `isEdited`, `updatedAt`. Remove `isDeleted` (hard delete). Rename `content` → `text` and `sentAt` → `createdAt` to match spec.
- **Rationale**: Aligns with spec's Firestore structure and enables edit/delete features
- **Alternatives**: Keep existing field names — creates inconsistency with spec and Firestore documents

### Decision: Chat model fields
- **Chosen**: Add `lastMessageType` and `updatedAt` to `ChatModel`
- **Rationale**: Required by spec to display message type indicators and track updates

### Decision: Storage paths for single chat
- **Chosen**: Use existing `SupabaseStorageService.uploadChatImage()` and `uploadChatFile()` methods which use paths `chats/{chatId}/messages/images/{timestamp}.ext` and `chats/{chatId}/messages/files/{timestamp}_{name}`
- **Rationale**: Already implemented and consistent with the storage service pattern
- **Alternatives**: Create new methods — unnecessary, existing ones work perfectly

### Decision: Domain layer use cases
- **Chosen**: Remove use case layer, have cubits depend directly on repos/data sources as per existing `ChatsCubit` and `CreateChatCubit` patterns
- **Rationale**: Existing `ChatsCubit` and `CreateChatCubit` already bypass use cases and depend on repos. The `MessagesCubit` uses a use case but it's a thin wrapper. For consistency and simplicity, follow the majority pattern.
- **Alternatives**: Add use cases for all operations — adds indirection without business logic justification

### Decision: Selected chat screen structure
- **Chosen**: `SingleChatScreen` is a standalone route with its own `Scaffold` (already exists this way)
- **Rationale**: It's navigated to via `Navigator.pushNamed` with a `ChatModel` argument, not embedded in MainScreen tabs
