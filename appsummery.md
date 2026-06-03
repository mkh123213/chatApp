# ALKHATEEB CHAT - App Summary

## Overview

**ALKHATEEB CHAT** (`chat_material3`) is a full-featured real-time messaging application built with **Flutter**. It supports one-on-one chats, group chats, voice/video calls, status stories, and an AI assistant. The app uses **Firebase** as the primary backend (Auth, Firestore, Messaging) with **Supabase** for file storage and serverless Edge Functions.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK >=3.3.0) |
| State Management | BLoC / Cubit (flutter_bloc, freezed) |
| Authentication | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore (real-time streams) |
| File Storage | Supabase Storage |
| Push Notifications | Firebase Cloud Messaging (FCM) via Supabase Edge Function |
| Voice/Video Calls | Agora RTC Engine |
| Call UI (native) | flutter_callkit_incoming |
| AI Assistant | Google Generative AI (Gemini 2.0 Flash) |
| DI | GetIt |
| Networking | Dio + Retrofit |
| Local Storage | Hive CE, SharedPreferences |
| Localization | Custom delegate (AR/EN) |
| UI | Material 3, ScreenUtil, animate_do, flutter_animate |

---

## Features

### 1. Authentication
- Email/password sign-up and login
- Google Sign-In
- Email verification
- Forgot password
- Profile setup on first login

### 2. Single Chat (1-on-1)
- Real-time text messaging
- Image, file, voice message, sticker, and GIF support
- Message editing and deletion
- Read receipts (isRead flag)
- Typing indicators (real-time)
- User presence / online status
- User blocking and unblocking
- Unread message count badges
- Contact info screen

### 3. Group Chat
- Create groups with multiple members
- Admin management (make/remove admin)
- Add members by email, remove members
- Group image upload
- Text + attachment messages (image, file, link)
- Message editing and deletion (batch)
- Read tracking (readBy array)
- Group info screen with media/links/docs viewer
- Creator can delete group; members can exit

### 4. Voice & Video Calls
- 1-on-1 audio and video calls via Agora RTC
- Agora token generation via Supabase Edge Function
- Native call UI with flutter_callkit_incoming (Android & iOS)
- Call states: ringing, accepted, rejected, ended, missed
- Call controls: mute, speaker, camera toggle, camera switch
- Call history (merged caller/receiver streams, sorted by date)
- Stale call auto-cleanup (ringing >60s, accepted >24h)
- Delete individual call records or entire history

### 5. Status / Stories
- Create text or image statuses
- View statuses from contacts
- My status management (view, delete)
- 24-hour auto-expiry pattern

### 6. AI Assistant
- Powered by Gemini 2.0 Flash
- Conversational chat session with memory
- General knowledge, jokes, advice, quotes

### 7. Profile Management
- Edit display name and profile photo
- Change password
- Dark mode toggle
- Language switch (Arabic/English)
- Notification preferences
- Do Not Disturb mode
- Blocked contacts management
- Logout

### 8. Push Notifications
- FCM token management (save/refresh/remove per user)
- Single chat message notifications (skipped if user has chat open)
- Group chat message notifications (sent to all members except sender, skipped if group is open)
- Call notifications (high priority)
- Delivered via Supabase Edge Function calling FCM v1 HTTP API
- Android notification channels: `chat-notifications`, `call-notifications`
- iOS: APNs with time-sensitive interruption for calls

### 9. Other
- Connectivity monitoring (no-network screen)
- QR code generation
- WebView integration
- Dynamic links
- Splash screen
- Environment variables (.env.dev / .env.prod)

---

## Architecture

```
lib/
  chat_app.dart              # App widget (MaterialApp, theme, locale, routing)
  main.dart                  # Initialization entry point
  constants/                 # Firestore paths, Agora, Giphy, Supabase, images
  core/
    app/                     # AppCubit, AuthCubit, upload image, unread messages
    common/                  # Shared widgets, dialogs, toast, bottom sheets
    di/                      # GetIt service locator
    enums/                   # Filter, nav bar enums
    extensions/              # Context, date, string extensions
    helper_functions/        # Current user, spacing, file open, photo cache
    language/                # Localization setup and delegates
    routes/                  # Named route definitions and generation
    service/                 # Core services (auth, call, connectivity, DnD, Firestore, Hive, notifications, etc.)
    style/                   # Theme (light/dark)
  features/
    ai_assistant/            # Gemini AI chat
    auth/                    # Login, sign-up, forgot password, verify email, setup profile
    calls/                   # Call data source, models, cubits, screens, widgets
    groups/                  # Group data source, models, cubits, screens, widgets
    main/                    # Main screen with bottom nav bar
    profile/                 # Profile, edit, blocked contacts, settings
    single_chat/             # 1-on-1 chat data sources, models, cubits, screens, widgets
    splash/                  # Splash screen
    status/                  # Status/stories data source, models, cubits, screens
supabase/
  functions/
    send-notification/       # FCM v1 push notification Edge Function
    agora-token/             # Agora RTC token generation Edge Function
```

---

## Enhancement Tips

### Performance
1. **Paginate messages**: Currently all messages are loaded via a single Firestore stream with no limit. Add cursor-based pagination (e.g., load 30 messages at a time, fetch more on scroll-up) to reduce bandwidth and memory usage for long conversations.
2. **Batch group notifications**: `sendGroupMessageNotification` fetches each member's document one-by-one in a loop. Move this logic to the Supabase Edge Function so the client sends a single request and the server fans out notifications.
3. **Cache user data locally**: User names and avatars are fetched repeatedly. Use Hive or an in-memory LRU cache to avoid redundant Firestore reads.
4. **Lazy-load media**: Use `CachedNetworkImage` with placeholder shimmer for all image messages and avatars to reduce initial load time.

### Security
5. **Firestore Security Rules**: Ensure rules validate that only chat participants can read/write messages, only group members can send group messages, and users can only modify their own data.
6. **Rate limiting on Edge Functions**: Add rate limiting to the `send-notification` Edge Function to prevent abuse.
7. **Validate FCM tokens server-side**: Before sending notifications, verify the token format and handle `UNREGISTERED` errors by cleaning up stale tokens.
8. **Encrypt sensitive data**: Consider encrypting message content at rest or implementing end-to-end encryption for sensitive conversations.

### User Experience
9. **Message search**: Add full-text search across conversations using Firestore composite indexes or a dedicated search service (e.g., Algolia, Typesense).
10. **Reply to messages**: Allow users to quote/reply to a specific message in both single and group chats.
11. **Message reactions**: Add emoji reactions to messages (a lightweight engagement feature).
12. **Link previews**: When a URL is detected in a message, fetch and display an Open Graph preview (title, description, image).
13. **Notification tap navigation**: When a user taps a push notification, deep-link directly to the relevant chat or group screen instead of just opening the app.
14. **Delivery status**: Add a "delivered" state (in addition to "sent" and "read") to give users confidence their messages arrived.

### Code Quality
15. **Remove `domain/` layer remnants**: `single_chat` still has `domain/repositories/messages_repo.dart` which violates the project architecture. Merge it into `data/repositories/`.
16. **Consistent naming**: Some files use `fierstore` (typo) instead of `firestore` — rename for clarity.
17. **Error handling**: Add structured error mapping for Firestore and Supabase errors instead of generic `try/catch` with `debugPrint`.
18. **Tests**: Add unit tests for cubits and data sources, and widget tests for critical screens.
19. **Remove unused imports/code**: Clean up commented-out code blocks in `injection_container.dart` and route files.

### Scalability
20. **Move business logic to backend**: Heavy operations like message fan-out for groups, call cleanup, and notification delivery should run on Cloud Functions or Supabase Edge Functions to reduce client load and ensure reliability even if the app is killed.
21. **Implement offline support**: Use Firestore's offline persistence and queue outgoing messages when the user has no connectivity, syncing when back online.
22. **Status auto-cleanup**: Use a Cloud Function with a scheduled trigger to delete expired statuses instead of relying on client-side filtering.
