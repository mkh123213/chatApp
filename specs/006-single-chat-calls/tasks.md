# Tasks: Single Chat Calls

**Input**: Design documents from `specs/006-single-chat-calls/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Organization**: Tasks follow the user's specified ordering, grouped by phase. Each user story can be tested independently after its phase completes.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1=Start Call, US2=Incoming Call, US3=Active Call, US4=Call History)
- Exact file paths included in all tasks

## Common Mistakes to Avoid

> **Read before starting ANY task:**
> - Do NOT rebuild existing single chat feature
> - Do NOT mix StartCallCubit with ActiveCallCubit
> - Do NOT mix CallsHistoryCubit with ActiveCallCubit
> - Do NOT put call state inside SelectedChatCubit
> - Do NOT use `FirebaseFirestore.instance` directly (use `DataBaseService`) except for generating doc IDs
> - Do NOT forget duplicate active call check before starting a call
> - Do NOT forget self-call prevention
> - Do NOT forget to save `acceptedAt` and `endedAt` timestamps
> - Duration = `endedAt - acceptedAt` (talk time only), NOT from `startedAt`
> - Do NOT forget to listen to call document changes in real time
> - Do NOT use wrong `currentUserId` in incoming call listener
> - Do NOT create separate Cubit instances between AppBar and BlocListener — use same provider
> - Do NOT hardcode labels — always use `context.translate(LangKeys.xxx)`
> - Do NOT forget to run `build_runner` after creating models
> - Do NOT forget to handle empty/error/loading states
> - Always use `TextApp`, `CustomLinearButton`, `ShowToast`, `context.textStyle`, `context.color`, `ScreenUtil`

---

## Phase 1: Setup (Constants, Dependencies, Model)

**Purpose**: Project constants, model foundation, and code generation

- [x] T001 [P] Add Firestore constant and call status constants in `lib/constants/fierstore_paths.dart` and new `lib/features/calls/data/models/call_status.dart`
  - Goal: Define `callsCollection` constant and call status string constants
  - Files: `lib/constants/fierstore_paths.dart`, `lib/features/calls/data/models/call_status.dart`
  - Details: Add `const String callsCollection = 'calls';` to fierstore_paths.dart. Create call_status.dart with `class CallStatus { static const String ringing = 'ringing'; static const String accepted = 'accepted'; static const String rejected = 'rejected'; static const String ended = 'ended'; static const String missed = 'missed'; }` and `class CallType { static const String audio = 'audio'; static const String video = 'video'; }`
  - Acceptance criteria: Constants compile without errors. No existing constants modified.

- [x] T002 [P] Add `agora_rtc_engine` and `permission_handler` to `pubspec.yaml`
  - Goal: Add call provider dependencies
  - Files: `pubspec.yaml`
  - Details: Add `agora_rtc_engine: ^6.3.0` and `permission_handler: ^11.0.0` under dependencies. Run `flutter pub get`.
  - Acceptance criteria: `flutter pub get` succeeds without errors.

- [x] T003 [P] Create Agora constants file at `lib/constants/agora_constants.dart`
  - Goal: Store Agora App ID constant
  - Files: `lib/constants/agora_constants.dart`
  - Details: Create file with `const String agoraAppId = 'YOUR_AGORA_APP_ID_HERE';`. Developer replaces with their actual Agora App ID.
  - Acceptance criteria: File exists and compiles.

- [x] T004 [P] Add Android permissions to `android/app/src/main/AndroidManifest.xml`
  - Goal: Enable camera, mic, and network permissions for Android
  - Files: `android/app/src/main/AndroidManifest.xml`
  - Details: Add `<uses-permission android:name="android.permission.RECORD_AUDIO" />`, `<uses-permission android:name="android.permission.CAMERA" />`, `<uses-permission android:name="android.permission.INTERNET" />`, `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />`, `<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />`
  - Acceptance criteria: Permissions added without duplicating existing entries.

- [x] T005 [P] Add iOS permissions to `ios/Runner/Info.plist`
  - Goal: Enable camera and mic permissions for iOS
  - Files: `ios/Runner/Info.plist`
  - Details: Add `NSMicrophoneUsageDescription` ("This app requires microphone access for audio calls") and `NSCameraUsageDescription` ("This app requires camera access for video calls")
  - Acceptance criteria: Permissions added to Info.plist.

- [x] T006 Create `CallModel` in `lib/features/calls/data/models/call_model.dart`
  - Goal: Define the call data model with all fields from the data model spec
  - Files: `lib/features/calls/data/models/call_model.dart`
  - Details: Create `@JsonSerializable()` class with fields: `id`, `chatId`, `callerId`, `callerName`, `callerEmail`, `callerPhotoUrl?`, `receiverId`, `receiverName`, `receiverEmail`, `receiverPhotoUrl?`, `type`, `status`, `startedAt?`, `acceptedAt?`, `endedAt?`, `durationInSeconds` (default 0), `channelId`, `createdAt?`, `updatedAt?`. Add `@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)` for all DateTime fields using the same Timestamp converter pattern from `ChatModel`. Add `fromJson`, `toJson`, `fromFirestore` factory. Add `part 'call_model.g.dart';`
  - Acceptance criteria: Class compiles (except for missing .g.dart which will be generated in T007). All fields match data-model.md exactly.

- [x] T007 Run `build_runner` to generate `call_model.g.dart`
  - Goal: Generate json_serializable code for CallModel
  - Files: `lib/features/calls/data/models/call_model.g.dart` (generated)
  - Details: Run `dart run build_runner build --delete-conflicting-outputs` from project root.
  - Acceptance criteria: `call_model.g.dart` generated. `CallModel.fromJson()` and `toJson()` work. No build errors.

**Checkpoint**: Model foundation ready. CallModel can serialize/deserialize Firestore data.

---

## Phase 2: Foundational (Data Source, Repository, Cubits, DI)

**Purpose**: Core data layer and state management that ALL user stories depend on

**⚠️ CRITICAL**: No UI or integration work can begin until this phase is complete

### Data Source

- [x] T008 Create `CallsRemoteDataSource` abstract class in `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Goal: Define the abstract interface for all calls remote operations
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Create abstract class with methods: `Future<CallModel> startCall({required ChatModel chat, required CurrentUserModel caller, required String type})`, `Stream<CallModel?> listenForIncomingCalls({required String currentUserId})`, `Stream<CallModel> listenToCall({required String callId})`, `Future<void> acceptCall({required String callId})`, `Future<void> rejectCall({required String callId})`, `Future<void> endCall({required String callId, required int durationInSeconds})`, `Stream<List<CallModel>> getCallsHistory({required String currentUserId})`, `Future<bool> hasActiveCallBetweenUsers({required String chatId})`. Also create `CallsRemoteDataSourceImpl` class that implements the abstract and takes `DataBaseService` in constructor (same pattern as `ChatsRemoteDataSourceImpl`). Implement methods in T009-T016.
  - Acceptance criteria: Abstract and impl class compile. Impl constructor takes `DataBaseService _dataBaseService`.

- [x] T009 Implement `hasActiveCallBetweenUsers` in `CallsRemoteDataSourceImpl`
  - Goal: Check if a ringing or accepted call already exists between two users
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Query `callsCollection` using `_dataBaseService.getCollection` with `queryBuilder: (q) => q.where('chatId', isEqualTo: chatId).where('status', whereIn: ['ringing', 'accepted'])`. Return `result.isNotEmpty`. The `chatId` is the sorted UIDs joined by `_`.
  - Acceptance criteria: Returns `true` when a ringing/accepted call exists for the chatId. Returns `false` otherwise.

- [x] T010 Implement `startCall` in `CallsRemoteDataSourceImpl`
  - Goal: Create a new call document in Firestore
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: (1) Determine `receiverId` from `chat.users` (the UID that is not `caller.uid`). (2) Check self-call: if `receiverId == caller.uid`, throw exception. (3) Create `chatId` from sorted `[caller.uid, receiverId].join('_')`. (4) Check `hasActiveCallBetweenUsers(chatId)` — if true, throw exception. (5) Fetch receiver user doc from `usersCollection` via `_dataBaseService.getDocument(path: '$usersCollection/$receiverId')` to get `name`, `photoUrl`, `email`. (6) Generate `callId` via `FirebaseFirestore.instance.collection(callsCollection).doc().id`. (7) Generate `channelId` as `'call_$callId'`. (8) Build `CallModel` with all fields, status `'ringing'`, `startedAt: DateTime.now()`, `createdAt: DateTime.now()`, `updatedAt: DateTime.now()`. (9) Save via `_dataBaseService.setData(path: '$callsCollection/$callId', data: callModel.toJson())`. (10) Return the `CallModel`.
  - Acceptance criteria: Creates Firestore doc with correct fields. Prevents self-call. Prevents duplicate active call. Fetches receiver data from users collection.

- [x] T011 Implement `listenForIncomingCalls` in `CallsRemoteDataSourceImpl`
  - Goal: Stream incoming ringing calls for the current user
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Use `_dataBaseService.collectionStream<CallModel>(path: callsCollection, queryBuilder: (q) => q.where('receiverId', isEqualTo: currentUserId).where('status', isEqualTo: 'ringing'), builder: (data, id) => CallModel.fromFirestore(id: id, data: data))`. Map the `List<CallModel>` stream to `CallModel?` by returning `list.isNotEmpty ? list.first : null`.
  - Acceptance criteria: Returns stream that emits `CallModel` when a ringing call targets the user. Emits `null` when no ringing calls exist.

- [x] T012 Implement `listenToCall` in `CallsRemoteDataSourceImpl`
  - Goal: Stream a specific call document for real-time status updates
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Use `_dataBaseService.documentStream<CallModel>(path: '$callsCollection/$callId', builder: (data, id) => CallModel.fromFirestore(id: id, data: data))`.
  - Acceptance criteria: Returns stream that emits updated `CallModel` every time the Firestore document changes.

- [x] T013 Implement `acceptCall` in `CallsRemoteDataSourceImpl`
  - Goal: Update call status to accepted with acceptedAt timestamp
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Use `_dataBaseService.setData(path: '$callsCollection/$callId', data: {'status': 'accepted', 'acceptedAt': Timestamp.now(), 'updatedAt': Timestamp.now()})`.
  - Acceptance criteria: Firestore doc status changes to `'accepted'`. `acceptedAt` is set.

- [x] T014 Implement `rejectCall` in `CallsRemoteDataSourceImpl`
  - Goal: Update call status to rejected with endedAt timestamp
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Use `_dataBaseService.setData(path: '$callsCollection/$callId', data: {'status': 'rejected', 'endedAt': Timestamp.now(), 'updatedAt': Timestamp.now()})`.
  - Acceptance criteria: Firestore doc status changes to `'rejected'`. `endedAt` is set.

- [x] T015 Implement `endCall` in `CallsRemoteDataSourceImpl`
  - Goal: Update call status to ended with duration and endedAt
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Use `_dataBaseService.setData(path: '$callsCollection/$callId', data: {'status': 'ended', 'endedAt': Timestamp.now(), 'durationInSeconds': durationInSeconds, 'updatedAt': Timestamp.now()})`.
  - Acceptance criteria: Firestore doc status changes to `'ended'`. `endedAt` and `durationInSeconds` are set correctly.

- [x] T016 Implement `getCallsHistory` in `CallsRemoteDataSourceImpl`
  - Goal: Stream all call history where current user is caller or receiver
  - Files: `lib/features/calls/data/datasources/calls_remote_data_source.dart`
  - Details: Create two separate collection streams: (1) `_dataBaseService.collectionStream` where `callerId == currentUserId`, (2) where `receiverId == currentUserId`. Use `Rx.combineLatest2` (from `rxdart`) or manual `StreamZip`/merge to combine both lists. Deduplicate by `call.id`, sort by `createdAt` descending. If not using rxdart, use two stream subscriptions and emit combined result.
  - Acceptance criteria: Returns stream of `List<CallModel>` containing all calls for the user, sorted newest first, no duplicates.

### Repository

- [x] T017 Create `CallsRepo` abstract and impl in `lib/features/calls/data/repositories/calls_repo.dart`
  - Goal: Repository layer that delegates to remote data source
  - Files: `lib/features/calls/data/repositories/calls_repo.dart`
  - Details: Create `abstract class CallsRepo` with all methods mirroring `CallsRemoteDataSource`. Create `class CallsRepoImpl implements CallsRepo` that takes `CallsRemoteDataSource` in constructor and delegates all calls. Follow exact pattern from `ChatsRepo` / `ChatsRepoImpl`.
  - Acceptance criteria: All methods delegate to data source. Same pattern as existing repos.

### Cubits and States

- [x] T018 [P] Create `StartCallState` in `lib/features/calls/presentation/bloc/start_call_cubit/start_call_state.dart`
  - Goal: Define states for call initiation
  - Files: `lib/features/calls/presentation/bloc/start_call_cubit/start_call_state.dart`
  - Details: Create sealed class hierarchy following `ChatsState` pattern: `sealed class StartCallState { const StartCallState(); }`, `final class StartCallInitial extends StartCallState { const StartCallInitial(); }`, `final class StartCallLoading extends StartCallState { const StartCallLoading(); }`, `final class StartCallSuccess extends StartCallState { const StartCallSuccess({required this.call}); final CallModel call; }`, `final class StartCallError extends StartCallState { const StartCallError({required this.message}); final String message; }`
  - Acceptance criteria: All 4 states defined. Matches existing sealed class pattern.

- [x] T019 Create `StartCallCubit` in `lib/features/calls/presentation/bloc/start_call_cubit/start_call_cubit.dart`
  - Goal: Cubit that handles starting audio/video calls
  - Files: `lib/features/calls/presentation/bloc/start_call_cubit/start_call_cubit.dart`
  - Details: Constructor takes `CallsRepo`. Two async methods: `startAudioCall({required ChatModel chat})` and `startVideoCall({required ChatModel chat})`. Both: (1) emit `StartCallLoading()`, (2) try `callsRepo.startCall(chat: chat, caller: getCurrentUser(), type: 'audio'/'video')`, (3) emit `StartCallSuccess(call: result)`, catch → emit `StartCallError(message: e.toString())`. Self-call check: compare `getCurrentUser().uid` with friend uid from `chat.users`.
  - Acceptance criteria: Emits loading then success/error. Self-call and duplicate call prevention work (duplicate check is in data source).

- [x] T020 [P] Create `IncomingCallState` in `lib/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_state.dart`
  - Goal: Define states for incoming call listening
  - Files: `lib/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_state.dart`
  - Details: Sealed classes: `IncomingCallInitial`, `IncomingCallListening`, `IncomingCallReceived({required CallModel call})`, `IncomingCallNone`, `IncomingCallError({required String message})`.
  - Acceptance criteria: All 5 states defined.

- [x] T021 Create `IncomingCallCubit` in `lib/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_cubit.dart`
  - Goal: Cubit that listens for incoming ringing calls globally
  - Files: `lib/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_cubit.dart`
  - Details: Constructor takes `CallsRepo`. Holds `StreamSubscription? _subscription`. Method `listenForIncomingCalls({required String currentUserId})`: emit `IncomingCallListening()`, subscribe to `callsRepo.listenForIncomingCalls(currentUserId)`, on data: if call != null emit `IncomingCallReceived(call)` else emit `IncomingCallNone()`, on error: emit `IncomingCallError`. Method `stopListening()`: cancel subscription. Override `close()`: cancel subscription.
  - Acceptance criteria: Listens to incoming calls stream. Emits correct states. Cancels subscription on close.

- [x] T022 [P] Create `ActiveCallState` in `lib/features/calls/presentation/bloc/active_call_cubit/active_call_state.dart`
  - Goal: Define states for active call management
  - Files: `lib/features/calls/presentation/bloc/active_call_cubit/active_call_state.dart`
  - Details: Sealed classes: `ActiveCallInitial`, `ActiveCallLoading`, `ActiveCallActive({required CallModel call})`, `ActiveCallEnded`, `ActiveCallError({required String message})`.
  - Acceptance criteria: All 5 states defined.

- [x] T023 Create `ActiveCallCubit` in `lib/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart`
  - Goal: Cubit that manages active call screen state and actions
  - Files: `lib/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart`
  - Details: Constructor takes `CallsRepo` and `CallProviderService`. Holds `StreamSubscription? _callSubscription`. Method `listenToCall({required String callId})`: emit `ActiveCallLoading`, subscribe to `callsRepo.listenToCall(callId)`, on data: if `call.status` is `ended`/`rejected`/`missed` emit `ActiveCallEnded` else emit `ActiveCallActive(call)`. Method `acceptCall({required CallModel call})`: call `callsRepo.acceptCall(callId: call.id)`. Method `rejectCall({required CallModel call})`: call `callsRepo.rejectCall(callId: call.id)`. Method `endCall({required CallModel call, required int durationInSeconds})`: call `callsRepo.endCall(callId: call.id, durationInSeconds: durationInSeconds)`. Override `close()`: cancel subscription.
  - Acceptance criteria: Listens to call document. Emits ActiveCallActive on status changes. Emits ActiveCallEnded on terminal status. Accept/reject/end update Firestore.

- [x] T024 [P] Create `CallsHistoryState` in `lib/features/calls/presentation/bloc/calls_history_cubit/calls_history_state.dart`
  - Goal: Define states for calls history
  - Files: `lib/features/calls/presentation/bloc/calls_history_cubit/calls_history_state.dart`
  - Details: Sealed classes: `CallsHistoryInitial`, `CallsHistoryLoading`, `CallsHistoryLoaded({required List<CallModel> calls})`, `CallsHistoryEmpty`, `CallsHistoryError({required String message})`.
  - Acceptance criteria: All 5 states defined.

- [x] T025 Create `CallsHistoryCubit` in `lib/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart`
  - Goal: Cubit that loads and holds call history list
  - Files: `lib/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart`
  - Details: Constructor takes `CallsRepo`. Holds `StreamSubscription? _subscription`. Method `getCallsHistory({required String currentUserId})`: emit `CallsHistoryLoading`, subscribe to `callsRepo.getCallsHistory(currentUserId)`, on data: if empty emit `CallsHistoryEmpty` else emit `CallsHistoryLoaded(calls)`, on error: emit `CallsHistoryError`. Override `close()`: cancel subscription.
  - Acceptance criteria: Streams call history. Handles empty/loaded/error states. Cancels subscription on close.

### Call Provider Abstraction

- [x] T026 [P] Create `CallProviderService` abstract in `lib/features/calls/call_provider/call_provider_service.dart`
  - Goal: Define abstract interface for call provider (Agora, ZegoCloud, etc.)
  - Files: `lib/features/calls/call_provider/call_provider_service.dart`
  - Details: Abstract class with methods: `Future<void> initialize()`, `Future<void> joinChannel({required String channelId, required String token, required int uid, required bool isVideo})`, `Future<void> leaveChannel()`, `Future<void> toggleMute(bool muted)`, `Future<void> toggleSpeaker(bool speakerOn)`, `Future<void> toggleCamera(bool cameraOn)`, `Future<void> switchCamera()`, `Future<void> dispose()`.
  - Acceptance criteria: Abstract class compiles. No Agora-specific imports.

- [x] T027 Create `AgoraCallProviderService` in `lib/features/calls/call_provider/agora_call_provider_service.dart`
  - Goal: Implement Agora SDK integration behind the abstract interface
  - Files: `lib/features/calls/call_provider/agora_call_provider_service.dart`
  - Details: Implements `CallProviderService`. Uses `agora_rtc_engine` package. `initialize()`: create `RtcEngine` with App ID from `agora_constants.dart`. `joinChannel()`: set channel profile, enable audio, optionally enable video, call `engine.joinChannel(token: token, channelId: channelId, uid: uid, options: ChannelMediaOptions(...))`. `leaveChannel()`: call `engine.leaveChannel()`. Toggle methods: call corresponding engine methods (`muteLocalAudioStream`, `setEnableSpeakerphone`, `muteLocalVideoStream`, `switchCamera`). `dispose()`: `leaveChannel()` then `engine.release()`.
  - Acceptance criteria: Agora engine initializes. Join/leave channel work. All toggles delegate to engine.

### Dependency Injection

- [x] T028 Register calls dependencies in GetIt at `lib/core/di/injection_container.dart`
  - Goal: Register all calls data source, repo, cubits, and provider in GetIt
  - Files: `lib/core/di/injection_container.dart`
  - Details: Add `_initCalls()` function. Register: `CallProviderService` → `AgoraCallProviderService` (lazySingleton), `CallsRemoteDataSource` → `CallsRemoteDataSourceImpl(dataBaseService: sl<DataBaseService>())` (lazySingleton), `CallsRepo` → `CallsRepoImpl(callsRemoteDataSource: sl<CallsRemoteDataSource>())` (lazySingleton), `StartCallCubit` (factory), `IncomingCallCubit` (factory), `ActiveCallCubit` (factory, takes callsRepo + callProviderService), `CallsHistoryCubit` (factory). Call `await _initCalls()` in `setupInjector()`. Add all necessary imports.
  - Acceptance criteria: All 7 registrations complete. `setupInjector()` calls `_initCalls()`. App compiles.

### Localization

- [x] T029 [P] Add call-related LangKeys in `lib/core/language/lang_keys.dart`
  - Goal: Add all localization keys for the calls feature
  - Files: `lib/core/language/lang_keys.dart`
  - Details: Add under a `// Calls feature` comment: `calls`, `audioCall`, `videoCall`, `incomingCall`, `outgoingCall`, `missedCall`, `rejectedCall`, `endedCall`, `startCall`, `acceptCall`, `rejectCall`, `endCall`, `calling`, `ringing`, `connected`, `callEnded`, `callRejected`, `callMissed`, `mute`, `unmute`, `speaker`, `camera`, `switchCamera`, `noCallsYet`, `callHistory`, `cannotCallYourself`, `callAlreadyActive`. Use snake_case values (e.g., `static const String audioCall = 'audio_call';`).
  - Acceptance criteria: All 28 keys added. Snake_case string values match the JSON keys.

- [x] T030 [P] Add English translations in `lang/en.json`
  - Goal: Add English text for all call-related keys
  - Files: `lang/en.json`
  - Details: Add all 28 entries as defined in plan.md section 18. Example: `"audio_call": "Audio Call"`, `"cannot_call_yourself": "Cannot call yourself"`, etc.
  - Acceptance criteria: All 28 entries present. Valid JSON.

- [x] T031 [P] Add Arabic translations in `lang/ar.json`
  - Goal: Add Arabic text for all call-related keys
  - Files: `lang/ar.json`
  - Details: Add all 28 entries as defined in plan.md section 18 (Arabic). Example: `"audio_call": "مكالمة صوتية"`, `"cannot_call_yourself": "لا يمكنك الاتصال بنفسك"`, etc.
  - Acceptance criteria: All 28 entries present. Valid JSON. Arabic text is correct.

### Routes

- [x] T032 Add call routes in `lib/core/routes/app_routes.dart`
  - Goal: Register callScreen and callsHistoryScreen routes
  - Files: `lib/core/routes/app_routes.dart`
  - Details: Add `static const String callScreen = 'callScreen';` and `static const String callsHistoryScreen = 'callsHistoryScreen';` to `AppRoutes` class. Add cases in `onGenerateRoute`: `case callScreen: return BaseRoute(page: CallScreen(call: args as CallModel));` and `case callsHistoryScreen: return BaseRoute(page: const CallsHistoryScreen());`. Add necessary imports. Note: `CallScreen` and `CallsHistoryScreen` will be created in later tasks — this task can add the route cases with TODO comments if the widgets don't exist yet, or be done after UI tasks.
  - Acceptance criteria: Route constants defined. Route cases added (even if widget imports are pending).

**Checkpoint**: Foundation ready. All data layer, state management, DI, localization, and routes are in place. User story implementation can begin.

---

## Phase 3: User Story 1 — Start a Call from Chat (Priority: P1) 🎯 MVP

**Goal**: User can tap audio/video call icons in the selected chat header to initiate a call and navigate to the call screen.

**Independent Test**: Open an existing chat → see call icons in header → tap audio call → Firestore doc created → navigated to CallScreen showing ringing state.

### Implementation for User Story 1

- [x] T033 [US1] Add audio/video call icons to existing selected chat header in `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Goal: Add call action buttons to the AppBar without rebuilding the screen
  - Files: `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Details: Add `BlocProvider<StartCallCubit>(create: (_) => sl<StartCallCubit>())` to the existing `MultiBlocProvider.providers` list. Add `actions` to the `AppBar`: `IconButton(icon: Icon(Icons.videocam), onPressed: ...)` and `IconButton(icon: Icon(Icons.call), onPressed: ...)`. The onPressed callbacks will be connected in T034/T035. Do NOT modify the body, messaging cubits, or any existing widgets.
  - Acceptance criteria: Audio call icon (phone) and video call icon (videocam) appear in the AppBar. Existing chat messaging still works. No changes to body or other providers.

- [x] T034 [US1] Connect audio call icon to `StartCallCubit.startAudioCall` in `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Goal: Tapping audio icon triggers call start
  - Files: `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Details: Set audio icon `onPressed` to `() => context.read<StartCallCubit>().startAudioCall(chat: chat)`.
  - Acceptance criteria: Tapping audio icon calls `startAudioCall`. Firestore doc created with `type: 'audio'`.

- [x] T035 [US1] Connect video call icon to `StartCallCubit.startVideoCall` in `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Goal: Tapping video icon triggers call start
  - Files: `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Details: Set video icon `onPressed` to `() => context.read<StartCallCubit>().startVideoCall(chat: chat)`.
  - Acceptance criteria: Tapping video icon calls `startVideoCall`. Firestore doc created with `type: 'video'`.

- [x] T036 [US1] Add `BlocListener<StartCallCubit>` to navigate on success and show errors in `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Goal: Navigate to CallScreen on call start success, show toast on error
  - Files: `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Details: Wrap existing `BlocListener<SendMessageCubit>` in a `MultiBlocListener` (or nest). Add `BlocListener<StartCallCubit, StartCallState>(listener: (context, state) { if (state is StartCallSuccess) Navigator.pushNamed(context, AppRoutes.callScreen, arguments: state.call); else if (state is StartCallError) ShowToast.showToastErrorTop(message: state.message); })`. Handle self-call and duplicate call errors with localized messages using `context.translate(LangKeys.cannotCallYourself)` and `context.translate(LangKeys.callAlreadyActive)`.
  - Acceptance criteria: On success → navigates to callScreen route with CallModel. On error → shows error toast. Same StartCallCubit instance used by both icons and listener.

- [x] T037 [US1] Create `CallScreen` in `lib/features/calls/presentation/screens/call_screen.dart`
  - Goal: Main call screen that provides ActiveCallCubit and initializes call listening
  - Files: `lib/features/calls/presentation/screens/call_screen.dart`
  - Details: `StatefulWidget` that receives `CallModel call` as constructor parameter. In `initState` or via `BlocProvider(create: ...)`, provide `ActiveCallCubit` and call `listenToCall(callId: call.id)`. Also initialize `CallProviderService` (get from `sl()`) and join Agora channel. Full `Scaffold` with body: `CallBody(call: call)`. Override `dispose()` to leave Agora channel.
  - Acceptance criteria: Screen shows when navigated to. ActiveCallCubit listens to call document. Agora channel joined.

- [x] T038 [US1] Create `CallBody` in `lib/features/calls/presentation/refactor/call_body.dart`
  - Goal: Layout widget for call screen content
  - Files: `lib/features/calls/presentation/refactor/call_body.dart`
  - Details: `StatelessWidget` that takes `CallModel call`. Returns `Column` with: `CallHeader` (top), `Spacer()` (middle), `CallControls` (bottom). Wraps in `ActiveCallBlocConsumer` for state-driven rendering.
  - Acceptance criteria: Layout shows header at top, controls at bottom.

- [x] T039 [US1] Create `ActiveCallBlocConsumer` in `lib/features/calls/presentation/widgets/active_call_bloc_consumer.dart`
  - Goal: BlocConsumer that handles active call state changes
  - Files: `lib/features/calls/presentation/widgets/active_call_bloc_consumer.dart`
  - Details: `BlocConsumer<ActiveCallCubit, ActiveCallState>`. Listener: on `ActiveCallEnded` → leave Agora channel via `sl<CallProviderService>().leaveChannel()`, then `Navigator.pop(context)`. Builder: on `ActiveCallActive(call)` → render `CallBody` content with updated call data. On `ActiveCallLoading` → show loading indicator. On `ActiveCallError` → show error with `ShowToast`.
  - Acceptance criteria: Reacts to state changes. Pops screen on call end. Updates UI on call status change.

- [x] T040 [US1] Create `CallHeader` in `lib/features/calls/presentation/widgets/call_header.dart`
  - Goal: Display friend info, call type, status, and timer
  - Files: `lib/features/calls/presentation/widgets/call_header.dart`
  - Details: Takes `CallModel call` and `bool isCurrentUserCaller`. Shows: `CircleAvatar` with friend photo (caller or receiver depending on who current user is), friend name via `TextApp`, call type label (localized: `context.translate(LangKeys.audioCall)` or `videoCall`), status text (localized: ringing/connected/callEnded), timer text (mm:ss format, only visible when status is `accepted`). Use `context.textStyle`, `context.color`, `ScreenUtil` for sizing.
  - Acceptance criteria: Avatar, name, type, and status display correctly. Timer shows only during accepted state.

- [x] T041 [US1] Create `CallControls` in `lib/features/calls/presentation/widgets/call_controls.dart`
  - Goal: Call action buttons (mute, speaker, camera, end)
  - Files: `lib/features/calls/presentation/widgets/call_controls.dart`
  - Details: `StatefulWidget`. Takes `CallModel call` and `VoidCallback onEndCall`. Row of `IconButton`s: mute toggle (Icons.mic / Icons.mic_off), speaker toggle (Icons.volume_up / Icons.volume_off), camera toggle for video calls only (Icons.videocam / Icons.videocam_off), switch camera for video calls only (Icons.cameraswitch), end call button (red circle, Icons.call_end). Toggle states managed with local `bool` fields (`_isMuted`, `_isSpeakerOn`, `_isCameraOff`). Each toggle calls `sl<CallProviderService>().toggleMute(...)` etc. End call button calls `onEndCall`. Use `ScreenUtil` for sizes.
  - Acceptance criteria: All buttons render. Toggle states update visually. End call triggers callback. Camera controls only show for video calls.

**Checkpoint**: User Story 1 complete. User can start audio/video calls from chat header and see the call screen with ringing state. Firestore docs created correctly.

---

## Phase 4: User Story 2 — Receive and Respond to Incoming Call (Priority: P1)

**Goal**: Receiver sees an incoming call dialog/overlay globally and can accept or reject the call.

**Independent Test**: User A starts a call → User B (on any screen) sees incoming call dialog → User B accepts or rejects → Firestore status updates correctly.

### Implementation for User Story 2

- [x] T042 [US2] Create `IncomingCallDialog` in `lib/features/calls/presentation/widgets/incoming_call_dialog.dart`
  - Goal: Dialog showing incoming call with accept/reject buttons
  - Files: `lib/features/calls/presentation/widgets/incoming_call_dialog.dart`
  - Details: `StatelessWidget` that takes `CallModel call`. Shows: `CircleAvatar` with caller photo, caller name via `TextApp`, caller email, call type label (localized), accept button (green, `CustomLinearButton` or `IconButton` with Icons.call, `context.translate(LangKeys.acceptCall)`), reject button (red, Icons.call_end, `context.translate(LangKeys.rejectCall)`). Accept: creates `ActiveCallCubit`, calls `acceptCall(call)`, navigates to `callScreen` route, dismisses dialog. Reject: creates `ActiveCallCubit`, calls `rejectCall(call)`, dismisses dialog. Use `context.textStyle`, `context.color`, `ScreenUtil`.
  - Acceptance criteria: Dialog shows caller info. Accept navigates to call screen and updates Firestore. Reject updates Firestore and dismisses.

- [x] T043 [US2] Create `IncomingCallOverlay` in `lib/features/calls/presentation/widgets/incoming_call_overlay.dart`
  - Goal: Optional overlay wrapper for showing incoming call dialog globally
  - Files: `lib/features/calls/presentation/widgets/incoming_call_overlay.dart`
  - Details: Helper widget or function that can show `IncomingCallDialog` as an overlay entry or `showDialog` from any context. Takes `BuildContext` and `CallModel`. Can be a static method: `static void show(BuildContext context, CallModel call)` that calls `showDialog(context: context, barrierDismissible: false, builder: (_) => IncomingCallDialog(call: call))`.
  - Acceptance criteria: Can be called from MainScreen listener to show dialog on any screen.

- [x] T044 [US2] Add `IncomingCallCubit` provider and listener to `MainScreen` in `lib/features/main/presentation/screens/main_screen.dart`
  - Goal: Listen for incoming calls globally and show dialog
  - Files: `lib/features/main/presentation/screens/main_screen.dart`
  - Details: Add `BlocProvider<IncomingCallCubit>(create: (_) => sl<IncomingCallCubit>()..listenForIncomingCalls(currentUserId: getCurrentUser().uid))` to the providers. Add `BlocListener<IncomingCallCubit, IncomingCallState>(listener: (context, state) { if (state is IncomingCallReceived) { IncomingCallOverlay.show(context, state.call); } })` wrapping the body. Do NOT modify existing providers or body structure. Import required files.
  - Acceptance criteria: IncomingCallCubit starts listening on MainScreen creation. When a ringing call targets current user, dialog shows. Dialog shows from any tab (chats, groups, calls, settings).

- [x] T045 [US2] Handle 30-second missed call timeout in `CallScreen`
  - Goal: Auto-update call to missed if receiver doesn't answer within 30 seconds
  - Files: `lib/features/calls/presentation/screens/call_screen.dart`
  - Details: In `CallScreen`, when the initial call status is `ringing` and current user is the caller, start a 30-second `Timer`. On timeout, if call status is still `ringing`, call `ActiveCallCubit.endCall(call, durationInSeconds: 0)` and update Firestore status to `missed` (add a `missCall` method to data source, or handle via `endCall` with a special flag, or add `Future<void> missCall({required String callId})` to data source that sets `{'status': 'missed', 'endedAt': Timestamp.now(), 'updatedAt': Timestamp.now()}`). Cancel timer on dispose or when status changes from ringing.
  - Acceptance criteria: After 30 seconds of ringing with no response, call status updates to `missed`. Timer cancelled if call is accepted/rejected/ended before timeout.

**Checkpoint**: User Story 2 complete. Incoming calls detected globally. Accept/reject work. Missed call timeout works.

---

## Phase 5: User Story 3 — Manage an Active Call (Priority: P1)

**Goal**: Both users on an active call can see real-time status, timer, and use controls (mute, speaker, camera, end).

**Independent Test**: Start call → accept → both see "connected" status and running timer → mute/speaker/camera toggles work → end call → both exit, duration recorded.

### Implementation for User Story 3

- [x] T046 [US3] Add call duration timer to `CallHeader` in `lib/features/calls/presentation/widgets/call_header.dart`
  - Goal: Show running mm:ss timer when call is accepted
  - Files: `lib/features/calls/presentation/widgets/call_header.dart`
  - Details: Make `CallHeader` a `StatefulWidget`. When `call.status == 'accepted'`, start a periodic `Timer.periodic(Duration(seconds: 1))` that increments a `_seconds` counter. Display as `mm:ss` format using `TextApp`. Stop timer when widget disposes or call status changes to terminal. Calculate initial seconds from `DateTime.now().difference(call.acceptedAt!)` if `acceptedAt` is not null (handles rejoining).
  - Acceptance criteria: Timer starts at 00:00 (or correct offset) when status is accepted. Updates every second. Stops on dispose.

- [x] T047 [US3] Wire end call button to `ActiveCallCubit.endCall` in `CallControls` / `CallBody`
  - Goal: End call button updates Firestore and exits screen
  - Files: `lib/features/calls/presentation/widgets/call_controls.dart`, `lib/features/calls/presentation/refactor/call_body.dart`
  - Details: The `onEndCall` callback passed to `CallControls` should call `context.read<ActiveCallCubit>().endCall(call: currentCall, durationInSeconds: elapsedSeconds)`. Duration = seconds since `acceptedAt` (calculated from timer or `DateTime.now().difference(call.acceptedAt!).inSeconds`). If call was never accepted (still ringing), duration = 0. The `ActiveCallBlocConsumer` listener handles popping the screen on `ActiveCallEnded`.
  - Acceptance criteria: Tapping end call updates Firestore to `ended` with correct duration. Both users' screens pop via ActiveCallCubit listener.

- [x] T048 [US3] Ensure caller cancel while ringing sets `status: 'ended'` with `durationInSeconds: 0`
  - Goal: Caller can cancel before receiver answers
  - Files: `lib/features/calls/presentation/widgets/call_controls.dart`
  - Details: When call status is `ringing` and user taps end call, call `ActiveCallCubit.endCall(call: call, durationInSeconds: 0)`. This sets Firestore status to `ended` with 0 duration. The receiver's `IncomingCallCubit` detects the status is no longer `ringing` and the dialog auto-dismisses (or listener checks and dismisses).
  - Acceptance criteria: Caller can cancel ringing call. Status becomes `ended` with 0 duration. Receiver's incoming call dialog dismisses.

- [x] T049 [US3] Handle incoming call dialog auto-dismiss when call status changes in `lib/features/main/presentation/screens/main_screen.dart`
  - Goal: Dismiss incoming call dialog when call is no longer ringing (caller cancelled, timeout)
  - Files: `lib/features/main/presentation/screens/main_screen.dart`, `lib/features/calls/presentation/widgets/incoming_call_dialog.dart`
  - Details: In the `BlocListener<IncomingCallCubit>` listener, when state becomes `IncomingCallNone` after having been `IncomingCallReceived`, dismiss any open dialog via `Navigator.of(context).pop()` (if dialog is showing). Alternatively, make `IncomingCallDialog` itself listen to the call document and self-dismiss. Simplest: track if dialog is open with a flag and pop when state changes to `None`.
  - Acceptance criteria: Dialog disappears when caller cancels or timeout triggers missed.

**Checkpoint**: User Story 3 complete. Full call lifecycle works: start → accept → manage → end. Duration calculated from acceptedAt.

---

## Phase 6: User Story 4 — View Call History (Priority: P2)

**Goal**: User can view all past calls in the Calls tab with caller/receiver info, type, status, time, and duration.

**Independent Test**: Make several calls → navigate to Calls tab → see all calls with correct details → empty state when no calls.

### Implementation for User Story 4

- [x] T050 [US4] Create `CallsHistoryScreen` in `lib/features/calls/presentation/screens/calls_history_screen.dart`
  - Goal: Main screen for calls history tab
  - Files: `lib/features/calls/presentation/screens/calls_history_screen.dart`
  - Details: `StatelessWidget`. Body: `CallsHistoryBody()`. This screen is provided with `CallsHistoryCubit` from the parent (MainScreen or route).
  - Acceptance criteria: Screen renders. Delegates to CallsHistoryBody.

- [x] T051 [US4] Create `CallsHistoryBody` in `lib/features/calls/presentation/refactor/calls_history_body.dart`
  - Goal: Body layout with bloc consumer for call history list
  - Files: `lib/features/calls/presentation/refactor/calls_history_body.dart`
  - Details: Contains `CallsHistoryBlocConsumer` as child.
  - Acceptance criteria: Renders bloc consumer.

- [x] T052 [US4] Create `CallsHistoryBlocConsumer` in `lib/features/calls/presentation/widgets/calls_history_bloc_consumer.dart`
  - Goal: Handle all calls history states (loading, loaded, empty, error)
  - Files: `lib/features/calls/presentation/widgets/calls_history_bloc_consumer.dart`
  - Details: `BlocBuilder<CallsHistoryCubit, CallsHistoryState>`. On `CallsHistoryLoading` → `CircularProgressIndicator`. On `CallsHistoryLoaded(calls)` → `ListView.builder` of `CallHistoryCard` widgets. On `CallsHistoryEmpty` → centered `TextApp` with `context.translate(LangKeys.noCallsYet)`. On `CallsHistoryError` → `ShowToast` or error text.
  - Acceptance criteria: All 4 states handled. Empty state shows localized message. Loaded state shows list.

- [x] T053 [US4] Create `CallHistoryCard` in `lib/features/calls/presentation/widgets/call_history_card.dart`
  - Goal: Single card widget for a call history entry
  - Files: `lib/features/calls/presentation/widgets/call_history_card.dart`
  - Details: Takes `CallModel call`. Determine if current user is caller or receiver. Show: `CircleAvatar` with the other user's photo, other user's name via `TextApp`, `Row` with call type icon (Icons.call for audio, Icons.videocam for video) + status text (localized: ended/missed/rejected/outgoing/incoming), time (formatted from `createdAt`), duration if > 0 (formatted as mm:ss). Use `context.textStyle`, `context.color`, `ScreenUtil`.
  - Acceptance criteria: Card shows correct info. Differentiates caller/receiver perspective. Duration only shown when applicable.

- [x] T054 [US4] Integrate Calls tab with `CallsHistoryScreen` in `lib/features/main/presentation/screens/main_screen.dart`
  - Goal: Replace placeholder in Calls tab with CallsHistoryScreen
  - Files: `lib/features/main/presentation/screens/main_screen.dart`
  - Details: In the `BlocBuilder<MainCubit, MainState>` builder, change the `NavBarEnum.calls` case from `StatusScreen()` to `BlocProvider(create: (_) => sl<CallsHistoryCubit>()..getCallsHistory(currentUserId: getCurrentUser().uid), child: const CallsHistoryScreen())`.
  - Acceptance criteria: Calls tab shows call history. List loads from Firestore. Empty state works.

**Checkpoint**: User Story 4 complete. Full call history visible in Calls tab.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, cleanup, and manual testing

- [x] T055 Finalize route cases in `lib/core/routes/app_routes.dart` with actual widget imports
  - Goal: Ensure all route cases compile with real widget imports
  - Files: `lib/core/routes/app_routes.dart`
  - Details: Verify `callScreen` and `callsHistoryScreen` cases import `CallScreen` and `CallsHistoryScreen`. Ensure `args as CallModel` cast works. Remove any TODO comments from T032.
  - Acceptance criteria: Both routes resolve correctly. Navigation works.

- [x] T056 [P] Verify all imports and compilation
  - Goal: Ensure the full app compiles with all new files
  - Files: All new files
  - Details: Run `flutter analyze` and `flutter build` (or at least `flutter run`). Fix any missing imports, typos, or compilation errors.
  - Acceptance criteria: `flutter analyze` passes with no errors. App builds and runs.

- [x] T057 Manual testing — full call flow
  - Goal: Verify all acceptance criteria from the spec
  - Files: None (testing)
  - Details: Test on two devices/emulators:
    - [ ] Existing single chat messaging still works
    - [ ] Audio call icon appears in selected chat header
    - [ ] Video call icon appears in selected chat header
    - [ ] Start audio call → Firestore doc created with `type: audio`, `status: ringing`
    - [ ] Start video call → Firestore doc created with `type: video`, `status: ringing`
    - [ ] Self-call prevention → error toast shown
    - [ ] Duplicate active call prevention → error toast shown
    - [ ] Receiver sees incoming call dialog with caller info
    - [ ] Receiver accepts → status changes to `accepted`, both on call screen
    - [ ] Receiver rejects → status changes to `rejected`, dialog dismissed
    - [ ] Caller cancels while ringing → status `ended`, duration 0
    - [ ] Either user ends active call → status `ended`, duration correct
    - [ ] Call duration starts from `acceptedAt` (talk time only)
    - [ ] Call status updates in real time on both screens
    - [ ] Calls history loads in Calls tab
    - [ ] Calls history empty state shows localized message
    - [ ] Calls history error state handled
    - [ ] Missed call timeout (30s) works
    - [ ] Cubits are separated: StartCallCubit, IncomingCallCubit, ActiveCallCubit, CallsHistoryCubit
    - [ ] All UI uses TextApp, CustomLinearButton, ShowToast, context.translate, ScreenUtil
    - [ ] Arabic translations display correctly
    - [ ] Agora channel joined/left correctly
    - [ ] Camera/mic permissions requested
  - Acceptance criteria: All items checked off.

- [x] T058 Code cleanup and refactor
  - Goal: Remove debug prints, clean up imports, ensure consistent style
  - Files: All new files in `lib/features/calls/`
  - Details: Remove any `debugPrint` or `print` statements added during development. Ensure all imports follow project conventions (package imports, not relative). Verify no unused imports. Check that no existing features were modified beyond the specified integration points.
  - Acceptance criteria: Clean code. No debug artifacts. Consistent with project style.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 (T007 build_runner must complete first for CallModel)
- **Phase 3 (US1 - Start Call)**: Depends on Phase 2 completion (needs all cubits, DI, routes, lang)
- **Phase 4 (US2 - Incoming Call)**: Depends on Phase 2 + T037 CallScreen from Phase 3
- **Phase 5 (US3 - Active Call)**: Depends on Phase 3 + Phase 4 (needs CallScreen + IncomingCallDialog)
- **Phase 6 (US4 - Call History)**: Depends on Phase 2 only (can run in parallel with Phase 3-5)
- **Phase 7 (Polish)**: Depends on all previous phases

### User Story Dependencies

- **US1 (Start Call)**: After Foundational — independent
- **US2 (Incoming Call)**: After Foundational + needs CallScreen from US1
- **US3 (Active Call)**: After US1 + US2 (needs full call flow)
- **US4 (Call History)**: After Foundational — independent of US1/US2/US3

### Within Each Phase

- States (`[P]` marked) can be created in parallel with each other
- Cubits depend on their states being created first
- Data source implementations are sequential (each builds on the abstract class)
- UI tasks depend on cubits and routes being ready

### Parallel Opportunities

**Phase 1**: T001, T002, T003, T004, T005 all run in parallel

**Phase 2**: T018, T020, T022, T024 (all state files) run in parallel; T026 (CallProviderService abstract) in parallel; T029, T030, T031 (localization) in parallel

**Phase 6**: Can run in parallel with Phase 3-5 (independent data, separate screens)

---

## Parallel Example: Phase 1 Setup

```text
# All run in parallel:
Task T001: Add Firestore constants
Task T002: Add pubspec dependencies
Task T003: Create Agora constants
Task T004: Add Android permissions
Task T005: Add iOS permissions
```

## Parallel Example: Phase 2 State Files

```text
# All state files run in parallel:
Task T018: StartCallState
Task T020: IncomingCallState
Task T022: ActiveCallState
Task T024: CallsHistoryState
Task T026: CallProviderService abstract
```

## Parallel Example: Localization

```text
# All run in parallel:
Task T029: LangKeys
Task T030: en.json
Task T031: ar.json
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T007)
2. Complete Phase 2: Foundational (T008-T032)
3. Complete Phase 3: User Story 1 (T033-T041)
4. **STOP and VALIDATE**: Start a call from chat header → see CallScreen → Firestore doc created
5. Proceed to US2-US4

### Incremental Delivery

1. Phase 1 + Phase 2 → Foundation ready
2. Phase 3 (US1) → Start calls work → Test independently
3. Phase 4 (US2) → Incoming calls work → Test independently
4. Phase 5 (US3) → Full call management → Test independently
5. Phase 6 (US4) → Call history → Test independently
6. Phase 7 → Polish → Full manual testing

### Task Count Summary

| Phase   | Description         | Tasks     |
|---------|---------------------|-----------|
| Phase 1 | Setup               | T001-T007 (7 tasks)  |
| Phase 2 | Foundational        | T008-T032 (25 tasks) |
| Phase 3 | US1 - Start Call    | T033-T041 (9 tasks)  |
| Phase 4 | US2 - Incoming Call | T042-T045 (4 tasks)  |
| Phase 5 | US3 - Active Call   | T046-T049 (4 tasks)  |
| Phase 6 | US4 - Call History  | T050-T054 (5 tasks)  |
| Phase 7 | Polish              | T055-T058 (4 tasks)  |
| **Total** |                   | **58 tasks**         |

---

## Notes

- [P] tasks = different files, no dependencies — can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable after its phase completes
- Commit after each task or logical group
- Stop at any checkpoint to validate independently
- **Do NOT rebuild existing features** — only modify at specified integration points
- All Cubits are separated by concern — never mix state between them
- Duration always calculated from `acceptedAt`, not `startedAt`
