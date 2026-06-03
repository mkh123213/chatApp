# Implementation Plan: Single Chat Feature

**Branch**: `005-single-chat-feature` | **Date**: 2026-05-07 | **Spec**: [spec.md](spec.md)

## Summary

Complete single chat feature for one-to-one messaging. Extends existing codebase with: message edit/delete, image/file message sending via Supabase Storage, `lastMessageType` tracking, and improved message model fields. Existing `ChatsCubit`, `CreateChatCubit`, `ChatModel`, chats data source, and repo are reused and extended.

## Technical Context

**Language/Version**: Dart 3+ / Flutter  
**Primary Dependencies**: Cubit/Bloc, Freezed, GetIt, json_serializable, ScreenUtil  
**Storage**: Cloud Firestore (data), Supabase Storage (media files)  
**Testing**: Flutter test  
**Target Platform**: Android, iOS  
**Project Type**: Mobile app  

## Constitution Check

Constitution not configured — no gates to enforce.

## Project Structure

### Documentation

```text
specs/005-single-chat-feature/
├── plan.md
├── spec.md
├── research.md
├── data-model.md
└── checklists/
    └── requirements.md
```

### Source Code (files to modify/create)

```text
lib/features/single_chat/
├── data/
│   ├── models/
│   │   ├── chat_model.dart              # MODIFY: add lastMessageType, updatedAt
│   │   ├── chat_model.g.dart            # REGENERATE
│   │   └── message_model.dart           # REWRITE: match spec fields, add @JsonSerializable
│   ├── datasources/
│   │   ├── chats_remote_data_source.dart    # EXISTS: no changes needed
│   │   └── messages_remote_data_source.dart # MODIFY: add edit, delete, image/file send
│   └── repositories/
│       ├── chats_repo.dart                  # EXISTS: no changes needed
│       └── messages_repo_impl.dart          # MODIFY: add edit, delete, image/file send
├── domain/
│   ├── repositories/
│   │   └── messages_repo.dart               # MODIFY: add edit, delete, image/file send
│   └── use_cases/                           # REMOVE: thin wrappers, cubits use repo directly
├── presentation/
│   ├── bloc/
│   │   ├── get_chatss/
│   │   │   ├── chats_cubit.dart             # MODIFY: fix search (see below)
│   │   │   ├── chats_state.dart             # EXISTS: no changes
│   │   │   └── chats_cubit.freezed.dart     # REGENERATE
│   │   ├── create_chat_cubit/
│   │   │   ├── create_chat_cubit.dart       # EXISTS: no changes needed
│   │   │   ├── create_chat_state.dart       # EXISTS: no changes
│   │   │   └── create_chat_cubit.freezed.dart # EXISTS
│   │   ├── messages_cubit/
│   │   │   ├── messages_cubit.dart          # MODIFY: remove use case dependency, use repo
│   │   │   └── messages_state.dart          # EXISTS: no changes
│   │   └── send_message_cubit/
│   │       ├── send_message_cubit.dart      # MODIFY: add edit, delete, image/file send
│   │       └── send_message_state.dart      # MODIFY: add states for edit, delete
│   ├── screens/
│   │   ├── chat_home_screen.dart            # EXISTS: no changes needed
│   │   └── single_chat_screen.dart          # MODIFY: add edit/delete message actions
│   └── widgets/
│       ├── message_bubble.dart              # MODIFY: add long-press, edit/delete, isEdited indicator
│       ├── message_input_bar.dart           # MODIFY: add attachment button for image/file
│       ├── messages_list_view.dart          # EXISTS: may need minor updates
│       ├── chat_list_view.dart              # EXISTS: no changes
│       ├── create_chat_bottom_sheet.dart     # EXISTS: no changes
│       ├── create_chat_bloc_consumer.dart    # EXISTS: no changes
│       ├── chats_scereen_bloc_consumer.dart  # EXISTS: no changes
│       ├── attachment_bottom_sheet.dart      # EXISTS: update for image/file only (remove audio)
│       ├── image_message_widget.dart         # EXISTS: no changes
│       ├── file_message_widget.dart          # EXISTS: no changes
│       ├── edit_message_dialog.dart          # CREATE: dialog for editing text messages
│       └── delete_message_dialog.dart        # CREATE: confirmation dialog for deleting messages
```

## 1. ChatModel Changes

Add to `chat_model.dart`:
```dart
final String? lastMessageType;   // "text", "image", "file"
final DateTime? updatedAt;       // with same Timestamp converter
```

Update constructor, `fromJson`, `toJson`, `fromFirestore`.

## 2. MessageModel Rewrite

Replace current `MessageModel` with spec-aligned version using `@JsonSerializable()`:

| Field | Type | Notes |
|-------|------|-------|
| id | String | auto-generated doc ID |
| chatId | String | parent chat |
| senderId | String | current user uid |
| senderEmail | String | current user email |
| receiverId | String | friend uid |
| text | String | message body (empty for media) |
| type | String | "text", "image", "file" |
| mediaUrl | String | Supabase public URL (empty for text) |
| storagePath | String | Supabase path for deletion (empty for text) |
| fileName | String | original file name (empty for text) |
| createdAt | DateTime | Timestamp converter |
| updatedAt | DateTime | Timestamp converter |
| isEdited | bool | default false |

Keep `fromFirestore` factory and Timestamp converters from existing pattern.

## 3. Stable Chat ID Generation

Already implemented in `chats_remote_data_source.dart` lines 124-130:
```dart
String createChatId({required String currentUserId, required String friendId}) {
  final ids = [currentUserId, friendId]..sort();
  return ids.join('_');
}
```

No changes needed.

## 4. MessagesRemoteDataSource Extensions

Add to `MessagesRemoteDataSource` abstract class and impl:

```dart
Future<void> sendImageMessage({
  required String chatId,
  required String senderId,
  required String senderEmail,
  required String receiverId,
  required File imageFile,
});

Future<void> sendFileMessage({
  required String chatId,
  required String senderId,
  required String senderEmail,
  required String receiverId,
  required File file,
  required String originalFileName,
});

Future<void> updateMessage({
  required String chatId,
  required String messageId,
  required String text,
});

Future<void> deleteMessage({
  required String chatId,
  required String messageId,
  required String storagePath,
});
```

**Implementation details**:
- `sendImageMessage`: Use `sl<SupabaseStorageService>().uploadChatImage()`, then save message with `type: "image"`, `mediaUrl: uploadResult.url`, `storagePath: uploadResult.storagePath`
- `sendFileMessage`: Use `sl<SupabaseStorageService>().uploadChatFile()`, same pattern
- `updateMessage`: Use `_dataBaseService.setData()` with `merge: true` to update `text`, `isEdited: true`, `updatedAt: Timestamp.now()`
- `deleteMessage`: Use `_dataBaseService.deleteData()` for the message doc. If `storagePath` is non-empty, call `sl<SupabaseStorageService>().removeFile()`
- All send methods must also call `updateChatLastMessage` after saving the message

**Update `updateChatLastMessage`** to include `lastMessageType`:
```dart
Future<void> updateChatLastMessage({
  required String chatId,
  required String lastMessage,
  required String lastMessageType,
  required DateTime time,
});
```

## 5. MessagesRepo Extensions

Mirror all new `MessagesRemoteDataSource` methods. Pure delegation.

## 6. Cubit Changes

### ChatsCubit (minor fix)

Current bug at line 91-92: emits `searchEmpty` then immediately emits `loaded`, which overrides the empty state. Fix: remove the second emit.

```dart
// BEFORE (buggy):
if (filteredChats.isEmpty) {
  emit(const ChatsState.searchEmpty());
  emit(ChatsState.loaded(chats: _allChats)); // ← removes empty state
}

// AFTER (fixed):
if (filteredChats.isEmpty) {
  emit(const ChatsState.searchEmpty());
}
```

Also add `isClosed` guards to stream listener (same pattern as status cubits).

### MessagesCubit

- Remove `GetMessagesUseCase` dependency, use `MessagesRepo` directly
- Add `isClosed` guard to stream listener

### SendMessageCubit

Extend to handle all message operations:

**New states** (add to `send_message_state.dart`):
```dart
@freezed
class SendMessageState with _$SendMessageState {
  const factory SendMessageState.initial() = _Initial;
  const factory SendMessageState.sending() = _Sending;
  const factory SendMessageState.sent() = _Sent;
  const factory SendMessageState.error({required String message}) = _Error;
  const factory SendMessageState.editing() = _Editing;
  const factory SendMessageState.edited() = _Edited;
  const factory SendMessageState.deleting() = _Deleting;
  const factory SendMessageState.deleted() = _Deleted;
}
```

**New methods**:
```dart
Future<void> sendTextMessage({required ChatModel chat, required String text})
Future<void> sendImageMessage({required ChatModel chat, required File imageFile})
Future<void> sendFileMessage({required ChatModel chat, required File file, required String originalFileName})
Future<void> updateMessage({required String chatId, required String messageId, required String text})
Future<void> deleteMessage({required String chatId, required String messageId, required String storagePath})
```

## 7. Search & Clear Search Design

Already implemented in `ChatsCubit`:
- `searchChats()`: filters `_allChats` by email match (client-side)
- `clearSearch()`: emits `loaded` with full `_allChats`
- Search UI in `MainAppBar` opens `SearchDialog`

**Fix needed**: Remove the double-emit bug in search empty case.

## 8. Pull to Refresh Design

Add `refreshChats` method to `ChatsCubit`:
```dart
void refreshChats({required String currentUserId}) {
  _isListeningToChats = false;
  _chatsSubscription?.cancel();
  getChats(currentUserId: currentUserId);
}
```

Wrap `ChatHomeBody`'s list in `RefreshIndicator` and call `refreshChats` on pull.

## 9. GetIt Registration

Update `_initChats()` in `injection_container.dart`:

```dart
// ADD these registrations:
..registerLazySingleton<MessagesRemoteDataSource>(
  () => MessagesRemoteDataSourceImpl(
    dataBaseService: sl<DataBaseService>(),
  ),
)
..registerLazySingleton<MessagesRepo>(
  () => MessagesRepoImpl(
    messagesRemoteDataSource: sl<MessagesRemoteDataSource>(),
  ),
)
..registerFactory<MessagesCubit>(
  () => MessagesCubit(messagesRepo: sl<MessagesRepo>()),
)
..registerFactory<SendMessageCubit>(
  () => SendMessageCubit(
    messagesRepo: sl<MessagesRepo>(),
    storageService: sl<SupabaseStorageService>(),
  ),
)
```

**Remove** use case registrations (if any exist).

## 10. UI Flow

### ChatHomeScreen (EXISTS)
- Stack with `ChatHomeBody` + FAB
- FAB opens `CreateChatBottomSheet`
- No changes needed

### ChatHomeBody (EXISTS)
- Add `RefreshIndicator` wrapper
- No other changes needed

### SingleChatScreen (MODIFY)
- Already provides `MessagesCubit` and `SendMessageCubit` via `MultiBlocProvider`
- Update cubit constructors after removing use cases
- Add `BlocListener<SendMessageCubit>` for edit/delete success/error toasts

### MessageBubble (MODIFY)
- Add `onLongPress` → show context menu or selection mode
- Show edit/delete options only for own messages
- Show "edited" label when `isEdited == true`
- Edit available only for `type == "text"`
- Both edit and delete available for own messages

### MessageInputBar (MODIFY)
- Add attachment icon button
- On tap → show `AttachmentBottomSheet` (already exists, remove audio option)

### EditMessageDialog (CREATE)
```dart
Future<void> showEditMessageDialog({
  required BuildContext context,
  required MessageModel message,
})
```
- `CustomField` pre-filled with current text
- `CustomLinearButton` to confirm
- Calls `context.read<SendMessageCubit>().updateMessage()`

### DeleteMessageDialog (CREATE)
```dart
Future<void> showDeleteMessageDialog({
  required BuildContext context,
  required MessageModel message,
})
```
- Confirmation text using `context.translate(LangKeys.deleteMessage)`
- Calls `context.read<SendMessageCubit>().deleteMessage()`

## 11. Localization Keys

### New keys to add to `LangKeys`:
```dart
static const String messageDeletedSuccessfully = 'message_deleted_successfully';
static const String messageUpdatedSuccessfully = 'message_updated_successfully';
static const String deleteMessage = 'delete_message';
static const String editMessage = 'edit_message';
static const String updateMessage = 'update_message';
static const String onlyTextMessagesCanBeEdited = 'only_text_messages_can_be_edited';
static const String chatAlreadyExists = 'chat_already_exists';
static const String cannotCreateChatWithYourself = 'cannot_create_chat_with_yourself';
static const String noUserFoundWithThisEmail = 'no_user_found_with_this_email';
static const String edited = 'edited';
static const String image = 'image';
static const String file = 'file';
static const String attachFile = 'attach_file';
static const String attachImage = 'attach_image';
```

### Add to `lang/en.json`:
```json
"message_deleted_successfully": "Message deleted successfully",
"message_updated_successfully": "Message updated successfully",
"delete_message": "Delete Message",
"edit_message": "Edit Message",
"update_message": "Update",
"only_text_messages_can_be_edited": "Only text messages can be edited",
"chat_already_exists": "Chat already exists",
"cannot_create_chat_with_yourself": "Cannot create chat with yourself",
"no_user_found_with_this_email": "No user found with this email",
"edited": "edited",
"image": "Image",
"file": "File",
"attach_file": "Attach File",
"attach_image": "Attach Image"
```

### Add to `lang/ar.json`:
```json
"message_deleted_successfully": "تم حذف الرسالة بنجاح",
"message_updated_successfully": "تم تعديل الرسالة بنجاح",
"delete_message": "حذف الرسالة",
"edit_message": "تعديل الرسالة",
"update_message": "تحديث",
"only_text_messages_can_be_edited": "يمكن تعديل الرسائل النصية فقط",
"chat_already_exists": "المحادثة موجودة بالفعل",
"cannot_create_chat_with_yourself": "لا يمكنك إنشاء محادثة مع نفسك",
"no_user_found_with_this_email": "لا يوجد مستخدم بهذا البريد الإلكتروني",
"edited": "تم التعديل",
"image": "صورة",
"file": "ملف",
"attach_file": "إرفاق ملف",
"attach_image": "إرفاق صورة"
```

## 12. Build Runner Commands

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generates:
- `chat_model.g.dart`
- `message_model.g.dart` (new)
- `chats_cubit.freezed.dart`
- `send_message_cubit.freezed.dart` (new states)

## 13. Testing Checklist

- [ ] Create chat with valid friend email → chat appears in list
- [ ] Create chat with own email → error toast
- [ ] Create duplicate chat → error toast
- [ ] Create chat with non-existent email → error toast
- [ ] Send text message → appears in real time, lastMessage updates
- [ ] Send image message → uploads to Supabase, appears with preview
- [ ] Send file message → uploads to Supabase, appears with file name
- [ ] Edit own text message → text updates, "edited" label shows
- [ ] Try to edit image/file message → edit option not available
- [ ] Delete own message (text) → message disappears
- [ ] Delete own message (image/file) → message disappears, storage file removed
- [ ] Try to delete other user's message → delete option not available
- [ ] Search by email → filtered results shown
- [ ] Search with no results → empty state
- [ ] Clear search → full list restored
- [ ] Pull to refresh → list reloads
- [ ] Navigate away and back → no "Cannot emit after close" errors
- [ ] Empty chat state → shows "no messages yet"
- [ ] Empty chats list → shows "no chats yet"

## 14. Common Mistakes to Avoid

1. **Don't mix cubit states**: `ChatsCubit` handles list only. `SendMessageCubit` handles send/edit/delete. `MessagesCubit` handles message stream.
2. **Don't forget `updateChatLastMessage`** after every send operation (text, image, file).
3. **Don't forget `isClosed` guards** in stream listeners to prevent "Cannot emit after close" errors.
4. **Don't use `FirebaseFirestore.instance` directly** except for generating document IDs — use `DataBaseService`.
5. **Don't create `TextEditingController` inside `build()`** — declare in `State` class and dispose.
6. **Don't forget to remove Supabase storage file** when deleting image/file messages.
7. **Don't register cubits as singletons** — use `registerFactory` so each screen gets a fresh instance.
8. **Don't forget to pass `settings`** in `BaseRoute` for routes that need arguments.
9. **Don't hardcode strings** — use `context.translate(LangKeys.key)` for all UI text.
10. **Don't forget `merge: true`** when updating chat document's lastMessage (partial update, not overwrite).
