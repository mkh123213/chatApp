# Research: Single Chat Calls

## Decision 1: Call Provider

**Decision**: Agora (`agora_rtc_engine` Flutter package)

**Rationale**: Most mature Flutter SDK for real-time audio/video. 10,000 free minutes/month. Simplest setup for 1:1 calls (no TURN server management). Well-documented with Flutter-specific examples.

**Alternatives considered**:
- ZegoCloud: Good SDK but less community adoption and fewer Flutter examples
- Daily: WebRTC-based, good API but Flutter SDK is newer and less stable
- Raw WebRTC (`flutter_webrtc`): Full control but requires signaling server, TURN/STUN setup, significantly more code

## Decision 2: Call State Management Architecture

**Decision**: Firestore for call metadata/state + Agora for media streaming. Four separated Cubits.

**Rationale**: Firestore provides real-time sync of call status without building a custom signaling server. Separating Cubits follows the existing app pattern and prevents state pollution between unrelated concerns.

**Alternatives considered**:
- Single CallCubit for everything: Violates user's explicit constraint of separation
- Firebase Realtime Database: Would work but project already uses Firestore exclusively
- Custom WebSocket signaling: Unnecessary complexity when Firestore snapshots provide real-time sync

## Decision 3: Incoming Call Detection Scope

**Decision**: Global listener at MainScreen level (foreground only)

**Rationale**: Users expect to receive calls regardless of which screen they're on. WhatsApp/Telegram pattern. Background detection via push notifications deferred to future version.

**Alternatives considered**:
- Chat screen only: User would miss calls while on settings/groups screens
- Background via FCM: Adds significant complexity (cloud functions, call kit integration) — deferred

## Decision 4: Call History Query Strategy

**Decision**: Two Firestore queries (caller + receiver) merged client-side

**Rationale**: Firestore doesn't support OR queries on different fields. Querying where `callerId == uid` and where `receiverId == uid` separately, then merging/deduplicating by ID and sorting by `createdAt` desc is the standard Firestore pattern.

**Alternatives considered**:
- Array field `participants`: Would require restructuring the call document
- Cloud Function to maintain a separate history sub-collection: Over-engineering for this scale
- Single query with chatId contains: Firestore doesn't support substring queries on fields

## Decision 5: Receiver Data Fetching

**Decision**: Fetch receiver user document from `usersCollection` when starting a call

**Rationale**: `ChatModel` only has `users` (UIDs) and `usersEmails`. It doesn't store name or photoUrl. The caller's info comes from `getCurrentUser()`, but receiver's name/photo must be fetched from Firestore at call creation time and stored in the call document for offline display.

**Alternatives considered**:
- Store name/photo in ChatModel: Would require schema change to existing feature
- Fetch on display: Would require network call every time history/call screen renders
- Store in SharedPreferences: Stale data risk

## Decision 6: Missed Call Timeout Responsibility

**Decision**: Caller-side 30-second timer in CallScreen

**Rationale**: Simpler than a Cloud Function. The caller's device starts a timer when the call is created. If 30 seconds pass with status still `ringing`, the caller updates status to `missed`. If the caller's app crashes/disconnects, a Cloud Function could be added later as a safety net.

**Alternatives considered**:
- Cloud Function with scheduled trigger: More reliable but adds backend complexity
- Receiver-side timer: Receiver might not have the app open
- No timeout (manual only): Bad UX, calls would ring forever
