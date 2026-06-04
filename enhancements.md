# Enhancement Roadmap — ALKHATEEB CHAT

Prioritized improvements organized by impact. Each item includes what to do, why it matters, and estimated effort.

---

## Priority 1: Critical Fixes (Do First)

### 1. Paginate Messages
**Current**: `getMessages()` streams ALL messages in a chat with no limit. A chat with 5,000 messages loads them all into memory at once.
**Fix**: Add cursor-based pagination — load 30 messages initially, fetch more on scroll-up using `.startAfterDocument()`.
**Why**: Without this, the app will crash or freeze on long conversations.
**Files**: `messages_remote_data_source.dart`, `messages_cubit.dart`, `messages_list_view.dart`
**Effort**: Medium

### 2. Paginate Group Messages
**Current**: Same problem as single chat — all group messages streamed at once.
**Fix**: Same cursor-based pagination approach.
**Files**: `groups_remote_data_source.dart`, `selected_group_chat_cubit.dart`
**Effort**: Medium

### 3. Firestore Security Rules
**Current**: Likely using default or permissive rules. Any authenticated user could read/write any document.
**Fix**: Write rules that enforce:
- Only chat participants can read/write messages in their chat
- Only group members can read/write group messages
- Users can only modify their own user document
- Block documents can only be created/deleted by the blocker
- Call documents can only be modified by caller or receiver
**Why**: Without this, any user with a Firebase token can access all data.
**Effort**: Medium

### 4. Remove Hardcoded Supabase Service Role Key
**Current**: `main.dart` line 49 uses a Supabase `service_role` key as `anonKey`. The service role key bypasses all Row Level Security.
**Fix**: Replace with the actual `anon` key from Supabase dashboard. Then set up proper RLS policies on the `chatapp` storage bucket.
**Why**: Anyone who decompiles the APK gets full unrestricted access to your Supabase storage.
**Effort**: Low

### 5. Move Agora App ID to Environment Variable
**Current**: `agora_constants.dart` has the App ID hardcoded. Not a secret, but bad practice.
**Fix**: Move to `.env.dev` / `.env.prod` and load via `EnvVariable`.
**Files**: `agora_constants.dart`, `env_variable.dart`, `.env.dev`, `.env.prod`
**Effort**: Low

---

## Priority 2: Performance

### 6. Cache User Profiles Locally
**Current**: Every notification send fetches the receiver's document from Firestore. Group notifications fetch N documents (one per member) in a loop.
**Fix**: Cache user name/photo/fcmToken in an in-memory LRU map or Hive box. Invalidate on changes via a lightweight Firestore listener.
**Why**: Reduces Firestore reads significantly, especially in active groups.
**Effort**: Medium

### 7. Batch Group Notifications Server-Side
**Current**: `sendGroupMessageNotification` loops through members and calls the Edge Function once per member.
**Fix**: Create a new Edge Function `send-group-notification` that accepts `memberIds` array and fans out notifications server-side in one request.
**Why**: Sending 20 HTTP requests from the client for a 20-member group is slow and unreliable (app could be killed mid-loop).
**Effort**: Medium

### 8. Lazy Load Chat List
**Current**: All chats are loaded via a single stream with no limit.
**Fix**: Initially load 20 most recent chats, paginate on scroll. Use `lastMessageTime` for ordering.
**Effort**: Medium

### 9. Image Compression Before Upload
**Current**: Images are uploaded at original resolution.
**Fix**: Compress images before upload (e.g., resize to max 1200px, 80% JPEG quality) using `flutter_image_compress`.
**Why**: Reduces upload time, storage cost, and download time for receivers.
**Effort**: Low

### 10. Thumbnail Generation for Images
**Current**: Full-size images are loaded in chat list previews.
**Fix**: Generate a small thumbnail (200px) on upload and store its URL in the message. Show thumbnail in list, full image on tap.
**Why**: Chat list scrolling will be much smoother.
**Effort**: Medium

---

## Priority 3: Features That Users Expect

### 11. Forward Messages
**What**: Long-press a message → "Forward" → pick a chat or group → send the message there.
**How**: Copy the message content to the target chat. For media, reuse the same `mediaUrl` (don't re-upload).
**Effort**: Medium

### 12. Message Reactions (Emoji)
**What**: Long-press a message → show emoji bar (like/love/laugh/sad/angry). Store as a map `reactions: { "userId": "emoji" }` on the message document.
**Display**: Small emoji chips below the message bubble with count.
**Effort**: Medium

### 13. Link Preview in Messages
**What**: When a message contains a URL, fetch Open Graph metadata (title, description, image) and show a preview card.
**How**: Use `any_link_preview` or `url_launcher` + metadata fetch. Cache previews to avoid re-fetching.
**Effort**: Medium

### 14. Message Search Within Chat
**What**: Search icon in chat app bar → search messages in the current conversation.
**How**: Firestore doesn't support full-text search natively. Options:
- Client-side filter on loaded messages (only works if all messages are loaded)
- Algolia / Typesense integration for real full-text search
- Simple `where('text', isGreaterThanOrEqualTo: query)` for prefix matching
**Effort**: Medium-High

### 15. Notification Tap Deep Linking
**Current**: Notifications likely open the app's main screen regardless of the notification type.
**Fix**: Read `data.route` and `data.chatId`/`data.groupId`/`data.callId` from the notification payload and navigate to the correct screen.
**Files**: `firebase_messaging_navigate.dart`, `pending_navigation_service.dart`
**Effort**: Medium

### 16. Delivered Status (Double Check)
**Current**: Messages have `isRead` but no "delivered" state. Users see either "sent" (single check) or "read" (blue checks).
**Fix**: Add `isDelivered` field. Set it to `true` when the receiver's device receives the message (via FCM data-only notification or on app open).
**Display**: Single gray check → double gray check (delivered) → double blue check (read).
**Effort**: Medium

### 17. Voice/Video Call for Groups
**Current**: Calls are 1-on-1 only.
**Fix**: Create a group call model with multiple participants. Each participant gets their own Agora token and joins the same channel.
**Complexity**: High — needs UI for multiple video feeds, participant management, and call state for N users.
**Effort**: High

---

## Priority 4: Code Quality & Architecture

### 18. Remove `domain/` Layer Violation
**Current**: `single_chat` has `domain/repositories/messages_repo.dart` — an abstract interface that violates the project's architecture (no `domain/` layer allowed).
**Fix**: Move the abstract class into `data/repositories/` or inline it into the impl.
**Files**: `lib/features/single_chat/domain/repositories/messages_repo.dart`
**Effort**: Low

### 19. Fix Typo: `fierstore` → `firestore`
**Current**: Multiple files use `fierstore` in names and paths:
- `constants/fierstore_paths.dart`
- `core/service/fierstore/firestore_service.dart`
- `auth_service_fierbase`
**Fix**: Rename files and update all imports. Do a project-wide find-replace.
**Effort**: Low (but touches many files)

### 20. Structured Error Handling
**Current**: Most data sources use `try/catch` with `debugPrint`. Errors are lost or shown as raw exception messages.
**Fix**: Create an `AppException` hierarchy (e.g., `NetworkException`, `AuthException`, `StorageException`). Map Firebase/Supabase errors to these in data sources. Cubits emit error keys. UI translates keys to user-friendly messages.
**Effort**: Medium

### 21. Unit Tests for Cubits
**Current**: No tests.
**Fix**: Add unit tests for critical cubits:
- `MessagesCubit` — message loading, sending, deleting
- `ActiveCallCubit` — call state transitions
- `AuthCubit` — login, signup, error handling
- `ChatsCubit` — chat list loading, search
**How**: Mock data sources using `mocktail`. Test state emissions with `bloc_test`.
**Effort**: Medium-High

### 22. Widget Tests for Critical Screens
**Fix**: Test key screens:
- `LoginScreen` — form validation, error display
- `MessageBubble` — renders correctly for each message type
- `CallControls` — button states for audio vs video
**Effort**: Medium

### 23. Clean Up Dead Code
**Current**: `injection_container.dart` has commented-out registrations. Route file has unused imports. Some files have Windsurf command comments.
**Fix**: Remove all commented-out code, unused imports, and tool-generated comments.
**Effort**: Low

---

## Priority 5: Scalability & Backend

### 24. Move Notification Fan-Out to Server
**Current**: The Flutter client loops through group members and sends individual notification requests.
**Fix**: Create a Supabase Edge Function that accepts `groupId` + `senderId` + `message`, fetches members from Firestore, and fans out notifications server-side.
**Why**: Reliable even if the sender's app is killed. Faster. Fewer client-side Firestore reads.
**Effort**: Medium

### 25. Server-Side Stale Call Cleanup
**Current**: Stale calls are cleaned up client-side in `hasActiveCallBetweenUsers()` — only triggers when someone tries to start a new call.
**Fix**: Create a scheduled Cloud Function / Supabase cron that runs every 5 minutes and cleans up calls stuck in `ringing` for >60s or `accepted` for >24h.
**Why**: Without this, orphaned calls accumulate silently.
**Effort**: Low-Medium

### 26. Status Auto-Expiry via Server
**Current**: Expired statuses are filtered client-side using `expiresAt`. Documents remain in Firestore forever.
**Fix**: Scheduled Cloud Function that deletes statuses where `expiresAt < now()` and removes their images from Supabase Storage.
**Why**: Saves storage cost and keeps Firestore clean.
**Effort**: Low-Medium

### 27. Firestore Offline Persistence
**Current**: No explicit offline support. If the user loses connectivity, messages can't be sent.
**Fix**: Enable Firestore offline persistence (it's on by default for Android/iOS but verify). Queue outgoing messages locally and sync when back online. Show "sending..." indicator.
**Effort**: Low-Medium

### 28. Rate Limiting on Edge Functions
**Current**: No rate limiting. A malicious user could spam the `send-notification` function.
**Fix**: Add IP-based or token-based rate limiting in the Edge Function (e.g., max 60 requests per minute per token).
**Effort**: Low

---

## Priority 6: Nice to Have

### 29. End-to-End Encryption (E2EE)
**What**: Encrypt message content so that even Firebase/Supabase admins can't read messages.
**How**: Use Signal Protocol or a simpler approach with per-chat key pairs. Store encrypted text in Firestore.
**Complexity**: Very High — key exchange, multi-device support, key rotation.
**Effort**: Very High

### 30. Video/Image Status (Stories)
**Current**: Status supports text and image. No video.
**Fix**: Add video upload + playback for statuses. Use `video_player` package.
**Effort**: Medium

### 31. Location Sharing
**What**: Share current location as a message type. Show a mini-map preview in the chat.
**How**: Use `geolocator` for location, `google_maps_flutter` or static map image for preview.
**Effort**: Medium

### 32. Custom Chat Themes Per Conversation
**Current**: Global wallpaper applies to all chats.
**Fix**: Let users set wallpaper per chat/group. Store in the chat document or locally.
**Effort**: Low

### 33. Scheduled Messages
**What**: Type a message → long-press send → pick date/time → message sends automatically at that time.
**How**: Store scheduled messages locally or in Firestore. Use a background worker or Cloud Function to send at the scheduled time.
**Effort**: Medium-High

### 34. Message Pinning in Groups
**What**: Admins can pin important messages in a group. Pinned messages appear in a banner at the top of the chat.
**How**: Add `pinnedMessageId` field to group document. Show a dismissible banner with the pinned message.
**Effort**: Low-Medium

### 35. Polls in Groups
**What**: Create a poll with question + options. Members vote. Results shown in real-time.
**How**: New message type `poll` with a sub-document for options and votes.
**Effort**: Medium

### 36. Audio/Video Recording in Chat
**Current**: Voice messages exist. No video messages.
**Fix**: Add video recording via camera. Compress and upload like voice messages.
**Effort**: Medium

---

## Quick Wins (Can Do in Under 2 Hours Each)

| # | Enhancement | Effort |
|---|------------|--------|
| 5 | Move Agora App ID to env | 30 min |
| 9 | Image compression before upload | 1 hour |
| 18 | Remove `domain/` layer violation | 30 min |
| 23 | Clean up dead code | 1 hour |
| 28 | Rate limiting on Edge Functions | 1 hour |
| 32 | Per-chat wallpaper | 1-2 hours |
