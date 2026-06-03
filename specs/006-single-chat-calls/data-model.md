# Data Model: Single Chat Calls

## Entities

### CallModel

| Field            | Type       | Required | Description                                      |
|------------------|------------|----------|--------------------------------------------------|
| id               | String     | Yes      | Unique call document ID                          |
| chatId           | String     | Yes      | Sorted user IDs joined by `_` (e.g., "uid1_uid2") |
| callerId         | String     | Yes      | UID of the user who initiated the call           |
| callerName       | String     | Yes      | Display name of the caller                       |
| callerEmail      | String     | Yes      | Email of the caller                              |
| callerPhotoUrl   | String?    | No       | Profile photo URL of the caller                  |
| receiverId       | String     | Yes      | UID of the user being called                     |
| receiverName     | String     | Yes      | Display name of the receiver                     |
| receiverEmail    | String     | Yes      | Email of the receiver                            |
| receiverPhotoUrl | String?    | No       | Profile photo URL of the receiver                |
| type             | String     | Yes      | "audio" or "video"                               |
| status           | String     | Yes      | "ringing", "accepted", "rejected", "ended", "missed" |
| startedAt        | DateTime?  | No       | Timestamp when the call was initiated            |
| acceptedAt       | DateTime?  | No       | Timestamp when the receiver accepted             |
| endedAt          | DateTime?  | No       | Timestamp when the call ended                    |
| durationInSeconds| int        | Yes      | Talk time in seconds (from acceptedAt to endedAt)|
| channelId        | String     | Yes      | Unique channel ID for the call provider (Agora)  |
| createdAt        | DateTime?  | No       | Document creation timestamp                      |
| updatedAt        | DateTime?  | No       | Last update timestamp                            |

### Relationships

- **CallModel → ChatModel**: Via `chatId` (matches the sorted UIDs pattern used in chats)
- **CallModel → User (caller)**: Via `callerId` (references `usersCollection`)
- **CallModel → User (receiver)**: Via `receiverId` (references `usersCollection`)

### Identity & Uniqueness

- **Call ID**: Auto-generated Firestore document ID
- **Chat ID**: Deterministic — sorted `[callerId, receiverId].join('_')`
- **Channel ID**: `'call_$callId'` (unique per call, used by Agora)
- **Uniqueness constraint**: Only one call with `status in ['ringing', 'accepted']` per `chatId` at any time

## State Transitions

```
                    ┌─────────────┐
                    │   ringing   │ (initial state)
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┬──────────────────┐
          ▼                ▼                ▼                  ▼
   ┌────────────┐   ┌───────────┐   ┌───────────┐     ┌───────────┐
   │  accepted  │   │ rejected  │   │   ended   │     │  missed   │
   └─────┬──────┘   └───────────┘   │ (dur = 0) │     └───────────┘
         │           (terminal)      └───────────┘      (terminal)
         ▼                            (terminal)
   ┌───────────┐
   │   ended   │
   │ (dur > 0) │
   └───────────┘
    (terminal)
```

### Transition Rules

| From     | To       | Trigger                        | Updates                                            |
|----------|----------|--------------------------------|----------------------------------------------------|
| ringing  | accepted | Receiver taps accept           | acceptedAt = now, updatedAt = now                  |
| ringing  | rejected | Receiver taps reject           | endedAt = now, updatedAt = now                     |
| ringing  | ended    | Caller cancels                 | endedAt = now, durationInSeconds = 0, updatedAt    |
| ringing  | missed   | 30s timeout (caller-side timer)| endedAt = now, updatedAt = now                     |
| accepted | ended    | Either user taps end           | endedAt = now, durationInSeconds = X, updatedAt    |

### Validation Rules

- `type` must be one of: `"audio"`, `"video"`
- `status` must be one of: `"ringing"`, `"accepted"`, `"rejected"`, `"ended"`, `"missed"`
- `durationInSeconds` >= 0
- `callerId` != `receiverId` (enforced at creation)
- Only one non-terminal call per `chatId` (enforced before creation)
- `durationInSeconds` calculated as `endedAt - acceptedAt` in seconds (0 if never accepted)

## Firestore Collection Structure

```
firestore-root/
└── calls/                          # Top-level collection
    └── {callId}/                   # Auto-generated document ID
        ├── id: "callId"
        ├── chatId: "uid1_uid2"     # Sorted, deterministic
        ├── callerId: "uid1"
        ├── callerName: "Mohammad"
        ├── callerEmail: "m@email.com"
        ├── callerPhotoUrl: "https://..."
        ├── receiverId: "uid2"
        ├── receiverName: "Friend"
        ├── receiverEmail: "f@email.com"
        ├── receiverPhotoUrl: "https://..."
        ├── type: "audio"
        ├── status: "ringing"
        ├── startedAt: Timestamp
        ├── acceptedAt: null
        ├── endedAt: null
        ├── durationInSeconds: 0
        ├── channelId: "call_callId"
        ├── createdAt: Timestamp
        └── updatedAt: Timestamp
```

## Firestore Indexes Required

| Collection | Fields                              | Order     | Purpose                    |
|------------|-------------------------------------|-----------|----------------------------|
| calls      | receiverId ASC, status ASC          | —         | Incoming call listener     |
| calls      | chatId ASC, status ASC              | —         | Duplicate prevention       |
| calls      | callerId ASC, createdAt DESC        | Composite | Caller history             |
| calls      | receiverId ASC, createdAt DESC      | Composite | Receiver history           |
