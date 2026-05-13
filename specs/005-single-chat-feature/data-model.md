# Data Model: Single Chat Feature

**Branch**: `005-single-chat-feature` | **Date**: 2026-05-07

## Firestore Structure

### Collection: `chats`

```
chats/{chatId}
  id: String (chatId = sorted UIDs joined with "_")
  users: List<String> [currentUserUid, friendUid]
  usersEmails: List<String> [current@email.com, friend@email.com]
  lastMessage: String
  lastMessageType: String ("text" | "image" | "file")
  lastMessageTime: Timestamp
  createdAt: Timestamp
  updatedAt: Timestamp
```

**Stable Chat ID Rule**: `[uid1, uid2].sort().join('_')` — guarantees uniqueness and prevents duplicates.

### Subcollection: `chats/{chatId}/messages`

```
chats/{chatId}/messages/{messageId}
  id: String (auto-generated)
  chatId: String
  senderId: String (uid)
  senderEmail: String
  receiverId: String (friend uid)
  text: String
  type: String ("text" | "image" | "file")
  mediaUrl: String (empty for text)
  storagePath: String (empty for text, Supabase path for media)
  fileName: String (empty for text, original name for files)
  createdAt: Timestamp
  updatedAt: Timestamp
  isEdited: bool (default false)
```

**Query**: `orderBy('createdAt', descending: true).limit(50)`

## Supabase Storage Paths

```
chatapp/chats/{chatId}/messages/images/{timestamp}.{ext}   → image messages
chatapp/chats/{chatId}/messages/files/{timestamp}_{name}    → file messages
```

Uses existing `SupabaseStorageService.uploadChatImage()` and `uploadChatFile()`.

## Dart Models

### ChatModel (existing — needs extension)

Add fields:
- `lastMessageType: String?`
- `updatedAt: DateTime?`

File: `lib/features/single_chat/data/models/chat_model.dart`

### MessageModel (existing — needs rewrite to match spec)

Current fields (`content`, `sentAt`, `fileSize`, `duration`) need renaming/replacing to match the spec structure:

```dart
@JsonSerializable()
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String text;
  final String type;        // "text", "image", "file"
  final String mediaUrl;
  final String storagePath;
  final String fileName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
}
```

File: `lib/features/single_chat/data/models/message_model.dart`

## Entity Relationships

```
CurrentUser (from SharedPreferences)
    │
    ├── has many → Chat (via users array contains uid)
    │                 │
    │                 └── has many → Message (subcollection)
    │
    └── identified by → uid, email, name, photoUrl
```
