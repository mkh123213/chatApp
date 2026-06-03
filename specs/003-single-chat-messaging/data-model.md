# Data Model: Single Chat Messaging

## Firestore Schema

### Collection: `chats/{chatId}`
Existing document — no schema changes needed.

Fields updated by this feature:
- `lastMessage` (String) — updated to message content or "[Image]" / "[Audio]" / "[File: name]" after each send
- `lastMessageTime` (Timestamp) — updated after each send

### Sub-collection: `chats/{chatId}/messages/{messageId}`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | String | Yes | Firestore document ID |
| `chatId` | String | Yes | Parent chat ID |
| `senderId` | String | Yes | UID of sender |
| `type` | String | Yes | `"text"` \| `"image"` \| `"audio"` \| `"file"` |
| `content` | String | Yes | Text body OR Supabase public URL for media |
| `fileName` | String | No | Original filename for audio/file types |
| `fileSize` | int | No | Bytes; populated for file/image types |
| `duration` | int | No | Audio duration in seconds |
| `sentAt` | Timestamp | Yes | Server timestamp |

### Firestore Path Constants (add to `fierstore_paths.dart`)
```dart
// Already exists:
const String messagesCollection = 'messages';
// Already exists:
const String chatsCollection = 'chats';
```
Message path helper: `'$chatsCollection/$chatId/$messagesCollection'`

## Dart Models

### `MessageModel`
Location: `lib/features/single_chat/data/models/message_model.dart`

```
MessageModel {
  id: String
  chatId: String
  senderId: String
  type: MessageType   // sealed/enum: text, image, audio, file
  content: String
  fileName: String?
  fileSize: int?
  duration: int?
  sentAt: DateTime
}
```

Factory: `MessageModel.fromFirestore(id, data)` — mirrors `ChatModel.fromFirestore`.
Serialization: `toJson()` — outputs Firestore-compatible map with `Timestamp` for `sentAt`.

### `MessageType` (enum)
```dart
enum MessageType { text, image, audio, file }
```

## Supabase Storage Paths

| Media Type | Path |
|-----------|------|
| Image | `chats/{chatId}/messages/images/{timestamp}.{ext}` |
| Audio | `chats/{chatId}/messages/audio/{timestamp}.m4a` |
| File | `chats/{chatId}/messages/files/{timestamp}_{safeName}` |

New methods on `SupabaseStorageService`:
- `uploadChatImage({chatId, file})` → `UploadedFileData`
- `uploadChatAudio({chatId, file})` → `UploadedFileData`
- `uploadChatFile({chatId, file, originalFileName})` → `UploadedFileData`

## State Models (Dart 3 Sealed Classes)

### `MessagesState` — for `MessagesCubit`
```dart
sealed class MessagesState {
  const MessagesState();
}
class MessagesInitial extends MessagesState { const MessagesInitial(); }
class MessagesLoading extends MessagesState { const MessagesLoading(); }
class MessagesLoaded extends MessagesState {
  const MessagesLoaded(this.messages);
  final List<MessageModel> messages;
}
class MessagesError extends MessagesState {
  const MessagesError(this.message);
  final String message;
}
```

### `SendMessageState` — for `SendMessageCubit`
```dart
sealed class SendMessageState {
  const SendMessageState();
}
class SendMessageInitial extends SendMessageState { const SendMessageInitial(); }
class SendMessageLoading extends SendMessageState { const SendMessageLoading(); }
class SendMessageSuccess extends SendMessageState { const SendMessageSuccess(); }
class SendMessageError extends SendMessageState {
  const SendMessageError(this.message);
  final String message;
}
```

## Validation Rules

- `content` must not be blank for text messages
- File/image/audio must be ≤ 25 MB (26,214,400 bytes)
- `chatId` must not be empty
- `senderId` must not be empty
