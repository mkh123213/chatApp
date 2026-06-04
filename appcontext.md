# App Context — ALKHATEEB CHAT

## Identity

- **App Name**: ALKHATEEB CHAT
- **Package Name**: `chat_material3`
- **Android Application ID**: `com.example.chat_material3`
- **Platform**: Flutter (Android + iOS)
- **Dart SDK**: >=3.3.0 <4.0.0
- **Localization**: Arabic (primary) + English
- **Font**: Poppins (Regular, Medium, Bold)

---

## What This App Does

A real-time messaging app with one-on-one chats, group chats, voice/video calls, disappearing statuses (stories), and an AI assistant. Similar in scope to WhatsApp but built as a learning/portfolio project.

---

## Backend Architecture

The app uses a **hybrid backend** — Firebase for auth, database, and messaging; Supabase for file storage and serverless functions.

```
┌─────────────────────────────────────────────────────────┐
│                     Firebase                             │
│                                                         │
│  Auth         → Email/password, Google Sign-In          │
│  Firestore    → Users, chats, messages, groups, calls,  │
│                 statuses, blocks, notifications          │
│  FCM          → Push notification delivery               │
│  Analytics    → Usage tracking                           │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                     Supabase                             │
│                                                         │
│  Storage      → All file uploads (images, files, audio) │
│  Edge Funcs   → send-notification (FCM v1 API)          │
│                 agora-token (Agora RTC token gen)        │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                     Agora                                │
│                                                         │
│  RTC Engine   → Real-time voice and video calls         │
│  App ID       → f12ce546beab424788857fd05ce38187        │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                     Google AI                            │
│                                                         │
│  Gemini 2.0 Flash → AI assistant chatbot                │
└─────────────────────────────────────────────────────────┘
```

### Why Two Backends?

| Need | Firebase | Supabase | Choice |
|------|----------|----------|--------|
| Auth | Firebase Auth | Supabase Auth | **Firebase** — already integrated, Google Sign-In |
| Real-time DB | Firestore streams | Supabase Realtime | **Firestore** — simpler for nested collections |
| File storage | Firebase Storage (paid) | Supabase Storage (free tier generous) | **Supabase** — cheaper |
| Push notifications | FCM (needs server key) | — | **Supabase Edge Function** calls FCM v1 API |
| Serverless functions | Cloud Functions (needs Blaze plan) | Edge Functions (free) | **Supabase** — free, Deno-based |

---

## Firestore Data Model

```
Firestore
│
├── users/{userId}
│   ├── uid, name, email, photoUrl
│   ├── fcmToken              → push notification delivery address
│   ├── activeChatId          → currently open single chat (suppresses notifications)
│   ├── activeGroupId         → currently open group (suppresses notifications)
│   ├── isOnline, lastSeen    → presence tracking
│   └── phoneNumber, emailVerified
│
├── chats/{chatId}
│   ├── users: [userId1, userId2]
│   ├── lastMessage, lastMessageType, lastMessageTime
│   └── messages/{messageId}          (sub-collection)
│       ├── senderId, receiverId, senderEmail
│       ├── text, type (text/image/file/voice/sticker/gif)
│       ├── mediaUrl, storagePath, fileName
│       ├── isRead, isEdited
│       └── createdAt, updatedAt
│
├── groups/{groupId}
│   ├── name, imageUrl, groupImageStoragePath
│   ├── creatorId, members[], membersEmails[], admins[]
│   ├── lastMessage, lastMessageTime
│   └── messages/{messageId}          (sub-collection)
│       ├── senderId, senderEmail
│       ├── text, type, fileUrl, fileName, storagePath
│       ├── readBy[]
│       └── createdAt, updatedAt
│
├── calls/{callId}
│   ├── callerId, callerName, callerEmail, callerPhotoUrl
│   ├── receiverId, receiverName, receiverEmail, receiverPhotoUrl
│   ├── chatId, channelId, type (audio/video)
│   ├── status (ringing/accepted/rejected/ended/missed)
│   ├── startedAt, acceptedAt, endedAt, durationInSeconds
│   └── createdAt, updatedAt
│
├── blocks/{blockId}
│   ├── blockerId, blockedId
│   └── createdAt
│
├── statuses/{statusId}
│   ├── userId, userName, userPhotoUrl
│   ├── type (text/image), text, imageUrl, storagePath
│   ├── backgroundColor, textColor
│   ├── viewedBy[]
│   └── createdAt, expiresAt
│
└── global_notifications/{notificationId}
    ├── user_id, title, body
    ├── isSeen, product_id
    └── created_at
```

---

## Supabase Storage Structure

Bucket: **`chatapp`**

```
chatapp/
├── chats/{chatId}/messages/images/     → single chat images
├── chats/{chatId}/messages/files/      → single chat files
├── chats/{chatId}/messages/audio/      → single chat voice messages
├── groups/{groupId}/image/             → group profile images
├── groups/{groupId}/messages/images/   → group chat images
├── groups/{groupId}/messages/files/    → group chat files
├── statuses/{userId}/                  → story images
└── images/{ownerId}/                   → profile photos and general uploads
```

---

## Supabase Edge Functions

| Function | Purpose | Env Vars |
|----------|---------|----------|
| `send-notification` | Sends push notifications via FCM v1 HTTP API | `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY`, `FCM_PROJECT_ID` |
| `agora-token` | Generates temporary Agora RTC tokens for calls | `AGORA_APP_ID`, `AGORA_APP_CERTIFICATE` |

Supabase project ref: `nkzezuvubeloiglhdpfu`
URL: `https://nkzezuvubeloiglhdpfu.supabase.co`

---

## Feature Map

### Authentication
- Email/password sign-up and login
- Google Sign-In
- Email verification (`sendEmailVerification`)
- Forgot password (`sendPasswordResetEmail`)
- Profile setup after first login
- Password change with old password re-authentication
- Account deletion

### Single Chat (1-on-1)
- Create chat by selecting a user or searching by email
- Message types: text, image, file, voice, sticker, GIF
- Message editing and deletion (deletes storage file too)
- Read receipts (`isRead` flag, batch mark-as-read)
- Typing indicators (real-time via Firestore)
- User presence (online/offline with `lastSeen`)
- User blocking/unblocking
- Unread message count badges
- Contact info screen
- Chat search

### Group Chat
- Create groups with multiple members
- Admin system (make/remove admin, creator can delete group)
- Add members by email (with block check)
- Remove members, exit group
- Group image upload
- Text + attachment messages (image, file, link)
- Message editing and batch deletion
- Read tracking (`readBy` array per message)
- Group info screen with media/links/docs viewer

### Voice & Video Calls
- 1-on-1 audio and video calls via Agora RTC
- Token generation via Supabase Edge Function (server-side, secure)
- Native incoming call UI via `flutter_callkit_incoming` (works on lock screen)
- Call states: ringing → accepted/rejected/missed → ended
- Controls: mute, speaker, camera toggle, camera switch
- Call history (merged caller + receiver streams, grouped by date)
- Stale call auto-cleanup (ringing >60s, accepted >24h)
- 30-second missed call timer on caller side
- Handles app termination during active call
- Delete individual call records or full history

### Status / Stories
- Create text statuses (with background/text color)
- Create image statuses
- View statuses from contacts
- My status management (view, delete)
- Viewed-by tracking
- 24-hour expiry pattern

### AI Assistant
- Gemini 2.0 Flash via `google_generative_ai`
- Conversational chat session with context memory
- System prompt: friendly assistant for jokes, facts, advice, quotes

### Profile & Settings
- Edit display name and profile photo (upload to Supabase)
- Change password (with old password verification)
- Dark mode / light mode toggle
- Language switch (Arabic / English)
- Notification subscribe/unsubscribe
- Do Not Disturb mode (local, via SharedPreferences)
- Chat wallpaper selection (9 gradient/solid options)
- Blocked contacts management
- Logout (clears FCM token, signs out Firebase + Google)

### Push Notifications
- FCM token management (save on login, refresh on change, delete on logout)
- Single chat: skips if receiver has the chat open (`activeChatId`)
- Group chat: sent to all members except sender, skips if member has group open (`activeGroupId`)
- Call: high priority, triggers CallKit on Android/iOS
- Delivered via Supabase Edge Function → FCM v1 API
- Android channels: `chat-notifications`, `call-notifications`
- iOS: APNs with `time-sensitive` interruption level for calls
- Local notification display via `flutter_local_notifications`
- Notification save to Firestore (`global_notifications`)

### Infrastructure
- Connectivity monitoring with no-network fallback screen
- Environment variables via `.env.dev` / `.env.prod` (flutter_dotenv)
- Product flavors: Development, Production
- Hive local database for caching
- SharedPreferences for settings (theme, language, DnD, wallpaper, user session)
- QR code generation
- WebView integration
- Dynamic links support (scaffolded)
- Splash screen with particle animation

---

## Project Structure

```
lib/
├── main.dart                               → app initialization
├── chat_app.dart                           → MaterialApp with theme, locale, routing
├── constants/
│   ├── agora_constants.dart                → Agora App ID
│   ├── app_images.dart                     → generated asset paths
│   ├── fierstore_paths.dart                → Firestore collection names
│   ├── giphy_constants.dart                → Giphy API config
│   └── suba_base_paths.dart                → Supabase paths
│
├── core/
│   ├── app/
│   │   ├── app_cubit/                      → theme + language state
│   │   ├── auth_cubit/                     → auth state (login/signup)
│   │   ├── upload_image/                   → image upload cubit + data source
│   │   ├── models/current_user_model.dart  → user model from Firebase Auth
│   │   ├── data_source/                    → unread messages data source
│   │   ├── repo/                           → unread messages repo
│   │   └── connectivity_controller.dart
│   │
│   ├── common/
│   │   ├── widgets/                        → shared UI (app bars, buttons, text fields)
│   │   ├── widgets/chat/                   → shared chat widgets (bubble, input, actions)
│   │   ├── dialogs/                        → custom dialog helpers
│   │   ├── toast/                          → toast notifications
│   │   ├── loading/                        → shimmer, empty screen
│   │   ├── screens/                        → no-network, under-build, webview
│   │   └── bottom_shet/                    → bottom sheet helpers
│   │
│   ├── di/injection_container.dart         → GetIt service locator setup
│   ├── enums/                              → filter, nav bar enums
│   ├── extensions/                         → context, date, string extensions
│   ├── helper_functions/                   → getCurrentUser, spacing, file open
│   ├── language/                           → localization delegates + lang keys
│   ├── routes/                             → named routes + onGenerateRoute
│   │
│   ├── service/
│   │   ├── auth_service_fierbase/          → Firebase Auth + Google Sign-In wrapper
│   │   ├── call_service/                   → CallProvider interface, Agora impl, token service, CallKit
│   │   ├── connectivity/                   → network connectivity monitor
│   │   ├── dnd/                            → Do Not Disturb toggle
│   │   ├── dynamic_link/                   → dynamic link handler (scaffolded)
│   │   ├── env/                            → .env variable loader
│   │   ├── fierstore/                      → generic Firestore CRUD wrapper
│   │   ├── hive/                           → Hive local DB setup
│   │   ├── image_picker/                   → image picker utils
│   │   ├── network/                        → Dio + Retrofit API service
│   │   ├── pending_navigation/             → deferred navigation after CallKit accept
│   │   ├── push_notification/              → FCM, local notifications, chat notifications
│   │   ├── shared_pref/                    → SharedPreferences keys + wrapper
│   │   ├── supabase/                       → Supabase Storage service
│   │   ├── user_presence/                  → online/offline lifecycle tracker
│   │   └── wallpaper/                      → chat wallpaper options
│   │
│   └── style/                              → light + dark theme definitions
│
├── features/
│   ├── ai_assistant/                       → Gemini AI chat (service + cubit + screen)
│   ├── auth/                               → login, signup, forgot password, verify email, profile setup
│   ├── calls/                              → call data source, models, cubits, screens, widgets
│   ├── groups/                             → group data source, models, cubits, screens, widgets
│   ├── main/                               → main screen with bottom nav bar
│   ├── profile/                            → profile, edit, blocked contacts, settings
│   ├── single_chat/                        → 1-on-1 chat data sources, models, cubits, screens
│   ├── splash/                             → animated splash screen
│   └── status/                             → stories data source, models, cubits, screens
│
supabase/
├── .temp/linked-project.json               → linked Supabase project info
└── functions/
    ├── send-notification/index.ts          → FCM push notification Edge Function
    └── agora-token/index.ts                → Agora RTC token Edge Function
```

---

## State Management Pattern

**BLoC/Cubit** with **Freezed** for immutable states.

```
User Action → Screen calls Cubit method
                    │
                    ▼
              Cubit calls Repo
                    │
                    ▼
              Repo delegates to DataSource
                    │
                    ▼
              DataSource talks to Firebase/Supabase
                    │
                    ▼
              Cubit emits new State
                    │
                    ▼
              BlocBuilder/BlocConsumer rebuilds UI
```

### Cubits in the app:

| Feature | Cubits |
|---------|--------|
| App-level | `AppCubit` (theme, language), `AuthCubit`, `UnreadMessagesCubit`, `UploadImageCubit` |
| Single Chat | `ChatsCubit`, `CreateChatCubit`, `MessagesCubit`, `SendMessageCubit`, `TypingCubit`, `ChatListTypingCubit`, `UserPresenceCubit`, `BlockCubit` |
| Groups | `GroupsCubit`, `CreateGroupCubit`, `SelectedGroupChatCubit`, `GroupInfoCubit` |
| Calls | `StartCallCubit`, `IncomingCallCubit`, `ActiveCallCubit`, `CallsHistoryCubit` |
| Status | `CreateStatusCubit`, `MyStatusCubit`, `StatusCubit` |
| Profile | `ProfileCubit`, `BlockedContactsCubit` |
| AI | `AiAssistantCubit` |
| Main | `MainCubit` |

---

## Dependency Injection

**GetIt** (`sl`) registered in `lib/core/di/injection_container.dart`.

| Registration | Type | Examples |
|-------------|------|---------|
| `registerLazySingleton` | Shared instance, created once | DataSources, Repos, Services (Agora, Storage, Firestore) |
| `registerFactory` | New instance each time | Cubits (each screen gets fresh state) |
| `registerSingleton` | Immediate singleton | `GlobalKey<NavigatorState>` |

---

## Navigation

Named routes via `onGenerateRoute` in `AppRoutes`. Key routes:

| Route | Screen | Args |
|-------|--------|------|
| `splash` | SplashScreen | — |
| `login` | LoginScreen | — |
| `signUp` | SignUpScreen | — |
| `mainScreen` | MainScreen (bottom nav) | — |
| `singleChat` | SingleChatScreen | `ChatModel` |
| `selectedGroup` | SelectedGroupChatScreen | `GroupModel` |
| `callScreen` | CallScreen | `CallModel` |
| `callsHistoryScreen` | CallsHistoryScreen | — |
| `profile` | ProfileScreen | — |
| `editProfile` | EditProfileScreen | — |
| `contactInfo` | ContactInfoScreen | `Map` with chat, friendId, blockCubit |
| `groupInfo` | GroupInfoScreen | `GroupModel` |
| `status` | StatusScreen | — |
| `aiAssistant` | AiAssistantScreen | — |
| `blockedContacts` | BlockedContactsScreen | — |
| `newChat` | NewChatScreen | — |

---

## Local Storage

| Store | Technology | What's stored |
|-------|-----------|---------------|
| Theme mode | SharedPreferences | `mode` (bool) |
| Language | SharedPreferences | `language` (string: "ar"/"en") |
| Current user | SharedPreferences | `currentUser` (JSON string of `CurrentUserModel`) |
| User photo URL | SharedPreferences | `currentUserUrl` |
| Do Not Disturb | SharedPreferences | `doNotDisturb` (bool) |
| Chat wallpaper | SharedPreferences | `chatWallpaper` (index string) |
| Cached data | Hive | General local caching |

---

## Environment Configuration

Two `.env` files loaded via `flutter_dotenv`:

| File | When used | `ENV_TYPE` |
|------|-----------|------------|
| `.env.dev` | Development builds | `dev` |
| `.env.prod` | Production builds | `prod` |

Keys: `API_KEY`, `BASE_URL`, `DEBUG`, `NOTFICATION_BASEURL`, `ENV_TYPE`, `APP_NAME`, `GEMINI_API_KEY`

---

## Build Configuration

### Product Flavors

| Flavor | Application ID Suffix | Use |
|--------|----------------------|-----|
| Development | (none defined) | Debug builds |
| Production | (none defined) | Release builds, CI/CD |

### CI/CD

- **GitHub Actions** workflow triggers on push to `master`
- **Fastlane** builds the APK and distributes via Firebase App Distribution
- Token read from `FIREBASE_CLI_TOKEN` GitHub secret
- Tester: `mohammadwork199700@gmail.com`

---

## Key Design Decisions

1. **Firebase + Supabase hybrid**: Firebase for auth/database/messaging (mature ecosystem), Supabase for storage/functions (free tier, no Blaze plan needed).

2. **Agora for calls, not WebRTC directly**: Agora handles NAT traversal, TURN servers, codec management. Token generated server-side to protect App Certificate.

3. **CallKit for incoming calls**: Shows native call UI even on lock screen. Handles accept/reject/timeout at OS level, writes to Firestore directly.

4. **activeChatId/activeGroupId pattern**: Prevents duplicate notifications when user already has the conversation open. Set on enter, cleared on leave.

5. **Dual-stream call history**: Firestore can't OR-query `callerId == me || receiverId == me`. Solution: two separate streams merged client-side with deduplication by call ID.

6. **FNV-1a hash for Agora UID**: Agora needs numeric UIDs. `String.hashCode` is non-deterministic across Dart versions. FNV-1a is deterministic and collision-resistant for this use case.

7. **Stale call cleanup**: If the app crashes during a call, the Firestore document stays in `ringing`/`accepted` forever. On next call attempt, stale calls older than 60s (ringing) or 24h (accepted) are auto-cleaned.

8. **Edge Functions over client-side API calls**: FCM v1 requires a Service Account private key. Agora token requires App Certificate. Both are secrets that must never be in the client app.

---

## GitHub Repository

- **Remote**: `https://github.com/mkh123213/chatApp`
- **Branch**: `master`
- **Owner**: `mkh123213`
