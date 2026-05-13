# Tasks: Single Chat Messaging

**Input**: Design documents from `/specs/003-single-chat-messaging/`
**Prerequisites**: plan.md âœ… spec.md âœ… research.md âœ… data-model.md âœ… quickstart.md âœ…

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies)
- **[Story]**: Maps to user story from spec.md (US1â€“US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Register dependencies, extend storage service, add route.

- [x] T001 Add `record` package to `pubspec.yaml` and run `flutter pub get` (if not already present)
- [x] T002 [P] Add `uploadChatImage({required String chatId, required File file})` method to `lib/core/service/supabase/supabase_storage_service.dart` â€” path: `chats/{chatId}/messages/images/{timestamp}.{ext}`
- [x] T003 [P] Add `uploadChatAudio({required String chatId, required File file})` method to `lib/core/service/supabase/supabase_storage_service.dart` â€” path: `chats/{chatId}/messages/audio/{timestamp}.m4a`
- [x] T004 [P] Add `uploadChatFile({required String chatId, required File file, required String originalFileName})` method to `lib/core/service/supabase/supabase_storage_service.dart` â€” path: `chats/{chatId}/messages/files/{timestamp}_{safeName}`

**Checkpoint**: `SupabaseStorageService` has all three chat media upload methods.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Data model and domain contract that ALL user stories share.

**âڑ ï¸ڈ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T005 Create `lib/features/single_chat/data/models/message_model.dart` â€” `MessageType` enum (`text`, `image`, `audio`, `file`) and `MessageModel` class with all fields (`id`, `chatId`, `senderId`, `type`, `content`, `fileName`, `fileSize`, `duration`, `sentAt`), `fromFirestore(id, data)` factory and `toJson()` using Firestore `Timestamp`
- [x] T006 Create `lib/features/single_chat/domain/repositories/messages_repo.dart` â€” abstract class with: `getMessages(chatId)` â†’ `Stream<ApiResult<List<MessageModel>>>`, `sendTextMessage`, `sendImageMessage`, `sendAudioMessage`, `sendFileMessage` all returning `Future<ApiResult<void>>`
- [x] T007 Create `lib/features/single_chat/data/datasources/messages_remote_data_source.dart` â€” abstract interface + `MessagesRemoteDataSourceImpl` using `DataBaseService`; `getMessages` streams `chats/{chatId}/messages` ordered by `sentAt` desc, limit 20; `sendMessage` writes to same path; `updateChatLastMessage` updates the parent chat doc
- [x] T008 Create `lib/features/single_chat/data/repositories/messages_repo_impl.dart` â€” `MessagesRepoImpl` wraps data source + `SupabaseStorageService`; catches all exceptions and maps to `Failure`; implements all 5 repo methods
- [x] T009 Create cubit state files (sealed classes, no Freezed):
  - `lib/features/single_chat/presentation/bloc/messages_cubit/messages_state.dart` â€” `sealed class MessagesState` with `MessagesInitial`, `MessagesLoading`, `MessagesLoaded(List<MessageModel>)`, `MessagesError(String)`
  - `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_state.dart` â€” `sealed class SendMessageState` with `SendMessageInitial`, `SendMessageLoading`, `SendMessageSuccess`, `SendMessageError(String)`

**Checkpoint**: Model, data source, repository, and state files compile. Foundation ready.

---

## Phase 3: User Story 1 â€” Send and Receive Text Messages (Priority: P1) ًںژ¯ MVP

**Goal**: Users can send and receive text messages in real time in a one-on-one chat.

**Independent Test**: Open a chat between two accounts, send text from Account A, confirm it appears instantly on Account B without refresh. Verify `chats/{chatId}/messages` sub-collection in Firestore receives the document.

### Implementation for User Story 1

- [x] T010 [US1] Create `lib/features/single_chat/domain/use_cases/get_messages_use_case.dart` â€” `GetMessagesUseCase(MessagesRepo)` with `call(chatId)` returning `Stream<ApiResult<List<MessageModel>>>`
- [x] T011 [US1] Create `lib/features/single_chat/domain/use_cases/send_text_message_use_case.dart` â€” `SendTextMessageUseCase(MessagesRepo)` with `call(chatId, senderId, text)` returning `Future<ApiResult<void>>`; validates text is not blank
- [x] T012 [US1] Create `lib/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart` â€” `MessagesCubit(GetMessagesUseCase)` extends `Cubit<MessagesState>`; `loadMessages(chatId)` subscribes to use case stream, maps `ApiResult` to states; cancels `StreamSubscription` in `close()`
- [x] T013 [US1] Create `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart` â€” `SendMessageCubit(SendTextMessageUseCase, ...)` with `sendText(chatId, senderId, text)` emitting Loading â†’ Success/Error; resets to Initial after success
- [x] T014 [P] [US1] Create `lib/features/single_chat/presentation/widgets/message_bubble.dart` â€” `MessageBubble(MessageModel, bool isMine)` stateless widget; `switch (message.type)` renders text body for `MessageType.text`; aligns right for sender, left for receiver; shows timestamp; uses `TextApp` from `core/common/widgets/text_app.dart`
- [x] T015 [P] [US1] Create `lib/features/single_chat/presentation/widgets/messages_list_view.dart` â€” `BlocBuilder<MessagesCubit, MessagesState>`; loading â†’ `LoadingShimmer` from `core/common/loading/loading_shimmer.dart`; empty â†’ `EmptyScreen` from `core/common/loading/empty_screen.dart`; loaded â†’ reversed `ListView.builder` of `MessageBubble`
- [x] T016 [US1] Create `lib/features/single_chat/presentation/widgets/message_input_bar.dart` â€” `StatefulWidget` with `TextEditingController` + `FocusNode` (created in `initState`, disposed in `dispose`); text field + send `IconButton` (active only when text non-empty); uses `BlocConsumer<SendMessageCubit>` to show `ShowToast` on error; calls `sendText` on tap
- [x] T017 [US1] Create `lib/features/single_chat/presentation/screens/single_chat_screen.dart` â€” `StatefulWidget` receiving `chatId` (String) and `chatModel` (ChatModel) as constructor args; `MultiBlocProvider` providing `MessagesCubit` + `SendMessageCubit` from `sl()`; calls `MessagesCubit.loadMessages` in `initState`; scaffold with AppBar (other user name), body = `Column([MessagesListView, MessageInputBar])`
- [x] T018 [US1] Register all US1 dependencies in `lib/core/di/injection_container.dart`:
  - `MessagesRemoteDataSourceImpl` (lazySingleton)
  - `MessagesRepoImpl` (lazySingleton)
  - `GetMessagesUseCase` (lazySingleton)
  - `SendTextMessageUseCase` (lazySingleton)
  - `MessagesCubit` (factory)
  - `SendMessageCubit` (factory â€” register once, update when more use cases are added in later phases)
- [x] T019 [US1] Register `SingleChatScreen` route in `lib/core/routes/app_routes.dart` with named route and args; update home chat list item `onTap` to navigate to `SingleChatScreen` passing `chatId` and `chatModel`

**Checkpoint**: Text send/receive works end-to-end. Messages appear in real time. Firestore sub-collection `chats/{chatId}/messages` receives documents.

---

## Phase 4: User Story 2 â€” Send and Receive Images (Priority: P2)

**Goal**: Users can pick an image from the gallery and send it; recipient sees a thumbnail inline.

**Independent Test**: Send an image from Account A; confirm Account B sees a thumbnail; tap thumbnail to open full-screen viewer.

### Implementation for User Story 2

- [x] T020 [US2] Create `lib/features/single_chat/domain/use_cases/send_image_message_use_case.dart` â€” `SendImageMessageUseCase(MessagesRepo)` with `call(chatId, senderId, file)` returning `Future<ApiResult<void>>`; validates file size â‰¤ 25 MB before delegating to repo
- [x] T021 [P] [US2] Create `lib/features/single_chat/presentation/widgets/image_message_widget.dart` â€” `StatelessWidget` showing `Image.network` thumbnail with a loading indicator; `GestureDetector` opens full-screen `Dialog` or `Navigator.push` with the full-res image; handles load errors with a placeholder icon
- [x] T022 [US2] Update `lib/features/single_chat/presentation/widgets/message_bubble.dart` â€” add `image` case in `switch (message.type)` to render `ImageMessageWidget(url: message.content)`
- [x] T023 [US2] Update `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart` â€” add `sendImage(chatId, senderId)` method: calls `image_picker` to pick file, checks 25 MB limit (show `ShowToast` error if exceeded), emits Loading â†’ calls `SendImageMessageUseCase` â†’ Success/Error
- [x] T024 [US2] Create `lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart` â€” `StatelessWidget` shown via `CustomBottomSheet.showModalBottomSheetContainer`; three `ListTile` options: Image, Audio, File; Image option calls `SendMessageCubit.sendImage` and pops; uses icons from `iconsax`
- [x] T025 [US2] Update `lib/features/single_chat/presentation/widgets/message_input_bar.dart` â€” add attachment `IconButton` (e.g., `Iconsax.attach_circle`) that opens `AttachmentBottomSheet`
- [x] T026 [US2] Register `SendImageMessageUseCase` in `lib/core/di/injection_container.dart`; update `SendMessageCubit` factory to include it

**Checkpoint**: Image messages send and display as thumbnails. Full-screen viewer works. Supabase Storage path `chats/{chatId}/messages/images/` receives files.

---

## Phase 5: User Story 3 â€” Send and Receive Audio Messages (Priority: P3)

**Goal**: Users can record a voice message inline and send it; recipient sees a playable audio player.

**Independent Test**: Hold record button in Account A, release to send; confirm Account B sees an audio message widget with correct duration; tap Play and audio plays.

### Implementation for User Story 3

- [x] T027 [US3] Create `lib/features/single_chat/domain/use_cases/send_audio_message_use_case.dart` â€” `SendAudioMessageUseCase(MessagesRepo)` with `call(chatId, senderId, file, duration)` returning `Future<ApiResult<void>>`
- [x] T028 [P] [US3] Create `lib/features/single_chat/presentation/widgets/audio_recorder_widget.dart` â€” `StatefulWidget`; uses `record` package; hold-to-record `GestureDetector` (`onLongPressStart` â†’ `recorder.start`, `onLongPressEnd` â†’ `recorder.stop` â†’ returns file path + duration); shows live duration counter while recording; slide-left cancels; on release calls `SendMessageCubit.sendAudio`
- [x] T029 [P] [US3] Create `lib/features/single_chat/presentation/widgets/audio_message_widget.dart` â€” `StatefulWidget`; uses `audioplayers` or equivalent; play/pause `IconButton`; `LinearProgressIndicator` or slider showing playback position; displays formatted duration (e.g., `0:32`); streams from Supabase URL
- [x] T030 [US3] Update `lib/features/single_chat/presentation/widgets/message_bubble.dart` â€” add `audio` case to render `AudioMessageWidget(url: message.content, duration: message.duration)`
- [x] T031 [US3] Update `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart` â€” add `sendAudio(chatId, senderId, filePath, duration)`: emits Loading â†’ `SendAudioMessageUseCase` â†’ Success/Error
- [x] T032 [US3] Update `lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart` â€” Audio option shows `AudioRecorderWidget` inline (replace bottom sheet body or push a new widget); dismisses sheet on send
- [x] T033 [US3] Register `SendAudioMessageUseCase` in `lib/core/di/injection_container.dart`; update `SendMessageCubit` factory

**Checkpoint**: Voice messages record, upload, and play back correctly. Supabase Storage path `chats/{chatId}/messages/audio/` receives `.m4a` files.

---

## Phase 6: User Story 4 â€” Send and Receive Files (Priority: P4)

**Goal**: Users can pick any file and send it; recipient sees a file attachment card and can download it.

**Independent Test**: Pick a PDF from Account A; confirm Account B sees file name, type icon, and size; tap Download and file saves to device.

### Implementation for User Story 4

- [x] T034 [US4] Create `lib/features/single_chat/domain/use_cases/send_file_message_use_case.dart` â€” `SendFileMessageUseCase(MessagesRepo)` with `call(chatId, senderId, file, fileName)` returning `Future<ApiResult<void>>`; validates file size â‰¤ 25 MB
- [x] T035 [P] [US4] Create `lib/features/single_chat/presentation/widgets/file_message_widget.dart` â€” `StatelessWidget`; shows file type icon (`Iconsax.document`), file name (`message.fileName`), formatted size; download `IconButton` using `url_launcher` or `dio` to save file to device; shows `ShowToast` on download error
- [x] T036 [US4] Update `lib/features/single_chat/presentation/widgets/message_bubble.dart` â€” add `file` case to render `FileMessageWidget`
- [x] T037 [US4] Update `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart` â€” add `sendFile(chatId, senderId)`: calls `file_picker` to pick file, checks 25 MB limit, emits Loading â†’ `SendFileMessageUseCase` â†’ Success/Error; shows `ShowToast` for oversized file
- [x] T038 [US4] Update `lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart` â€” File option calls `SendMessageCubit.sendFile` and pops sheet
- [x] T039 [US4] Register `SendFileMessageUseCase` in `lib/core/di/injection_container.dart`; update `SendMessageCubit` factory

**Checkpoint**: File attachments send and display. Download works. 25 MB limit enforced with toast error. Supabase Storage path `chats/{chatId}/messages/files/` receives files.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Error handling, edge cases, and UX polish across all stories.

- [x] T040 [P] Add loading upload progress indicator to `MessageInputBar` â€” while `SendMessageCubit` is in `Loading` state, disable send/attachment buttons and show a `CircularProgressIndicator` in the input bar area
- [x] T041 [P] Handle Firestore stream errors in `MessagesCubit` â€” ensure `MessagesError` state shows a retry button in `MessagesListView` that calls `loadMessages` again
- [x] T042 [P] Add `lastMessage` and `lastMessageTime` update to `MessagesRemoteDataSourceImpl.sendMessage` â€” after writing to `messages` sub-collection, call `updateChatLastMessage` to keep the parent chat doc in sync (used by the home screen chat list)
- [x] T043 [P] Add mic permission request before starting audio recording in `AudioRecorderWidget` â€” use `permission_handler` or the `record` package built-in permission API; show `CustomDialogs` dialog if denied explaining why permission is needed
- [x] T044 [P] Validate text input in `MessageInputBar` â€” trim whitespace before calling `sendText`; keep Send button disabled if trimmed text is empty
- [x] T045 Run through quickstart.md validation: open chat, send one of each message type, confirm all appear in correct order on the receiving device

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies â€” T002, T003, T004 can run in parallel immediately
- **Foundational (Phase 2)**: Depends on Phase 1 â€” BLOCKS all user story phases
- **Phase 3 (US1)**: Depends on Phase 2 â€” MVP; must complete before Phases 4â€“6
- **Phase 4 (US2)**: Depends on Phase 2 + T013 (SendMessageCubit exists)
- **Phase 5 (US3)**: Depends on Phase 2 + T013 + T024/T025 (AttachmentBottomSheet exists from US2)
- **Phase 6 (US4)**: Depends on Phase 2 + T013 + T024/T025
- **Phase 7 (Polish)**: Depends on all desired stories being complete

### Within Each User Story

- Use case â†’ Cubit update â†’ Widget update â†’ DI registration
- Widgets marked [P] can be built in parallel with the use case/cubit work

### Parallel Opportunities

- T002, T003, T004 (Phase 1) â€” all touch different methods in the same file but are additive; can be done sequentially in one pass
- T005, T006 (Phase 2) â€” different files, fully parallel
- T014, T015 (US1 widgets) â€” different files, fully parallel
- T020 (US2 use case) + T021 (US2 widget) â€” different files, fully parallel
- T027 (US3 use case) + T028 (US3 recorder) + T029 (US3 player) â€” different files, fully parallel
- T034 (US4 use case) + T035 (US4 widget) â€” different files, fully parallel
- T040â€“T044 (Polish) â€” all different files, fully parallel

---

## Parallel Example: User Story 1

```
Parallel group A (after Phase 2):
  Task T010: get_messages_use_case.dart
  Task T011: send_text_message_use_case.dart
  Task T014: message_bubble.dart
  Task T015: messages_list_view.dart

Sequential after group A:
  Task T012: messages_cubit.dart          (depends on T010)
  Task T013: send_message_cubit.dart      (depends on T011)
  Task T016: message_input_bar.dart       (depends on T013)
  Task T017: single_chat_screen.dart      (depends on T012, T013, T015, T016)
  Task T018: injection_container.dart     (depends on all above)
  Task T019: app_routes.dart              (depends on T017)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001â€“T004)
2. Complete Phase 2: Foundational (T005â€“T009) â€” **CRITICAL**
3. Complete Phase 3: User Story 1 (T010â€“T019)
4. **STOP and VALIDATE**: Text send/receive works in real time on device
5. Ship/demo MVP

### Incremental Delivery

1. Setup + Foundational â†’ compile passes
2. US1 (text) â†’ real-time messaging works âœ… MVP
3. US2 (images) â†’ image sharing works âœ…
4. US3 (audio) â†’ voice messages work âœ…
5. US4 (files) â†’ file sharing works âœ…
6. Polish â†’ production-ready âœ…

---

## Notes

- No Freezed anywhere â€” all states use Dart 3 `sealed class`
- No Flutter imports in `domain/` layer
- `setState` only in `AudioRecorderWidget` for local recording-in-progress flag
- Commit after each checkpoint
- `SendMessageCubit` grows across phases; update its factory registration in DI after each phase adds a new use case
- `MessageBubble` is updated per phase to handle new `MessageType` cases

