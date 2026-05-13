# Implementation Plan: Single Chat Calls

**Branch**: `006-single-chat-calls` | **Date**: 2026-05-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/006-single-chat-calls/spec.md`

## Summary

Add one-to-one audio/video calling between two users inside the existing single chat feature. The implementation uses Agora (`agora_rtc_engine`) as the real-time media provider behind an abstraction layer, with Firestore managing call metadata/state. Four separated Cubits handle start, incoming, active, and history concerns. Minimal integration into the existing `SingleChatScreen` header adds call buttons without modifying chat messaging logic.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: flutter_bloc (Cubit), freezed, json_serializable, get_it, cloud_firestore, firebase_auth, agora_rtc_engine, shared_preferences, flutter_screenutil  
**Storage**: Cloud Firestore (`calls` collection)  
**Testing**: Manual testing (no test framework configured in project)  
**Target Platform**: Android / iOS  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Call screen visible in <3s, incoming call notification in <2s, status sync in <2s  
**Constraints**: Foreground only (no background call detection), no push notifications for calls  
**Scale/Scope**: 1:1 calls only, single `calls` collection

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution is using default template (no custom principles defined). No gates to enforce. Proceeding.

## Project Structure

### Documentation (this feature)

```text
specs/006-single-chat-calls/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── constants/
│   └── fierstore_paths.dart              # ADD: callsCollection constant
├── core/
│   ├── language/
│   │   └── lang_keys.dart                # ADD: call-related LangKeys
│   ├── routes/
│   │   └── app_routes.dart               # ADD: callScreen, callsHistoryScreen routes
│   └── di/
│       └── injection_container.dart      # ADD: _initCalls() registration
├── features/
│   ├── calls/                            # NEW FEATURE FOLDER
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── call_model.dart
│   │   │   │   └── call_model.g.dart     # generated
│   │   │   ├── datasources/
│   │   │   │   └── calls_remote_data_source.dart
│   │   │   └── repositories/
│   │   │       └── calls_repo.dart
│   │   ├── call_provider/
│   │   │   ├── call_provider_service.dart         # abstract interface
│   │   │   └── agora_call_provider_service.dart   # Agora implementation
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── start_call_cubit/
│   │       │   │   ├── start_call_cubit.dart
│   │       │   │   └── start_call_state.dart
│   │       │   ├── incoming_call_cubit/
│   │       │   │   ├── incoming_call_cubit.dart
│   │       │   │   └── incoming_call_state.dart
│   │       │   ├── active_call_cubit/
│   │       │   │   ├── active_call_cubit.dart
│   │       │   │   └── active_call_state.dart
│   │       │   └── calls_history_cubit/
│   │       │       ├── calls_history_cubit.dart
│   │       │       └── calls_history_state.dart
│   │       ├── screens/
│   │       │   ├── call_screen.dart
│   │       │   └── calls_history_screen.dart
│   │       ├── refactor/
│   │       │   ├── call_body.dart
│   │       │   └── calls_history_body.dart
│   │       └── widgets/
│   │           ├── active_call_bloc_consumer.dart
│   │           ├── call_header.dart
│   │           ├── call_controls.dart
│   │           ├── incoming_call_dialog.dart
│   │           ├── incoming_call_overlay.dart
│   │           ├── calls_history_bloc_consumer.dart
│   │           └── call_history_card.dart
│   ├── main/
│   │   └── presentation/
│   │       └── screens/
│   │           └── main_screen.dart      # MODIFY: add IncomingCallCubit provider + overlay
│   └── single_chat/
│       └── presentation/
│           └── screens/
│               └── single_chat_screen.dart  # MODIFY: add call icons to AppBar
lang/
├── en.json                               # ADD: call-related translations
└── ar.json                               # ADD: call-related translations
```

**Structure Decision**: Feature-first under `lib/features/calls/`. Follows existing pattern from `single_chat/`, `groups/`, `status/`. Call provider abstraction lives inside the feature as `call_provider/`.

---

## 1. Call Provider Decision & Integration Strategy

### Decision: Agora with abstraction layer

**Agora** (`agora_rtc_engine` package) handles real audio/video streaming. All Agora-specific code lives behind `CallProviderService` abstract class so it can be swapped for ZegoCloud/Daily/raw WebRTC later.

### Abstract interface: `call_provider_service.dart`

```dart
abstract class CallProviderService {
  Future<void> initialize();
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool isVideo,
  });
  Future<void> leaveChannel();
  Future<void> toggleMute(bool muted);
  Future<void> toggleSpeaker(bool speakerOn);
  Future<void> toggleCamera(bool cameraOn);
  Future<void> switchCamera();
  Future<void> dispose();
}
```

### Agora implementation: `agora_call_provider_service.dart`

- Creates `RtcEngine` on `initialize()`
- Joins channel with temp token (or no token for testing with App ID only)
- Implements all toggle methods via Agora SDK
- Calls `leaveChannel()` and `engine.release()` on `dispose()`

### Agora setup requirements

- Add `agora_rtc_engine` to `pubspec.yaml`
- Add `permission_handler` for camera/mic permissions
- Add Agora App ID to a constants file (not hardcoded in provider)
- Android: Add permissions to `AndroidManifest.xml` (RECORD_AUDIO, CAMERA, INTERNET)
- iOS: Add permissions to `Info.plist` (NSMicrophoneUsageDescription, NSCameraUsageDescription)

---

## 2. Firestore Data Design

### Collection: `calls` (top-level)

```
calls/{callId}
├── id: String (callId)
├── chatId: String ("uid1_uid2" sorted)
├── callerId: String
├── callerName: String
├── callerEmail: String
├── callerPhotoUrl: String?
├── receiverId: String
├── receiverName: String
├── receiverEmail: String
├── receiverPhotoUrl: String?
├── type: String ("audio" | "video")
├── status: String ("ringing" | "accepted" | "rejected" | "ended" | "missed")
├── startedAt: Timestamp
├── acceptedAt: Timestamp?
├── endedAt: Timestamp?
├── durationInSeconds: int (0 by default)
├── channelId: String (unique per call for Agora)
├── createdAt: Timestamp
└── updatedAt: Timestamp
```

### Firestore constant

Add to `lib/constants/fierstore_paths.dart`:

```dart
const String callsCollection = 'calls';
```

### Indexes needed

- `calls` where `receiverId == X` AND `status == "ringing"` (for incoming call listener)
- `calls` where `chatId == X` AND `status in ["ringing", "accepted"]` (for duplicate prevention)
- Composite index for history: `calls` where `callerId == X` OR `receiverId == X` ordered by `createdAt` desc — Firestore requires two separate queries merged client-side

---

## 3. CallModel Design

```dart
@JsonSerializable()
class CallModel {
  const CallModel({
    required this.id,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    required this.callerEmail,
    this.callerPhotoUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    this.receiverPhotoUrl,
    required this.type,
    required this.status,
    this.startedAt,
    this.acceptedAt,
    this.endedAt,
    this.durationInSeconds = 0,
    required this.channelId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chatId;
  final String callerId;
  final String callerName;
  final String callerEmail;
  final String? callerPhotoUrl;
  final String receiverId;
  final String receiverName;
  final String receiverEmail;
  final String? receiverPhotoUrl;
  final String type; // "audio" | "video"
  final String status; // "ringing" | "accepted" | "rejected" | "ended" | "missed"

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? startedAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? acceptedAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? endedAt;

  final int durationInSeconds;
  final String channelId;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? updatedAt;

  // Same Timestamp converters as ChatModel
  static DateTime? _dateTimeFromJson(dynamic value) { ... }
  static dynamic _dateTimeToJson(DateTime? value) { ... }

  factory CallModel.fromJson(Map<String, dynamic> json) => _$CallModelFromJson(json);
  Map<String, dynamic> toJson() => _$CallModelToJson(this);

  factory CallModel.fromFirestore({required String id, required Map<String, dynamic> data}) {
    return CallModel.fromJson({'id': id, ...data});
  }
}
```

---

## 4. Call Status Lifecycle

```
┌─────────┐
│ ringing │
└────┬────┘
     │
     ├── receiver accepts ──► [accepted] ──► either ends ──► [ended] (duration > 0)
     │
     ├── receiver rejects ──► [rejected]
     │
     ├── caller cancels ────► [ended] (duration = 0)
     │
     └── timeout (30s) ─────► [missed]
```

**Rules**:
- `ringing` → `accepted` | `rejected` | `ended` | `missed`
- `accepted` → `ended` only
- `rejected`, `ended`, `missed` are terminal states
- Duration is calculated from `acceptedAt` to `endedAt` (talk time only)

---

## 5. Remote Data Source Methods

### Abstract: `CallsRemoteDataSource`

```dart
abstract class CallsRemoteDataSource {
  Future<CallModel> startCall({
    required ChatModel chat,
    required CurrentUserModel caller,
    required String type,
  });

  Stream<CallModel?> listenForIncomingCalls({
    required String currentUserId,
  });

  Stream<CallModel> listenToCall({
    required String callId,
  });

  Future<void> acceptCall({required String callId});

  Future<void> rejectCall({required String callId});

  Future<void> endCall({
    required String callId,
    required int durationInSeconds,
  });

  Stream<List<CallModel>> getCallsHistory({
    required String currentUserId,
  });

  Future<bool> hasActiveCallBetweenUsers({
    required String chatId,
  });
}
```

### Implementation: `CallsRemoteDataSourceImpl`

Constructor takes `DataBaseService` (same pattern as `ChatsRemoteDataSourceImpl`).

**Key implementation details**:

- **`startCall`**: 
  - Derives `chatId` from sorted `[callerId, receiverId].join('_')`
  - Checks `hasActiveCallBetweenUsers` first
  - Extracts receiver info from `chat.users` / `chat.usersEmails` + fetches user doc from `usersCollection` to get name/photoUrl
  - Generates callId via `FirebaseFirestore.instance.collection(callsCollection).doc().id`
  - Generates channelId as `'call_$callId'`
  - Calls `_dataBaseService.setData(path: '$callsCollection/$callId', data: callModel.toJson())`

- **`listenForIncomingCalls`**:
  - Uses `_dataBaseService.collectionStream` with query: `receiverId == currentUserId` AND `status == 'ringing'`
  - Maps to first element or null

- **`listenToCall`**:
  - Uses `_dataBaseService.documentStream(path: '$callsCollection/$callId')`

- **`acceptCall`**:
  - `setData` with `{status: 'accepted', acceptedAt: Timestamp.now(), updatedAt: Timestamp.now()}`

- **`rejectCall`**:
  - `setData` with `{status: 'rejected', endedAt: Timestamp.now(), updatedAt: Timestamp.now()}`

- **`endCall`**:
  - `setData` with `{status: 'ended', endedAt: Timestamp.now(), durationInSeconds: durationInSeconds, updatedAt: Timestamp.now()}`

- **`getCallsHistory`**:
  - Two collection streams: one where `callerId == currentUserId`, one where `receiverId == currentUserId`
  - Merge with `Rx.combineLatest2` or manual merge, deduplicate by id, sort by `createdAt` desc
  - Alternatively: single query using `chatId` contains currentUserId (but Firestore doesn't support this well)
  - **Best approach**: Two queries merged client-side

- **`hasActiveCallBetweenUsers`**:
  - Query `callsCollection` where `chatId == chatId` and `status` in `['ringing', 'accepted']`
  - Return `result.isNotEmpty`

---

## 6. Repository Methods

### `CallsRepo` (abstract + impl)

Mirrors all `CallsRemoteDataSource` methods exactly, delegating to the data source. Same pattern as `ChatsRepo` / `ChatsRepoImpl`.

```dart
abstract class CallsRepo {
  Future<CallModel> startCall({...});
  Stream<CallModel?> listenForIncomingCalls({...});
  Stream<CallModel> listenToCall({...});
  Future<void> acceptCall({...});
  Future<void> rejectCall({...});
  Future<void> endCall({...});
  Stream<List<CallModel>> getCallsHistory({...});
  Future<bool> hasActiveCallBetweenUsers({...});
}
```

---

## 7. Cubits and States

### 7a. StartCallCubit

**Purpose**: Only handles call initiation flow (loading → success/error).

```dart
// States (sealed classes, same pattern as ChatsState):
sealed class StartCallState
├── StartCallInitial
├── StartCallLoading
├── StartCallSuccess(CallModel call)
└── StartCallError(String message)

// Cubit:
class StartCallCubit extends Cubit<StartCallState> {
  StartCallCubit({required CallsRepo callsRepo});

  Future<void> startAudioCall({required ChatModel chat}) async {
    emit(StartCallLoading());
    try {
      // Check self-call prevention
      // Call repo.startCall(type: 'audio')
      emit(StartCallSuccess(call: callModel));
    } catch (e) {
      emit(StartCallError(message: e.toString()));
    }
  }

  Future<void> startVideoCall({required ChatModel chat}) async {
    // Same as above with type: 'video'
  }
}
```

### 7b. IncomingCallCubit

**Purpose**: Listens for incoming ringing calls globally.

```dart
// States:
sealed class IncomingCallState
├── IncomingCallInitial
├── IncomingCallListening
├── IncomingCallReceived(CallModel call)
├── IncomingCallNone
└── IncomingCallError(String message)

// Cubit:
class IncomingCallCubit extends Cubit<IncomingCallState> {
  StreamSubscription? _subscription;

  void listenForIncomingCalls({required String currentUserId}) {
    emit(IncomingCallListening());
    _subscription = _callsRepo.listenForIncomingCalls(currentUserId: currentUserId).listen(
      (call) {
        if (call != null) emit(IncomingCallReceived(call: call));
        else emit(IncomingCallNone());
      },
      onError: (e) => emit(IncomingCallError(message: e.toString())),
    );
  }

  void stopListening() { _subscription?.cancel(); }

  @override
  Future<void> close() { _subscription?.cancel(); return super.close(); }
}
```

### 7c. ActiveCallCubit

**Purpose**: Manages active call screen — listening to call doc + accept/reject/end actions.

```dart
// States:
sealed class ActiveCallState
├── ActiveCallInitial
├── ActiveCallLoading
├── ActiveCallActive(CallModel call)
├── ActiveCallEnded
└── ActiveCallError(String message)

// Cubit:
class ActiveCallCubit extends Cubit<ActiveCallState> {
  StreamSubscription? _callSubscription;

  void listenToCall({required String callId}) {
    emit(ActiveCallLoading());
    _callSubscription = _callsRepo.listenToCall(callId: callId).listen(
      (call) {
        if (call.status == 'ended' || call.status == 'rejected' || call.status == 'missed') {
          emit(ActiveCallEnded());
        } else {
          emit(ActiveCallActive(call: call));
        }
      },
      onError: (e) => emit(ActiveCallError(message: e.toString())),
    );
  }

  Future<void> acceptCall({required CallModel call}) async { ... }
  Future<void> rejectCall({required CallModel call}) async { ... }
  Future<void> endCall({required CallModel call, required int durationInSeconds}) async { ... }

  @override
  Future<void> close() { _callSubscription?.cancel(); return super.close(); }
}
```

### 7d. CallsHistoryCubit

**Purpose**: Loads and holds call history list.

```dart
// States:
sealed class CallsHistoryState
├── CallsHistoryInitial
├── CallsHistoryLoading
├── CallsHistoryLoaded(List<CallModel> calls)
├── CallsHistoryEmpty
└── CallsHistoryError(String message)

// Cubit:
class CallsHistoryCubit extends Cubit<CallsHistoryState> {
  StreamSubscription? _subscription;

  void getCallsHistory({required String currentUserId}) {
    emit(CallsHistoryLoading());
    _subscription = _callsRepo.getCallsHistory(currentUserId: currentUserId).listen(
      (calls) {
        if (calls.isEmpty) emit(CallsHistoryEmpty());
        else emit(CallsHistoryLoaded(calls: calls));
      },
      onError: (e) => emit(CallsHistoryError(message: e.toString())),
    );
  }

  @override
  Future<void> close() { _subscription?.cancel(); return super.close(); }
}
```

---

## 8. Real-Time Incoming Call Listening

**Where**: `IncomingCallCubit` provided at `MainScreen` level (global).

**Flow**:
1. `MainScreen` wraps its body with `BlocProvider<IncomingCallCubit>` and starts `listenForIncomingCalls(currentUserId: getCurrentUser().uid)`
2. A `BlocListener<IncomingCallCubit, IncomingCallState>` at the `MainScreen` level watches for `IncomingCallReceived`
3. When received, show `IncomingCallDialog` as an overlay/dialog
4. Dialog shows: caller avatar, caller name/email, call type, accept/reject buttons
5. Accept → navigate to `callScreen` route with the `CallModel`
6. Reject → call `ActiveCallCubit.rejectCall()` and dismiss dialog

---

## 9. Active Call Listening

**Where**: `CallScreen` using `ActiveCallCubit`.

**Flow**:
1. `CallScreen` receives `CallModel` as argument
2. Creates `BlocProvider<ActiveCallCubit>` and calls `listenToCall(callId: call.id)`
3. Also initializes `CallProviderService` and joins the Agora channel
4. `BlocConsumer` renders UI based on state:
   - `ActiveCallActive(call)` → show call UI with real-time status/timer
   - `ActiveCallEnded` → leave Agora channel, pop screen
5. Timer widget: starts `Stopwatch` when `call.status == 'accepted'`, displays `mm:ss`

---

## 10. Call Start/Accept/Reject/End Flow

### Start (caller side)
1. User taps audio/video icon in `SingleChatScreen` AppBar
2. `StartCallCubit.startAudioCall(chat)` or `startVideoCall(chat)` called
3. Cubit checks `getCurrentUser().uid != receiverId` (self-call prevention)
4. Cubit checks `callsRepo.hasActiveCallBetweenUsers(chatId)` (duplicate prevention)
5. Cubit calls `callsRepo.startCall(...)` → creates Firestore doc with `status: 'ringing'`
6. On success, emit `StartCallSuccess(call)` → UI navigates to `callScreen`
7. `CallScreen` starts `ActiveCallCubit.listenToCall(callId)` + joins Agora channel
8. Caller sees ringing state until receiver accepts

### Accept (receiver side)
1. `IncomingCallCubit` detects new ringing call → shows `IncomingCallDialog`
2. Receiver taps accept → `ActiveCallCubit.acceptCall(call)` updates Firestore to `status: 'accepted'`
3. Navigate to `callScreen` with the call
4. Both users' `ActiveCallCubit` sees the status change via listener
5. Timer starts, Agora channel connected

### Reject (receiver side)
1. Receiver taps reject → `ActiveCallCubit.rejectCall(call)` updates Firestore to `status: 'rejected'`
2. Dialog dismissed
3. Caller's `ActiveCallCubit` sees `rejected` → emits `ActiveCallEnded` → pops `CallScreen`

### End (either side)
1. User taps end call → `ActiveCallCubit.endCall(call, durationInSeconds: elapsed)`
2. Duration = seconds since `acceptedAt` (talk time only)
3. Firestore updated to `status: 'ended'`, `endedAt`, `durationInSeconds`
4. Both sides' listener detects `ended` → leave Agora → pop screen

### Caller cancels while ringing
1. Caller taps end call while still ringing → `ActiveCallCubit.endCall(call, durationInSeconds: 0)`
2. Status → `ended` with zero duration
3. Receiver's `IncomingCallCubit` sees status is no longer `ringing` → dialog auto-dismissed

### Timeout (missed)
1. `CallScreen` (caller side) starts a 30-second timer when call is ringing
2. If timer expires and status is still `ringing`, update to `status: 'missed'`
3. Both sides react to terminal state

---

## 11. Duplicate Active Call Prevention

In `CallsRemoteDataSourceImpl.startCall()`:

```dart
final hasActive = await hasActiveCallBetweenUsers(chatId: chatId);
if (hasActive) {
  throw Exception('Call already active between these users.');
}
```

`hasActiveCallBetweenUsers` queries:
```dart
_dataBaseService.getCollection(
  path: callsCollection,
  queryBuilder: (q) => q
    .where('chatId', isEqualTo: chatId)
    .where('status', whereIn: ['ringing', 'accepted']),
  builder: (data, id) => data,
);
```

---

## 12. Prevent Calling Myself

In `StartCallCubit.startAudioCall()` / `startVideoCall()`:

```dart
final currentUser = getCurrentUser();
final friendId = chat.users.firstWhere((id) => id != currentUser.uid);
if (friendId == currentUser.uid) {
  emit(StartCallError(message: 'Cannot call yourself.'));
  return;
}
```

Also guarded in `CallsRemoteDataSourceImpl.startCall()` as a second layer.

---

## 13. Call Duration Calculation

- Duration = `endedAt - acceptedAt` (in seconds)
- Timer in `CallScreen` UI: starts a `Stopwatch` or periodic `Timer` when `call.status == 'accepted'`
- On end call: `durationInSeconds = stopwatch.elapsed.inSeconds`
- Passed to `ActiveCallCubit.endCall(call, durationInSeconds: elapsed)`
- Stored in Firestore on the `endCall` update

---

## 14. Calls History Flow

1. User navigates to Calls tab (`NavBarEnum.calls`)
2. `MainScreen` switches body to `CallsHistoryScreen`
3. `CallsHistoryScreen` wraps in `BlocProvider<CallsHistoryCubit>` calling `getCallsHistory(currentUserId)`
4. Data source runs two Firestore queries (caller + receiver), merges, deduplicates, sorts by `createdAt` desc
5. UI renders list via `CallsHistoryBlocConsumer` → `CallHistoryCard` per entry
6. Empty state shows localized "No calls yet" message

---

## 15. Minimal Integration with Existing Selected Single Chat Header

### Changes to `SingleChatScreen` (`single_chat_screen.dart`)

Current AppBar:
```dart
appBar: AppBar(
  title: Text(friendEmail),
),
```

Modified AppBar:
```dart
appBar: AppBar(
  title: Text(friendEmail),
  actions: [
    IconButton(
      icon: const Icon(Icons.videocam),
      onPressed: () => context.read<StartCallCubit>().startVideoCall(chat: chat),
    ),
    IconButton(
      icon: const Icon(Icons.call),
      onPressed: () => context.read<StartCallCubit>().startAudioCall(chat: chat),
    ),
  ],
),
```

Also add:
- `BlocProvider<StartCallCubit>` to the providers list
- `BlocListener<StartCallCubit, StartCallState>` to handle navigation on success and error toast

**No changes to messaging Cubits or body.**

---

## 16. GetIt Registration

Add `_initCalls()` in `injection_container.dart`:

```dart
Future<void> _initCalls() async {
  sl
    ..registerLazySingleton<CallProviderService>(
      () => AgoraCallProviderService(),
    )
    ..registerLazySingleton<CallsRemoteDataSource>(
      () => CallsRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
      ),
    )
    ..registerLazySingleton<CallsRepo>(
      () => CallsRepoImpl(
        callsRemoteDataSource: sl<CallsRemoteDataSource>(),
      ),
    )
    ..registerFactory<StartCallCubit>(
      () => StartCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<IncomingCallCubit>(
      () => IncomingCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<ActiveCallCubit>(
      () => ActiveCallCubit(
        callsRepo: sl<CallsRepo>(),
        callProviderService: sl<CallProviderService>(),
      ),
    )
    ..registerFactory<CallsHistoryCubit>(
      () => CallsHistoryCubit(callsRepo: sl<CallsRepo>()),
    );
}
```

Call `await _initCalls();` in `setupInjector()`.

---

## 17. UI Flow

### 17a. CallScreen (`call_screen.dart`)

- Receives `CallModel` as constructor arg
- Provides `ActiveCallCubit` via `BlocProvider`
- Starts `listenToCall(callId)` and initializes `CallProviderService`
- Full `Scaffold` route (pushed via named route `callScreen`)
- Child: `CallBody`

### 17b. CallBody (`call_body.dart`)

- Layout:
  - `CallHeader` (avatar, name, status, timer)
  - `Spacer`
  - `CallControls` (mute, speaker, camera, end)
- Uses `BlocConsumer<ActiveCallCubit, ActiveCallState>` for state-driven UI

### 17c. ActiveCallBlocConsumer (`active_call_bloc_consumer.dart`)

- Wraps the `BlocConsumer` logic
- Listener: on `ActiveCallEnded` → leave Agora channel, pop screen
- Builder: on `ActiveCallActive(call)` → render call UI

### 17d. CallHeader (`call_header.dart`)

- Circle avatar (friend photo or placeholder)
- Friend name via `TextApp`
- Call type label (Audio Call / Video Call) localized
- Status text (Ringing / Connected / Ended) localized
- Timer text (mm:ss) — only when status is `accepted`

### 17e. CallControls (`call_controls.dart`)

- Row of `IconButton`s:
  - Mute/Unmute mic
  - Speaker on/off
  - Camera on/off (video calls only)
  - Switch camera (video calls only)
  - End call (red circular button)
- Toggle states managed locally with `StatefulWidget`
- Each toggle calls the corresponding `CallProviderService` method

### 17f. IncomingCallDialog (`incoming_call_dialog.dart`)

- Shows as dialog/bottom sheet from `MainScreen` listener
- Caller avatar, name, email
- Call type label
- Accept button (green) → navigate to `callScreen`
- Reject button (red) → reject call

### 17g. IncomingCallOverlay (`incoming_call_overlay.dart`)

- Optional: wraps `IncomingCallDialog` as an `Overlay` entry for global display
- Alternative: use `showDialog` from `MainScreen` context

### 17h. CallsHistoryScreen (`calls_history_screen.dart`)

- Provides `CallsHistoryCubit`
- Child: `CallsHistoryBody`

### 17i. CallsHistoryBody (`calls_history_body.dart`)

- `CallsHistoryBlocConsumer` for state handling
- `ListView.builder` of `CallHistoryCard`s
- Empty state widget when no calls

### 17j. CallHistoryCard (`call_history_card.dart`)

- Row layout:
  - Avatar
  - Column: name, call type + status
  - Column: time, duration

---

## 18. Localization Keys & JSON Entries

### LangKeys additions (to `lang_keys.dart`)

```dart
// Calls feature
static const String calls = 'calls';
static const String audioCall = 'audio_call';
static const String videoCall = 'video_call';
static const String incomingCall = 'incoming_call';
static const String outgoingCall = 'outgoing_call';
static const String missedCall = 'missed_call';
static const String rejectedCall = 'rejected_call';
static const String endedCall = 'ended_call';
static const String startCall = 'start_call';
static const String acceptCall = 'accept_call';
static const String rejectCall = 'reject_call';
static const String endCall = 'end_call';
static const String calling = 'calling';
static const String ringing = 'ringing';
static const String connected = 'connected';
static const String callEnded = 'call_ended';
static const String callRejected = 'call_rejected';
static const String callMissed = 'call_missed';
static const String mute = 'mute';
static const String unmute = 'unmute';
static const String speaker = 'speaker';
static const String camera = 'camera';
static const String switchCamera = 'switch_camera';
static const String noCallsYet = 'no_calls_yet';
static const String callHistory = 'call_history';
static const String cannotCallYourself = 'cannot_call_yourself';
static const String callAlreadyActive = 'call_already_active';
```

### en.json additions

```json
"calls": "Calls",
"audio_call": "Audio Call",
"video_call": "Video Call",
"incoming_call": "Incoming Call",
"outgoing_call": "Outgoing Call",
"missed_call": "Missed Call",
"rejected_call": "Rejected Call",
"ended_call": "Ended Call",
"start_call": "Start Call",
"accept_call": "Accept",
"reject_call": "Reject",
"end_call": "End Call",
"calling": "Calling...",
"ringing": "Ringing...",
"connected": "Connected",
"call_ended": "Call Ended",
"call_rejected": "Call Rejected",
"call_missed": "Call Missed",
"mute": "Mute",
"unmute": "Unmute",
"speaker": "Speaker",
"camera": "Camera",
"switch_camera": "Switch Camera",
"no_calls_yet": "No calls yet",
"call_history": "Call History",
"cannot_call_yourself": "Cannot call yourself",
"call_already_active": "A call is already active between you and this user"
```

### ar.json additions

```json
"calls": "المكالمات",
"audio_call": "مكالمة صوتية",
"video_call": "مكالمة فيديو",
"incoming_call": "مكالمة واردة",
"outgoing_call": "مكالمة صادرة",
"missed_call": "مكالمة فائتة",
"rejected_call": "مكالمة مرفوضة",
"ended_call": "مكالمة منتهية",
"start_call": "بدء مكالمة",
"accept_call": "قبول",
"reject_call": "رفض",
"end_call": "إنهاء المكالمة",
"calling": "جاري الاتصال...",
"ringing": "يرن...",
"connected": "متصل",
"call_ended": "انتهت المكالمة",
"call_rejected": "تم رفض المكالمة",
"call_missed": "مكالمة فائتة",
"mute": "كتم",
"unmute": "إلغاء الكتم",
"speaker": "مكبر الصوت",
"camera": "الكاميرا",
"switch_camera": "تبديل الكاميرا",
"no_calls_yet": "لا توجد مكالمات بعد",
"call_history": "سجل المكالمات",
"cannot_call_yourself": "لا يمكنك الاتصال بنفسك",
"call_already_active": "يوجد مكالمة نشطة بالفعل بينك وبين هذا المستخدم"
```

---

## 19. Route Registration

Add to `AppRoutes` class:

```dart
static const String callScreen = 'callScreen';
static const String callsHistoryScreen = 'callsHistoryScreen';
```

Add cases in `onGenerateRoute`:

```dart
case callScreen:
  return BaseRoute(
    page: CallScreen(call: args as CallModel),
  );
case callsHistoryScreen:
  return BaseRoute(
    page: CallsHistoryScreen(),
  );
```

---

## 20. MainScreen Changes

### Add IncomingCallCubit globally

```dart
// In MainScreen build():
BlocProvider(
  create: (_) => sl<IncomingCallCubit>()
    ..listenForIncomingCalls(currentUserId: getCurrentUser().uid),
),
```

### Add BlocListener for incoming calls

```dart
BlocListener<IncomingCallCubit, IncomingCallState>(
  listener: (context, state) {
    if (state is IncomingCallReceived) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => IncomingCallDialog(call: state.call),
      );
    }
  },
)
```

### Replace Calls tab body

Change from `StatusScreen()` to `CallsHistoryScreen()` when `NavBarEnum.calls`:

```dart
else if (cubit.navBarEnum == NavBarEnum.calls) {
  return BlocProvider(
    create: (_) => sl<CallsHistoryCubit>()
      ..getCallsHistory(currentUserId: getCurrentUser().uid),
    child: const CallsHistoryScreen(),
  );
}
```

---

## 21. Build Runner Commands

After creating all model files with `@JsonSerializable()`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `call_model.g.dart` (fromJson/toJson)

---

## 22. Testing Checklist

- [ ] Start audio call from chat header → Firestore doc created with `status: ringing`, `type: audio`
- [ ] Start video call from chat header → Firestore doc created with `status: ringing`, `type: video`
- [ ] Self-call prevention → ShowToast error, no Firestore doc created
- [ ] Duplicate call prevention → ShowToast error when call already ringing/active
- [ ] Receiver sees incoming call dialog with correct caller info
- [ ] Accept call → Firestore status changes to `accepted`, both users on CallScreen
- [ ] Reject call → Firestore status changes to `rejected`, dialog dismissed, caller sees ended
- [ ] End call → Firestore status `ended`, duration recorded, both exit CallScreen
- [ ] Caller cancels while ringing → Firestore status `ended`, duration 0
- [ ] Timer shows `mm:ss` starting from accept time, not ring time
- [ ] Mute/unmute toggles mic correctly
- [ ] Speaker toggle works
- [ ] Camera toggle works for video calls
- [ ] Call history shows all calls for current user
- [ ] Call history empty state shows localized message
- [ ] Call history card shows correct: participant info, type icon, status, time, duration
- [ ] Existing chat messaging still works after integration
- [ ] No hardcoded strings — all labels use `context.translate(LangKeys.xxx)`
- [ ] Arabic translations display correctly
- [ ] Agora channel is left/released on call end
- [ ] Camera/mic permissions requested on Android and iOS

---

## 23. Common Mistakes to Avoid

1. **Do NOT put call state into SelectedChatCubit or MessagesCubit** — calls have their own Cubits
2. **Do NOT mix StartCallCubit with ActiveCallCubit** — starting is a one-shot action, active is a stream listener
3. **Do NOT mix CallsHistoryCubit with ActiveCallCubit** — history is a list, active is a single call
4. **Do NOT use `FirebaseFirestore.instance` directly** — use `DataBaseService` (except for generating doc IDs)
5. **Do NOT forget to cancel StreamSubscriptions** in Cubit `close()` methods
6. **Do NOT forget `part` directives** for `.g.dart` files in CallModel
7. **Do NOT hardcode strings** — always use `context.translate(LangKeys.xxx)`
8. **Do NOT forget ScreenUtil** for sizes — use `.w`, `.h`, `.sp`, `.r` extensions
9. **Do NOT forget to register new classes in GetIt** — every data source, repo, cubit needs registration
10. **Do NOT forget to add Agora App ID** as a constant, not inline
11. **Do NOT forget platform permissions** — AndroidManifest.xml and Info.plist
12. **Do NOT forget to run build_runner** after creating `CallModel` with `@JsonSerializable()`
13. **Do NOT rebuild SingleChatScreen** — only add AppBar actions and one BlocProvider/BlocListener
14. **Do NOT forget to leave Agora channel** before popping CallScreen
15. **Duration is from `acceptedAt`**, not `startedAt` — use talk time only
16. **Caller cancel = `ended` with 0 duration**, not `missed` or `cancelled`

---

## Complexity Tracking

No constitution violations to justify. Architecture follows existing patterns.

---

## ChatModel Data Gap

**Important**: `ChatModel` only contains `users: List<String>` (UIDs) and `usersEmails: List<String>?` (emails). It does NOT contain user name or photoUrl.

**Solution**: When starting a call, `CallsRemoteDataSourceImpl.startCall()` must fetch the receiver's user document from `usersCollection` to get `name` and `photoUrl`. The caller's info comes from `getCurrentUser()` which has `name`, `email`, `photoUrl`.

```dart
// In startCall():
final receiverDoc = await _dataBaseService.getDocument(
  path: '$usersCollection/$receiverId',
  builder: (data, id) => data,
);
final receiverName = receiverDoc['name'] as String? ?? '';
final receiverPhotoUrl = receiverDoc['photoUrl'] as String?;
```
