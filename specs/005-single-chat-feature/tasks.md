# Tasks: Single Chat Feature

**Input**: Design documents from `specs/005-single-chat-feature/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Models, constants, code generation, localization, and DI â€” shared by all user stories

- [x] T001 Verify Firestore constants exist in lib/constants/fierstore_paths.dart
  - Goal: Ensure `chatsCollection`, `messagesCollection`, `usersCollection` constants exist
  - Files: `lib/constants/fierstore_paths.dart`
  - Details: Constants already exist (`chatsCollection = 'chats'`, `messagesCollection = 'messages'`, `usersCollection = 'users'`). Verify they are present. No changes expected.
  - Acceptance criteria: All three constants exist and are importable

- [x] T002 Update ChatModel to add lastMessageType and updatedAt in lib/features/single_chat/data/models/chat_model.dart
  - Goal: Extend `ChatModel` with `lastMessageType` (String?) and `updatedAt` (DateTime? with Timestamp converter)
  - Files: `lib/features/single_chat/data/models/chat_model.dart`
  - Details: Add `lastMessageType` as `String?` field. Add `updatedAt` as `DateTime?` with the same `@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)` pattern used for `lastMessageTime` and `createdAt`. Update constructor.
  - Acceptance criteria: `ChatModel` has `lastMessageType` and `updatedAt` fields, `fromJson`/`toJson`/`fromFirestore` work correctly

- [x] T003 Rewrite MessageModel to match spec in lib/features/single_chat/data/models/message_model.dart
  - Goal: Replace current `MessageModel` with spec-aligned `@JsonSerializable()` version
  - Files: `lib/features/single_chat/data/models/message_model.dart`
  - Details: New fields: `id`, `chatId`, `senderId`, `senderEmail`, `receiverId`, `text`, `type` (String: "text"/"image"/"file"), `mediaUrl`, `storagePath`, `fileName`, `createdAt` (DateTime with Timestamp converter), `updatedAt` (DateTime with Timestamp converter), `isEdited` (bool, default false). Use `@JsonSerializable()` and `part 'message_model.g.dart'`. Add `fromFirestore` factory (same pattern as `ChatModel`). Keep Timestamp converters.
  - Acceptance criteria: `MessageModel` compiles, has all spec fields, `fromJson`/`toJson`/`fromFirestore` work

- [x] T004 Run build_runner for json_serializable
  - Goal: Generate `.g.dart` files for updated models
  - Files: `lib/features/single_chat/data/models/chat_model.g.dart`, `lib/features/single_chat/data/models/message_model.g.dart`
  - Details: Run `flutter pub run build_runner build --delete-conflicting-outputs`. Verify both `.g.dart` files are generated without errors.
  - Acceptance criteria: `chat_model.g.dart` and `message_model.g.dart` exist and project compiles

- [x] T005 [P] Verify SupabaseStorageService has uploadChatImage, uploadChatFile, removeFile in lib/core/service/supabase/supabase_storage_service.dart
  - Goal: Confirm existing methods work for single chat media messages
  - Files: `lib/core/service/supabase/supabase_storage_service.dart`
  - Details: Methods already exist: `uploadChatImage(chatId, file)` â†’ `chats/{chatId}/messages/images/{timestamp}.ext`, `uploadChatFile(chatId, file, originalFileName)` â†’ `chats/{chatId}/messages/files/{timestamp}_{name}`, `removeFile(storagePath)`. No changes needed.
  - Acceptance criteria: All three methods exist, accept correct parameters, return `UploadedFileData`

- [x] T006 [P] Add new LangKeys in lib/core/language/lang_keys.dart
  - Goal: Add localization keys for single chat message features
  - Files: `lib/core/language/lang_keys.dart`
  - Details: Add these static const String fields: `messageDeletedSuccessfully = 'message_deleted_successfully'`, `messageUpdatedSuccessfully = 'message_updated_successfully'`, `deleteMessage = 'delete_message'`, `editMessage = 'edit_message'`, `updateMessage = 'update_message'`, `onlyTextMessagesCanBeEdited = 'only_text_messages_can_be_edited'`, `chatAlreadyExists = 'chat_already_exists'`, `cannotCreateChatWithYourself = 'cannot_create_chat_with_yourself'`, `noUserFoundWithThisEmail = 'no_user_found_with_this_email'`, `edited = 'edited'`, `image = 'image'`, `file = 'file'`, `attachFile = 'attach_file'`, `attachImage = 'attach_image'`. Some keys like `createChat`, `enterFriendEmail`, `noChatsYet`, `sendMessage`, `enterMessage`, `cancel`, `remove` already exist â€” do NOT duplicate.
  - Acceptance criteria: All new keys added, no duplicates, file compiles

- [x] T007 [P] Add en.json translations in lang/en.json
  - Goal: Add English translations for new LangKeys
  - Files: `lang/en.json`
  - Details: Add entries matching the new LangKeys: `"message_deleted_successfully": "Message deleted successfully"`, `"message_updated_successfully": "Message updated successfully"`, `"delete_message": "Delete Message"`, `"edit_message": "Edit Message"`, `"update_message": "Update"`, `"only_text_messages_can_be_edited": "Only text messages can be edited"`, `"chat_already_exists": "Chat already exists"`, `"cannot_create_chat_with_yourself": "Cannot create chat with yourself"`, `"no_user_found_with_this_email": "No user found with this email"`, `"edited": "edited"`, `"image": "Image"`, `"file": "File"`, `"attach_file": "Attach File"`, `"attach_image": "Attach Image"`. Do NOT duplicate existing keys.
  - Acceptance criteria: All new keys have English values in valid JSON

- [x] T008 [P] Add ar.json translations in lang/ar.json
  - Goal: Add Arabic translations for new LangKeys
  - Files: `lang/ar.json`
  - Details: Add entries: `"message_deleted_successfully": "طھظ… ط­ط°ظپ ط§ظ„ط±ط³ط§ظ„ط© ط¨ظ†ط¬ط§ط­"`, `"message_updated_successfully": "طھظ… طھط¹ط¯ظٹظ„ ط§ظ„ط±ط³ط§ظ„ط© ط¨ظ†ط¬ط§ط­"`, `"delete_message": "ط­ط°ظپ ط§ظ„ط±ط³ط§ظ„ط©"`, `"edit_message": "طھط¹ط¯ظٹظ„ ط§ظ„ط±ط³ط§ظ„ط©"`, `"update_message": "طھط­ط¯ظٹط«"`, `"only_text_messages_can_be_edited": "ظٹظ…ظƒظ† طھط¹ط¯ظٹظ„ ط§ظ„ط±ط³ط§ط¦ظ„ ط§ظ„ظ†طµظٹط© ظپظ‚ط·"`, `"chat_already_exists": "ط§ظ„ظ…ط­ط§ط¯ط«ط© ظ…ظˆط¬ظˆط¯ط© ط¨ط§ظ„ظپط¹ظ„"`, `"cannot_create_chat_with_yourself": "ظ„ط§ ظٹظ…ظƒظ†ظƒ ط¥ظ†ط´ط§ط، ظ…ط­ط§ط¯ط«ط© ظ…ط¹ ظ†ظپط³ظƒ"`, `"no_user_found_with_this_email": "ظ„ط§ ظٹظˆط¬ط¯ ظ…ط³طھط®ط¯ظ… ط¨ظ‡ط°ط§ ط§ظ„ط¨ط±ظٹط¯ ط§ظ„ط¥ظ„ظƒطھط±ظˆظ†ظٹ"`, `"edited": "طھظ… ط§ظ„طھط¹ط¯ظٹظ„"`, `"image": "طµظˆط±ط©"`, `"file": "ظ…ظ„ظپ"`, `"attach_file": "ط¥ط±ظپط§ظ‚ ظ…ظ„ظپ"`, `"attach_image": "ط¥ط±ظپط§ظ‚ طµظˆط±ط©"`.
  - Acceptance criteria: All new keys have Arabic values in valid JSON

**Checkpoint**: Models, constants, localization ready. Code generation complete.

---

## Phase 2: Foundational (Data Layer & Business Logic)

**Purpose**: Data sources, repositories, cubits, DI â€” blocks all UI work

### Data Sources

- [x] T009 Verify ChatsRemoteDataSource getChats in lib/features/single_chat/data/datasources/chats_remote_data_source.dart
  - Goal: Confirm `getChats` streams chats where `users` arrayContains `currentUserId`
  - Files: `lib/features/single_chat/data/datasources/chats_remote_data_source.dart`
  - Details: Already implemented. Uses `_dataBaseService.collectionStream` with `queryBuilder: (query) => query.where('users', arrayContains: currentUserId)`. No changes needed.
  - Acceptance criteria: Method exists and returns `Stream<List<ChatModel>>`

- [x] T010 Verify ChatsRemoteDataSource createChat in lib/features/single_chat/data/datasources/chats_remote_data_source.dart
  - Goal: Confirm `createChat` validates email, prevents self-chat, prevents duplicates, uses stable ID
  - Files: `lib/features/single_chat/data/datasources/chats_remote_data_source.dart`
  - Details: Already implemented with all validations. Uses stable chat ID (`[uid1, uid2].sort().join('_')`). Looks up friend by email in `usersCollection`. Checks existing chats for duplicates. No changes needed.
  - Acceptance criteria: Method handles all validation cases and creates chat with stable ID

- [x] T011 Update MessagesRemoteDataSource with sendTextMessage in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Update `sendMessage` to use new `MessageModel` fields and call `updateChatLastMessage`
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Rename/refactor existing `sendMessage` to `sendTextMessage`. Parameters: `chatId`, `senderId`, `senderEmail`, `receiverId`, `text`. Create `MessageModel` with `type: "text"`, empty `mediaUrl`/`storagePath`/`fileName`, `isEdited: false`. Generate message ID using `FirebaseFirestore.instance.collection(...).doc().id`. Save via `_dataBaseService.setData`. Then call `updateChatLastMessage` with `lastMessageType: "text"`.
  - Acceptance criteria: Text message saved to `chats/{chatId}/messages/{messageId}`, chat document's `lastMessage`, `lastMessageType`, `lastMessageTime` updated

- [x] T012 Add sendImageMessage to MessagesRemoteDataSource in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Upload image to Supabase, save image message to Firestore, update lastMessage
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Accept `chatId`, `senderId`, `senderEmail`, `receiverId`, `File imageFile`. Inject `SupabaseStorageService` in constructor. Call `_storageService.uploadChatImage(chatId: chatId, file: imageFile)` to get `UploadedFileData`. Create `MessageModel` with `type: "image"`, `mediaUrl: result.url`, `storagePath: result.storagePath`, `fileName: result.fileName`, empty `text`. Save message. Call `updateChatLastMessage` with `lastMessage: "Image"`, `lastMessageType: "image"`.
  - Acceptance criteria: Image uploaded to Supabase at `chats/{chatId}/messages/images/...`, message saved with correct URLs, chat lastMessage updated

- [x] T013 Add sendFileMessage to MessagesRemoteDataSource in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Upload file to Supabase, save file message to Firestore, update lastMessage
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Accept `chatId`, `senderId`, `senderEmail`, `receiverId`, `File file`, `String originalFileName`. Call `_storageService.uploadChatFile(chatId: chatId, file: file, originalFileName: originalFileName)`. Create `MessageModel` with `type: "file"`, `mediaUrl: result.url`, `storagePath: result.storagePath`, `fileName: originalFileName`, empty `text`. Save and update lastMessage with `lastMessage: originalFileName`, `lastMessageType: "file"`.
  - Acceptance criteria: File uploaded to Supabase at `chats/{chatId}/messages/files/...`, message saved, chat lastMessage updated

- [x] T014 Add updateMessage to MessagesRemoteDataSource in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Update text of an existing message and set isEdited to true
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Accept `chatId`, `messageId`, `String newText`. Use `_dataBaseService.setData(path: '$chatsCollection/$chatId/$messagesCollection/$messageId', data: {'text': newText, 'isEdited': true, 'updatedAt': Timestamp.now()}, merge: true)`.
  - Acceptance criteria: Message text updated, `isEdited` set to true, `updatedAt` set to current time

- [x] T015 Add deleteMessage to MessagesRemoteDataSource in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Hard delete message from Firestore and remove storage file if applicable
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Accept `chatId`, `messageId`, `String storagePath`. Delete message doc via `_dataBaseService.deleteData(path: '$chatsCollection/$chatId/$messagesCollection/$messageId')`. If `storagePath` is non-empty, call `_storageService.removeFile(storagePath: storagePath)`.
  - Acceptance criteria: Message document deleted from Firestore, Supabase file removed if `storagePath` was non-empty

- [x] T016 Update updateChatLastMessage to include lastMessageType in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Add `lastMessageType` parameter to `updateChatLastMessage`
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Add `required String lastMessageType` parameter. Include `'lastMessageType': lastMessageType` in the data map. Also add `'updatedAt': Timestamp.fromDate(time)`.
  - Acceptance criteria: Chat document updated with `lastMessage`, `lastMessageType`, `lastMessageTime`, and `updatedAt`

- [x] T017 Verify getMessages in MessagesRemoteDataSource in lib/features/single_chat/data/datasources/messages_remote_data_source.dart
  - Goal: Confirm messages stream works with updated MessageModel
  - Files: `lib/features/single_chat/data/datasources/messages_remote_data_source.dart`
  - Details: Existing `getMessages` uses `collectionStream` with `orderBy('sentAt', ...)`. Update to `orderBy('createdAt', descending: true)` to match new field name. Update builder to use new `MessageModel.fromFirestore`.
  - Acceptance criteria: Returns `Stream<List<MessageModel>>` ordered by `createdAt` descending

### Repository

- [x] T018 Update MessagesRepo abstract and impl in lib/features/single_chat/domain/repositories/messages_repo.dart and lib/features/single_chat/data/repositories/messages_repo_impl.dart
  - Goal: Add all new methods to repo layer (pure delegation)
  - Files: `lib/features/single_chat/domain/repositories/messages_repo.dart`, `lib/features/single_chat/data/repositories/messages_repo_impl.dart`
  - Details: Add abstract methods: `sendTextMessage(...)`, `sendImageMessage(...)`, `sendFileMessage(...)`, `updateMessage(...)`, `deleteMessage(...)`, `updateChatLastMessage(...)`. Impl delegates to `MessagesRemoteDataSource`. Keep existing `getMessages` and `sendMessage` (rename to match new signature).
  - Acceptance criteria: All methods defined in abstract class and implemented with pure delegation

- [x] T019 Verify ChatsRepo in lib/features/single_chat/data/repositories/chats_repo.dart
  - Goal: Confirm ChatsRepo has `getChats`, `createChat`, `searchChats`
  - Files: `lib/features/single_chat/data/repositories/chats_repo.dart`
  - Details: Already fully implemented. No changes needed.
  - Acceptance criteria: All three methods exist and delegate to data source

### Cubits

- [x] T020 Fix ChatsCubit search bug and add isClosed guard in lib/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart
  - Goal: Fix double-emit bug in `searchChats` and add `isClosed` guard to stream listener
  - Files: `lib/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart`
  - Details: Bug at lines 91-92: removes `emit(ChatsState.loaded(chats: _allChats))` after `emit(const ChatsState.searchEmpty())` â€” the second emit overrides the empty state. Also add `if (isClosed) return;` guard in the stream `.listen` callback (both `onData` and `onError`). Also add `refreshChats` method that cancels subscription, sets `_isListeningToChats = false`, and calls `getChats` again. Remove `print` statements.
  - Acceptance criteria: Search empty state shows correctly, no "Cannot emit after close" errors, pull-to-refresh works via `refreshChats`

- [x] T021 Verify CreateChatCubit in lib/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart
  - Goal: Confirm CreateChatCubit works independently from ChatsCubit
  - Files: `lib/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart`
  - Details: Already implemented. Uses `ChatsRepo.createChat()`. Has states: `initial`, `createChatLoading`, `createChatSuccess`, `createChatError`. No changes needed.
  - Acceptance criteria: CreateChatCubit emits correct states, is completely separate from ChatsCubit

- [x] T022 Update MessagesCubit to use MessagesRepo directly in lib/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart
  - Goal: Remove `GetMessagesUseCase` dependency, use `MessagesRepo` directly, add `isClosed` guard
  - Files: `lib/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart`
  - Details: Change constructor to accept `MessagesRepo` instead of `GetMessagesUseCase`. In `loadMessages`, call `_messagesRepo.getMessages(chatId: chatId)` directly. Add `if (isClosed) return;` guard in stream listener callbacks.
  - Acceptance criteria: MessagesCubit works with repo directly, no use case dependency, no "Cannot emit after close" errors

- [x] T023 Update SendMessageCubit with edit/delete/image/file in lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart
  - Goal: Extend SendMessageCubit to handle all message operations
  - Files: `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart`, `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_state.dart`
  - Details: Update states (Freezed): `initial`, `sending`, `sent`, `error(message)`, `editing`, `edited`, `deleting`, `deleted`. Add methods: `sendTextMessage({required ChatModel chat, required String text})` â€” gets current user, calls repo. `sendImageMessage({required ChatModel chat, required File imageFile})` â€” calls repo. `sendFileMessage({required ChatModel chat, required File file, required String originalFileName})` â€” calls repo. `updateMessage({required String chatId, required String messageId, required String text})` â€” calls repo. `deleteMessage({required String chatId, required String messageId, required String storagePath})` â€” calls repo. Each method: emit loading state â†’ try operation â†’ emit success state â†’ catch â†’ emit error state.
  - Acceptance criteria: All five methods work, emit correct states, use `MessagesRepo`

- [x] T024 Run build_runner for Freezed cubit states
  - Goal: Generate `.freezed.dart` files for updated cubit states
  - Files: `lib/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.freezed.dart`, `lib/features/single_chat/presentation/bloc/get_chatss/chats_cubit.freezed.dart`
  - Details: Run `flutter pub run build_runner build --delete-conflicting-outputs`.
  - Acceptance criteria: All `.freezed.dart` files generated, project compiles

### Dependency Injection

- [x] T025 Update GetIt registration in lib/core/di/injection_container.dart
  - Goal: Register messages data source, repo, and cubits in `_initChats()`
  - Files: `lib/core/di/injection_container.dart`
  - Details: Add to `_initChats()`: `registerLazySingleton<MessagesRemoteDataSource>(() => MessagesRemoteDataSourceImpl(dataBaseService: sl<DataBaseService>(), storageService: sl<SupabaseStorageService>()))`, `registerLazySingleton<MessagesRepo>(() => MessagesRepoImpl(messagesRemoteDataSource: sl<MessagesRemoteDataSource>()))`, `registerFactory<MessagesCubit>(() => MessagesCubit(messagesRepo: sl<MessagesRepo>()))`, `registerFactory<SendMessageCubit>(() => SendMessageCubit(messagesRepo: sl<MessagesRepo>()))`. Remove any existing use case registrations. Ensure `SupabaseStorageService` is registered before `_initChats` (it already is).
  - Acceptance criteria: All types resolvable via `sl<T>()`, cubits registered as factory (not singleton)

**Checkpoint**: Full data layer and business logic ready. UI can begin.

---

## Phase 3: User Story 1 â€” View All Single Chats (Priority: P1) ًںژ¯ MVP

**Goal**: User sees list of all single chats with friend info, last message, and timestamp

**Independent Test**: Log in, navigate to chats tab, verify chats appear ordered by lastMessageTime

### Implementation

- [x] T026 [US1] Verify ChatHomeScreen in lib/features/single_chat/presentation/screens/chat_home_screen.dart
  - Goal: Confirm ChatHomeScreen shows Stack with ChatHomeBody + FAB
  - Files: `lib/features/single_chat/presentation/screens/chat_home_screen.dart`
  - Details: Already implemented. Uses Stack with `ChatHomeBody` and FAB that opens `CreateChatBottomSheet`. No changes needed.
  - Acceptance criteria: Screen renders, FAB visible

- [x] T027 [US1] Add RefreshIndicator to ChatHomeBody in lib/features/single_chat/presentation/refactor/chat_home_body.dart
  - Goal: Wrap chat list with RefreshIndicator for pull-to-refresh
  - Files: `lib/features/single_chat/presentation/refactor/chat_home_body.dart`
  - Details: Wrap existing list widget with `RefreshIndicator`. On refresh, call `context.read<ChatsCubit>().refreshChats(currentUserId: getCurrentUser().uid)`. Return a Future from the onRefresh callback.
  - Acceptance criteria: Pull-to-refresh triggers `refreshChats`, list reloads

- [x] T028 [US1] Verify ChatsBlocConsumer in lib/features/single_chat/presentation/widgets/chats_scereen_bloc_consumer.dart
  - Goal: Confirm BlocConsumer handles all ChatsCubit states (loading, loaded, empty, error, searchLoaded, searchEmpty)
  - Files: `lib/features/single_chat/presentation/widgets/chats_scereen_bloc_consumer.dart`
  - Details: Verify existing implementation handles all states. Ensure empty state uses `context.translate(LangKeys.noChatsYet)`. Ensure error state shows error message. Ensure `searchEmpty` shows `context.translate(LangKeys.noChatsFound)`.
  - Acceptance criteria: All states display correctly with localized text

- [x] T029 [US1] Verify ChatCard in lib/features/single_chat/presentation/widgets/chat_list_view.dart
  - Goal: Confirm chat card shows friend email, last message, and time
  - Files: `lib/features/single_chat/presentation/widgets/chat_list_view.dart`
  - Details: Verify card displays: friend email (filter out current user's email from `usersEmails`), `lastMessage`, formatted `lastMessageTime`. Use `TextApp` for text. On tap, navigate to `AppRoutes.singleChat` with `ChatModel` as argument.
  - Acceptance criteria: Card shows correct info, tapping navigates to single chat screen

**Checkpoint**: Chats list visible, pull-to-refresh works, navigation to chat works

---

## Phase 4: User Story 2 â€” Create New Chat (Priority: P1)

**Goal**: User creates a new chat by entering friend email with all validations

**Independent Test**: Tap FAB, enter friend email, create chat, verify it appears

### Implementation

- [x] T030 [US2] Verify CreateChatBottomSheet in lib/features/single_chat/presentation/widgets/create_chat_bottom_sheet.dart
  - Goal: Confirm bottom sheet has email field and create button
  - Files: `lib/features/single_chat/presentation/widgets/create_chat_bottom_sheet.dart`
  - Details: Verify it uses `CustomField` for email input, `CustomLinearButton` for create button, `context.translate(LangKeys.enterFriendEmail)` for hint, `context.translate(LangKeys.createChat)` for button. `TextEditingController` must be passed from parent (already done in `ChatHomeScreen`). Verify it wraps content with `CreateChatBlocConsumer`.
  - Acceptance criteria: Bottom sheet renders with email field and create button using app conventions

- [x] T031 [US2] Verify CreateChatBlocConsumer in lib/features/single_chat/presentation/widgets/create_chat_bloc_consumer.dart
  - Goal: Confirm BlocConsumer handles CreateChatCubit states with toasts
  - Files: `lib/features/single_chat/presentation/widgets/create_chat_bloc_consumer.dart`
  - Details: Verify listener: `createChatSuccess` â†’ `ShowToast.showToastSuccessTop(message: context.translate(LangKeys.chatCreatedSuccessfully))` + pop. `createChatError(message)` â†’ `ShowToast.showToastErrorTop(message: message)`. Builder: `createChatLoading` â†’ show loading indicator on button.
  - Acceptance criteria: Success toast + pop on success, error toast on error, loading state on button

**Checkpoint**: Chat creation works with all validations

---

## Phase 5: User Story 3 â€” Send Text Messages (Priority: P1)

**Goal**: User opens chat, sends text, message appears in real time, lastMessage updates

**Independent Test**: Open chat, type text, send, verify it appears and lastMessage updates

### Implementation

- [x] T032 [US3] Update SingleChatScreen to use updated cubits in lib/features/single_chat/presentation/screens/single_chat_screen.dart
  - Goal: Update MultiBlocProvider to use repo-based cubits, add BlocListener for send states
  - Files: `lib/features/single_chat/presentation/screens/single_chat_screen.dart`
  - Details: Update `BlocProvider` for `MessagesCubit` to use new constructor (repo-based). Keep `SendMessageCubit` provider. Add `BlocListener<SendMessageCubit, SendMessageState>` that shows toasts: `sent` â†’ nothing (message appears via stream), `error` â†’ `ShowToast.showToastErrorTop`, `edited` â†’ `ShowToast.showToastSuccessTop(LangKeys.messageUpdatedSuccessfully)`, `deleted` â†’ `ShowToast.showToastSuccessTop(LangKeys.messageDeletedSuccessfully)`.
  - Acceptance criteria: Screen renders with correct cubits, toasts show for operations

- [x] T033 [US3] Verify MessagesListView in lib/features/single_chat/presentation/widgets/messages_list_view.dart
  - Goal: Confirm messages display in reversed ListView with correct alignment
  - Files: `lib/features/single_chat/presentation/widgets/messages_list_view.dart`
  - Details: Verify it uses `BlocBuilder<MessagesCubit, MessagesState>`. `ListView.builder` with `reverse: true`. Current user messages align right, friend messages align left. Uses `MessageBubble` widget. Empty state shows `context.translate(LangKeys.noMessagesYet)`.
  - Acceptance criteria: Messages show with correct alignment, empty state displays

- [x] T034 [US3] Update MessageInputBar for text send in lib/features/single_chat/presentation/widgets/message_input_bar.dart
  - Goal: Ensure text send uses updated `SendMessageCubit.sendTextMessage`
  - Files: `lib/features/single_chat/presentation/widgets/message_input_bar.dart`
  - Details: On send tap: get `ChatModel` from widget, call `context.read<SendMessageCubit>().sendTextMessage(chat: chat, text: controller.text)`. Clear controller after send. Disable send button when text is empty. `TextEditingController` must be in State class, not build(). Dispose in `dispose()`. Use `CustomField` or existing `TextField` for input. Use `context.translate(LangKeys.enterMessage)` for hint.
  - Acceptance criteria: Text message sends, input clears, send button disabled when empty

**Checkpoint**: Text messaging works end-to-end with real-time updates

---

## Phase 6: User Story 4 â€” Send Image Messages (Priority: P2)

**Goal**: User selects image, uploads to Supabase, image message appears in chat

**Independent Test**: Tap attachment, select image, verify it uploads and appears

### Implementation

- [x] T035 [US4] Add attachment button to MessageInputBar in lib/features/single_chat/presentation/widgets/message_input_bar.dart
  - Goal: Add attachment icon that opens AttachmentBottomSheet
  - Files: `lib/features/single_chat/presentation/widgets/message_input_bar.dart`
  - Details: Add `IconButton` with attachment/paperclip icon before the text field. On tap, show `AttachmentBottomSheet`. Pass `ChatModel` to the bottom sheet so it can call `SendMessageCubit` methods.
  - Acceptance criteria: Attachment button visible, tapping opens bottom sheet

- [x] T036 [US4] Update AttachmentBottomSheet for image/file only in lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart
  - Goal: Show options for image and file (remove audio option if present)
  - Files: `lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart`
  - Details: Two options: "Attach Image" (icon: `Icons.image`) and "Attach File" (icon: `Icons.attach_file`). Use `context.translate(LangKeys.attachImage)` and `context.translate(LangKeys.attachFile)`. Image option: pick from gallery using `image_picker`, call `context.read<SendMessageCubit>().sendImageMessage(chat: chat, imageFile: file)`. Use `TextApp` for labels.
  - Acceptance criteria: Bottom sheet shows image and file options, image selection triggers upload

- [x] T037 [P] [US4] Verify ImageMessageWidget in lib/features/single_chat/presentation/widgets/image_message_widget.dart
  - Goal: Confirm image message displays thumbnail with CachedNetworkImage
  - Files: `lib/features/single_chat/presentation/widgets/image_message_widget.dart`
  - Details: Already exists. Verify it uses `CachedNetworkImage` with `mediaUrl`. Shows loading placeholder and error widget.
  - Acceptance criteria: Image messages render with thumbnail preview

**Checkpoint**: Image sending works end-to-end

---

## Phase 7: User Story 5 â€” Send File Messages (Priority: P2)

**Goal**: User selects file, uploads to Supabase, file message appears in chat

**Independent Test**: Tap attachment, select file, verify file message appears with name

### Implementation

- [x] T038 [US5] Add file picking to AttachmentBottomSheet in lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart
  - Goal: File option picks file and sends via SendMessageCubit
  - Files: `lib/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart`
  - Details: File option: use `file_picker` package to select any file. Call `context.read<SendMessageCubit>().sendFileMessage(chat: chat, file: file, originalFileName: fileName)`. Pop bottom sheet after selection.
  - Acceptance criteria: File picker opens, selected file uploads, file message appears

- [x] T039 [P] [US5] Verify FileMessageWidget in lib/features/single_chat/presentation/widgets/file_message_widget.dart
  - Goal: Confirm file message shows file name and download/open action
  - Files: `lib/features/single_chat/presentation/widgets/file_message_widget.dart`
  - Details: Already exists. Verify it shows `fileName`, file type icon, and tap action to open/download.
  - Acceptance criteria: File messages render with name and actionable tap

**Checkpoint**: File sending works end-to-end

---

## Phase 8: User Story 6 â€” Real-Time Messages (Priority: P1)

**Goal**: Messages from other user appear in real time without refresh

**Independent Test**: Open same chat on two accounts, send from one, verify it appears on the other

### Implementation

- [x] T040 [US6] Verify real-time stream works in MessagesCubit
  - Goal: Confirm Firestore snapshot stream delivers new messages automatically
  - Files: `lib/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart`
  - Details: Already implemented via `collectionStream` which uses Firestore `snapshots()`. The stream automatically pushes new documents. No additional work needed beyond T022 (repo migration).
  - Acceptance criteria: New messages from other user appear without manual refresh

**Checkpoint**: Real-time messaging confirmed

---

## Phase 9: User Story 7 â€” Delete Own Messages (Priority: P3)

**Goal**: User long-presses own message, deletes it, storage file removed if applicable

**Independent Test**: Send a message, long-press it, delete, verify it disappears

### Implementation

- [x] T041 [US7] Add long-press selection to MessageBubble in lib/features/single_chat/presentation/widgets/message_bubble.dart
  - Goal: Long-press on own message shows edit/delete actions
  - Files: `lib/features/single_chat/presentation/widgets/message_bubble.dart`
  - Details: Wrap bubble with `GestureDetector` or `InkWell` with `onLongPress`. Only show actions for messages where `senderId == getCurrentUser().uid`. Show a bottom sheet or popup menu with: "Edit" (only for `type == "text"`), "Delete" (for all types). Use `context.translate(LangKeys.editMessage)` and `context.translate(LangKeys.deleteMessage)`. Also show "edited" label below message text when `isEdited == true`, using `TextApp` with smaller font.
  - Acceptance criteria: Long-press on own message shows actions, no actions on friend's messages, "edited" indicator shows

- [x] T042 [US7] Create DeleteMessageDialog in lib/features/single_chat/presentation/widgets/delete_message_dialog.dart
  - Goal: Confirmation dialog before deleting a message
  - Files: `lib/features/single_chat/presentation/widgets/delete_message_dialog.dart`
  - Details: `showDeleteMessageDialog({required BuildContext context, required MessageModel message, required String chatId})`. Shows `AlertDialog` with title `context.translate(LangKeys.deleteMessage)`, content `context.translate(LangKeys.removeMessagesConfirm)`. Cancel button: `context.translate(LangKeys.cancel)`. Delete button: `context.translate(LangKeys.remove)` with red color. On confirm: call `context.read<SendMessageCubit>().deleteMessage(chatId: chatId, messageId: message.id, storagePath: message.storagePath)`, then pop.
  - Acceptance criteria: Dialog shows, cancel dismisses, confirm triggers delete

**Checkpoint**: Message deletion works, storage files cleaned up

---

## Phase 10: User Story 8 â€” Edit Own Text Messages (Priority: P3)

**Goal**: User edits own text message, "edited" indicator appears

**Independent Test**: Send text, edit it, verify updated text and "edited" label

### Implementation

- [x] T043 [US8] Create EditMessageDialog in lib/features/single_chat/presentation/widgets/edit_message_dialog.dart
  - Goal: Dialog with pre-filled text field to edit message
  - Files: `lib/features/single_chat/presentation/widgets/edit_message_dialog.dart`
  - Details: `showEditMessageDialog({required BuildContext context, required MessageModel message, required String chatId})`. Uses `AlertDialog` with `CustomField` pre-filled with `message.text`. Controller in StatefulWidget, dispose properly. Title: `context.translate(LangKeys.editMessage)`. Confirm button: `CustomLinearButton` with text `context.translate(LangKeys.updateMessage)`. On confirm: call `context.read<SendMessageCubit>().updateMessage(chatId: chatId, messageId: message.id, text: controller.text)`, then pop. Disable confirm if text unchanged or empty.
  - Acceptance criteria: Dialog shows with current text, edit updates message, "edited" label appears on bubble

**Checkpoint**: Message editing works

---

## Phase 11: User Story 9 â€” Search Chats (Priority: P2)

**Goal**: User searches chats by friend email, clears search to restore full list

**Independent Test**: Search by email, verify filtered results, clear search, verify full list

### Implementation

- [x] T044 [US9] Verify SearchDialog in lib/features/single_chat/presentation/widgets/search_for_chat/seaarch_dialog.dart
  - Goal: Confirm search dialog calls `ChatsCubit.searchChats` and `clearSearch`
  - Files: `lib/features/single_chat/presentation/widgets/search_for_chat/seaarch_dialog.dart`
  - Details: Verify dialog has search field using `CustomField`, calls `context.read<ChatsCubit>().searchChats(currentUserId: getCurrentUser().uid, searchText: text)` on submit. Clear button calls `context.read<ChatsCubit>().clearSearch()`. Uses `context.translate(LangKeys.searchChats)` for hint. `TextEditingController` in State, disposed properly.
  - Acceptance criteria: Search filters chats, clear restores full list, same ChatsCubit instance used

**Checkpoint**: Search works

---

## Phase 12: User Story 10 â€” Pull to Refresh (Priority: P3)

**Goal**: Pull down on chats list to refresh

**Independent Test**: Pull down, verify list reloads

### Implementation

- [x] T045 [US10] Verify RefreshIndicator works (implemented in T027)
  - Goal: Confirm pull-to-refresh re-subscribes to chats stream
  - Files: `lib/features/single_chat/presentation/refactor/chat_home_body.dart`
  - Details: Already handled in T027. Verify `RefreshIndicator.onRefresh` calls `refreshChats` and returns a Future that completes when re-subscription emits first data.
  - Acceptance criteria: Pull down triggers refresh, new data loads

**Checkpoint**: Pull to refresh works

---

## Phase 13: Routes & Navigation

**Purpose**: Ensure routes are correctly configured

- [x] T046 Verify route for singleChat in lib/core/routes/app_routes.dart
  - Goal: Confirm `AppRoutes.singleChat` route passes ChatModel and settings
  - Files: `lib/core/routes/app_routes.dart`
  - Details: Route `singleChat` already exists at line 141-144: `return BaseRoute(page: SingleChatScreen(chat: args as ChatModel))`. Verify it passes `settings: settings` to `BaseRoute` (same fix pattern as statusViewer). If not, add it.
  - Acceptance criteria: Navigation to single chat works with ChatModel argument

- [x] T047 Verify MainScreen connects ChatHomeScreen to singleChats tab in lib/features/main/presentation/screens/main_screen.dart
  - Goal: Confirm singleChats tab shows ChatHomeScreen with correct BlocProviders
  - Files: `lib/features/main/presentation/screens/main_screen.dart`
  - Details: Already implemented. `NavBarEnum.singleChats` â†’ `ChatHomeScreen()` wrapped in `BlocProvider<CreateChatCubit>`. `ChatsCubit` is provided at the `MainScreen` level (line 29-30). No changes needed.
  - Acceptance criteria: Chats tab shows ChatHomeScreen, cubits available in widget tree

---

## Phase 14: Manual Testing

**Purpose**: End-to-end verification of all features

- [ ] T048 Manual test: create chat with friend email
  - Goal: Verify chat creation works
  - Details: Tap FAB â†’ enter valid friend email â†’ tap create â†’ verify chat appears in list. Verify stable chat ID is used.
  - Acceptance criteria: Chat created, appears in both users' lists

- [ ] T049 Manual test: prevent chat with self and duplicates
  - Goal: Verify validation errors
  - Details: Try creating chat with own email â†’ "Cannot create chat with yourself" toast. Try creating existing chat â†’ "Chat already exists" toast. Try non-existent email â†’ "No user found" toast.
  - Acceptance criteria: All three validation cases show correct error toasts

- [ ] T050 Manual test: send text message and verify lastMessage
  - Goal: Verify text messaging and chat document updates
  - Details: Open chat â†’ send text â†’ verify message appears. Check Firestore: `lastMessage`, `lastMessageType: "text"`, `lastMessageTime` updated.
  - Acceptance criteria: Message visible, chat document updated

- [ ] T051 Manual test: send image message
  - Goal: Verify image upload and display
  - Details: Tap attachment â†’ select image â†’ verify upload â†’ verify image message appears with preview. Check Supabase: file exists at `chats/{chatId}/messages/images/...`.
  - Acceptance criteria: Image uploaded, message displays with thumbnail

- [ ] T052 Manual test: send file message
  - Goal: Verify file upload and display
  - Details: Tap attachment â†’ select file â†’ verify upload â†’ verify file message shows file name.
  - Acceptance criteria: File uploaded, message displays with file name

- [ ] T053 Manual test: edit text message
  - Goal: Verify edit works and "edited" label appears
  - Details: Long-press own text message â†’ tap Edit â†’ change text â†’ confirm â†’ verify updated text and "edited" label. Verify `isEdited: true` in Firestore.
  - Acceptance criteria: Text updated, "edited" indicator visible

- [ ] T054 Manual test: delete message and verify storage cleanup
  - Goal: Verify hard delete and Supabase file removal
  - Details: Send an image message. Long-press â†’ tap Delete â†’ confirm â†’ verify message disappears. Check Supabase: file removed. Repeat with text message (no storage path).
  - Acceptance criteria: Message deleted from Firestore, storage file removed for media messages

- [ ] T055 Manual test: search chats and clear search
  - Goal: Verify search filtering and clear
  - Details: Search by friend email â†’ verify filtered results. Search non-existent â†’ verify empty state. Clear search â†’ verify full list restored.
  - Acceptance criteria: Search works, clear restores list

- [ ] T056 Manual test: pull to refresh
  - Goal: Verify pull-to-refresh reloads data
  - Details: Pull down on chats list â†’ verify spinner shows â†’ list reloads.
  - Acceptance criteria: Refresh triggers, data reloads

- [ ] T057 Manual test: real-time messages
  - Goal: Verify messages appear in real time
  - Details: Open same chat on two accounts. Send from Account A â†’ verify it appears on Account B without refresh.
  - Acceptance criteria: Messages appear in real time on both sides

- [ ] T058 Manual test: empty and error states
  - Goal: Verify empty/loading/error states display correctly
  - Details: New user with no chats â†’ "No chats yet". Open chat with no messages â†’ "No messages yet". All use localized text.
  - Acceptance criteria: All states show correct localized messages

---

## Phase 15: Polish & Cleanup

- [x] T059 Remove unused use case files from lib/features/single_chat/domain/use_cases/
  - Goal: Clean up unused use case layer
  - Files: `lib/features/single_chat/domain/use_cases/get_messages_use_case.dart`, `lib/features/single_chat/domain/use_cases/send_text_message_use_case.dart`, `lib/features/single_chat/domain/use_cases/send_image_message_use_case.dart`, `lib/features/single_chat/domain/use_cases/send_audio_message_use_case.dart`, `lib/features/single_chat/domain/use_cases/send_file_message_use_case.dart`
  - Details: Delete all use case files. Remove imports from cubits and DI. Verify no other files reference them.
  - Acceptance criteria: No use case files remain, project compiles

- [x] T060 Remove print statements and debug logs
  - Goal: Clean up debug output
  - Files: All modified files in `lib/features/single_chat/`
  - Details: Search for `print(` calls and remove them. Keep `debugPrint` in `DataBaseService` if desired.
  - Acceptance criteria: No stray print statements in single_chat feature

- [x] T061 Final build and compilation check
  - Goal: Verify project compiles without errors
  - Details: Run `flutter pub run build_runner build --delete-conflicting-outputs` then `flutter analyze`. Fix any warnings or errors.
  - Acceptance criteria: Zero errors, zero warnings (or only pre-existing ones)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies â€” start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 completion â€” BLOCKS all UI work
- **Phase 3-12 (User Stories)**: All depend on Phase 2 completion
  - US1 (View Chats): Independent
  - US2 (Create Chat): Independent
  - US3 (Send Text): Independent
  - US4 (Send Image): Depends on US3 (attachment button added to input bar)
  - US5 (Send File): Depends on US4 (shares attachment bottom sheet)
  - US6 (Real-Time): Verified alongside US3
  - US7 (Delete): Depends on US3 (needs message bubble)
  - US8 (Edit): Depends on US7 (shares long-press UI)
  - US9 (Search): Independent
  - US10 (Pull to Refresh): Independent (implemented in US1)
- **Phase 13 (Routes)**: After Phase 3
- **Phase 14 (Testing)**: After all user stories
- **Phase 15 (Polish)**: After testing

### Parallel Opportunities

Within Phase 1: T005, T006, T007, T008 can all run in parallel
Within Phase 2: T009, T010 (verify) can run in parallel
Within User Stories: US1, US2, US9, US10 can start in parallel after Phase 2

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 3)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: View Chats (US1)
4. Complete Phase 4: Create Chat (US2)
5. Complete Phase 5: Send Text (US3)
6. **STOP and VALIDATE**: Test chat list, creation, and text messaging
7. Deploy/demo as MVP

### Incremental Delivery

8. Add US4: Image Messages
9. Add US5: File Messages
10. Add US7: Delete Messages
11. Add US8: Edit Messages
12. Add US9: Search
13. Polish and cleanup

---

## Common Mistakes to Avoid

1. **DO NOT** mix `CreateChatCubit` with `ChatsCubit` â€” they have separate responsibilities
2. **DO NOT** mix `SendMessageCubit`/`MessagesCubit` with `ChatsCubit`
3. **DO NOT** use `FirebaseFirestore.instance` directly â€” use `DataBaseService` (except for generating doc IDs)
4. **DO NOT** use `currentUser.uid` as chat ID â€” use stable chat ID
5. **DO NOT** forget to save `storagePath` for media messages
6. **DO NOT** forget to call `updateChatLastMessage` after every send
7. **DO NOT** forget to run `build_runner` after model/state changes
8. **DO NOT** forget `isClosed` guards in stream listeners
9. **DO NOT** create `TextEditingController` inside `build()` â€” use State class + dispose
10. **DO NOT** hardcode labels â€” use `context.translate(LangKeys.key)`
11. **DO NOT** use separate `ChatsCubit` instances for AppBar search and body list
12. **DO NOT** use `Text` when `TextApp` should be used
13. **DO NOT** use `ElevatedButton` when `CustomLinearButton` should be used
14. **DO NOT** use `TextField` when `CustomField` should be used

## Notes

- Total tasks: 61
- Verify tasks (no code changes): 14
- Implementation tasks: 33
- Testing tasks: 11
- Cleanup tasks: 3
- [P] parallelizable tasks: 8
- Commit after each logical group of tasks
