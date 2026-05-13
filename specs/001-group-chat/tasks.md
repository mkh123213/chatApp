# Tasks: Group Chats

**Branch**: `001-group-chat` | **Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)
**Input**: Design documents from `specs/001-group-chat/`

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependency on in-progress task)
- **[US1/US2/US3]**: Maps to user story from spec.md

---

## Phase 1: Setup — Firestore Constants

**Purpose**: Add the two new collection constants. No other task can hard-code collection names.

- [ ] T001 Add `groupsCollection` and `messagesCollection` constants to `lib/constants/fierstore_paths.dart`
  - Goal: Centralise all Firestore collection names so no file uses raw strings.
  - Files: `lib/constants/fierstore_paths.dart`
  - Details: Append `const String groupsCollection = 'groups';` and `const String messagesCollection = 'messages';` below the existing constants. No other changes.
  - Acceptance criteria: File compiles; both constants are importable from any file in the project.

---

## Phase 2: Foundational — Models, Data Source, Repository, Dependency Injection

**Purpose**: Core data layer that all three user stories depend on. Complete this phase before any UI work.

**⚠️ CRITICAL**: No Cubit or UI work can begin until T001–T007 are complete and build_runner has been run (T004).

- [ ] T002 [P] Create `GroupModel` in `lib/features/groups/data/models/group_model.dart`
  - Goal: Dart model for a Firestore group document, with full serialization support.
  - Files: `lib/features/groups/data/models/group_model.dart`
  - Details:
    - Annotate with `@JsonSerializable()`.
    - Fields: `id` (String), `name` (String), `imageUrl` (String), `members` (List\<String\>), `membersEmails` (List\<String\>), `admins` (List\<String\>), `lastMessage` (String?), `lastMessageTime` (DateTime?), `createdAt` (DateTime?).
    - `lastMessageTime` and `createdAt` use `@JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)` with the same static Timestamp↔DateTime helpers used in `ChatModel`.
    - Provide `factory GroupModel.fromJson(Map<String,dynamic> json)` delegating to generated `_$GroupModelFromJson`.
    - Provide `Map<String,dynamic> toJson()` delegating to generated `_$GroupModelToJson`.
    - Provide `factory GroupModel.fromFirestore({required String id, required Map<String,dynamic> data})` → `GroupModel.fromJson({'id': id, ...data})`.
  - Acceptance criteria: File compiles (after build_runner in T004). `GroupModel.fromFirestore` correctly deserialises a Firestore document map. Timestamp fields convert to `DateTime`.

- [ ] T003 [P] Create `GroupMessageModel` in `lib/features/groups/data/models/group_message_model.dart`
  - Goal: Dart model for a Firestore group message document.
  - Files: `lib/features/groups/data/models/group_message_model.dart`
  - Details:
    - Annotate with `@JsonSerializable()`.
    - Fields: `id` (String), `senderId` (String), `senderEmail` (String), `text` (String), `createdAt` (DateTime?).
    - `createdAt` uses the same `@JsonKey` Timestamp converter as `GroupModel`.
    - Same `fromJson` / `toJson` / `fromFirestore` pattern as `GroupModel`.
  - Acceptance criteria: File compiles after build_runner. `fromFirestore` correctly maps a Firestore message document.

- [ ] T004 Run `build_runner` to generate `.g.dart` files for `GroupModel` and `GroupMessageModel`
  - Goal: Generate `group_model.g.dart` and `group_message_model.g.dart` before any file imports these models.
  - Files: `lib/features/groups/data/models/group_model.g.dart` (generated), `lib/features/groups/data/models/group_message_model.g.dart` (generated)
  - Details: Run `flutter pub run build_runner build --delete-conflicting-outputs` from the project root. Confirm both `.g.dart` files are created.
  - Acceptance criteria: No build errors. `GroupModel.fromJson` and `GroupMessageModel.fromJson` resolve to generated code.

- [ ] T005 Create `GroupsRemoteDataSource` in `lib/features/groups/data/datasources/groups_remote_data_source.dart`
  - Goal: Abstract + implementation class for all Firestore group operations.
  - Files: `lib/features/groups/data/datasources/groups_remote_data_source.dart`
  - Details:
    - Abstract class `GroupsRemoteDataSource` with four method signatures: `getGroups`, `createGroup`, `getGroupMessages`, `sendGroupMessage`.
    - `GroupsRemoteDataSourceImpl` constructor takes `DataBaseService` — inject via `_dataBaseService` field.
    - `getGroups`: use `_dataBaseService.collectionStream(path: groupsCollection, builder: GroupModel.fromFirestore, queryBuilder: (q) => q.where('members', arrayContains: currentUserId))`.
    - `createGroup`: generate doc ID via `FirebaseFirestore.instance.collection(groupsCollection).doc().id` (the only permitted direct SDK call). Build a complete data map; include `createdAt: Timestamp.now()`, `lastMessage: ''`, `lastMessageTime: null`, `admins: [currentUserId]`; ensure `currentUserId` is in `membersIds`. Write with `_dataBaseService.setData(path: '$groupsCollection/$groupId', data: groupData)`.
    - `getGroupMessages`: use `_dataBaseService.collectionStream(path: '$groupsCollection/$groupId/$messagesCollection', builder: GroupMessageModel.fromFirestore, queryBuilder: (q) => q.orderBy('createdAt', descending: false))`.
    - `sendGroupMessage`: generate message doc ID via direct SDK. Write message to `'$groupsCollection/$groupId/$messagesCollection/$messageId'`. Update group: `_dataBaseService.setData(path: '$groupsCollection/$groupId', data: {'lastMessage': text, 'lastMessageTime': Timestamp.now()})` (merge: true is the default).
  - Acceptance criteria: File compiles. No direct `FirebaseFirestore.instance` usage except for the two `.doc().id` calls. All four methods use `_dataBaseService`.

- [ ] T006 Create `GroupsRepo` in `lib/features/groups/data/repositories/groups_repo.dart`
  - Goal: Repository abstraction that delegates to the remote data source.
  - Files: `lib/features/groups/data/repositories/groups_repo.dart`
  - Details:
    - Abstract class `GroupsRepo` with the same four method signatures.
    - `GroupsRepoImpl` constructor takes `GroupsRemoteDataSource`. Each method delegates directly to `_groupsRemoteDataSource` — no business logic.
  - Acceptance criteria: File compiles. Each method is a single-line delegation. No Firestore or DataBaseService imports.

- [ ] T007 Add `_initGroups()` to `lib/core/di/injection_container.dart`
  - Goal: Register all five group-feature services with GetIt.
  - Files: `lib/core/di/injection_container.dart`
  - Details:
    - Add `await _initGroups();` to `setupInjector()` after `_initChats()`.
    - `_initGroups()`: `registerLazySingleton<GroupsRemoteDataSource>(() => GroupsRemoteDataSourceImpl(dataBaseService: sl<DataBaseService>()))`, `registerLazySingleton<GroupsRepo>(() => GroupsRepoImpl(groupsRemoteDataSource: sl<GroupsRemoteDataSource>()))`, `registerFactory<GroupsCubit>(() => GroupsCubit(groupsRepo: sl<GroupsRepo>()))`, `registerFactory<CreateGroupCubit>(() => CreateGroupCubit(groupsRepo: sl<GroupsRepo>()))`, `registerFactory<SelectedGroupChatCubit>(() => SelectedGroupChatCubit(groupsRepo: sl<GroupsRepo>()))`.
  - Acceptance criteria: App launches without GetIt exceptions. `sl<GroupsCubit>()` returns a fresh `GroupsCubit` instance each call.

**Checkpoint**: Data layer and DI complete — all three user stories can now be implemented.

---

## Phase 3: User Story 1 — Browse and Open Group Conversations (P1) 🎯 MVP

**Goal**: Logged-in user sees their real-time group list and can tap into any group.

**Independent Test**: A user who is a member of two groups navigates to the Groups screen — both group cards appear. Tapping one opens `SelectedGroupChatScreen`.

- [ ] T008 [P] [US1] Create `GroupsState` in `lib/features/groups/presentation/bloc/groups_cubit/groups_state.dart`
  - Goal: Define all five `GroupsState` variants using Freezed.
  - Files: `lib/features/groups/presentation/bloc/groups_cubit/groups_state.dart`
  - Details:
    - `part of 'groups_cubit.dart';`
    - `@freezed class GroupsState with _$GroupsState`: `initial()`, `loading()`, `loaded({required List<GroupModel> groups})`, `empty()`, `error({required String message})`.
  - Acceptance criteria: After build_runner (T010), `GroupsState` pattern-matches exhaustively.

- [ ] T009 [US1] Create `GroupsCubit` in `lib/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart`
  - Goal: Stream-based cubit for real-time group list, with subscription guard.
  - Files: `lib/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart`
  - Details:
    - `part 'groups_state.dart';`
    - Constructor takes `GroupsRepo`.
    - Private fields: `StreamSubscription<List<GroupModel>>? _groupsSubscription;` and `bool _isListeningToGroups = false;`.
    - `getGroups({required String currentUserId})`: guard `if (_isListeningToGroups) return;`, set flag, `emit(loading())`, subscribe to `_groupsRepo.getGroups(...)`, emit `loaded`/`empty`/`error` from stream events.
    - Override `close()`: `await _groupsSubscription?.cancel(); return super.close();`.
  - Acceptance criteria: Calling `getGroups` twice on the same instance does not create two Firestore subscriptions. `close()` cancels the subscription.

- [ ] T010 [US1] Run `build_runner` to generate `groups_cubit.freezed.dart`
  - Goal: Generate Freezed code for `GroupsState`.
  - Files: `lib/features/groups/presentation/bloc/groups_cubit/groups_cubit.freezed.dart` (generated)
  - Details: `flutter pub run build_runner build --delete-conflicting-outputs`. Confirm `_$GroupsState` is generated.
  - Acceptance criteria: No build errors. `GroupsState.loaded(groups: [...])` compiles.

- [ ] T011 [US1] Create `GroupsChatScreen` in `lib/features/groups/presentation/screens/groups_chat_screen.dart`
  - Goal: Root screen that owns the `GroupsCubit` lifecycle.
  - Files: `lib/features/groups/presentation/screens/groups_chat_screen.dart`
  - Details:
    - `StatelessWidget`.
    - `Scaffold` with `AppBar(title: TextApp(text: context.translate(LangKeys.groups)))`.
    - `BlocProvider<GroupsCubit>(create: (_) => sl<GroupsCubit>(), child: const GroupsChatBody())`.
    - FAB with an icon that opens `CreateGroupBottomSheet` via `showModalBottomSheet`.
  - Acceptance criteria: Screen compiles. Navigating to it does not throw a GetIt or BlocProvider error.

- [ ] T012 [US1] Create `GroupsChatBody` in `lib/features/groups/presentation/refactor/groups_chat_body.dart`
  - Goal: StatefulWidget that triggers the group list stream on mount.
  - Files: `lib/features/groups/presentation/refactor/groups_chat_body.dart`
  - Details:
    - `StatefulWidget`.
    - `initState`: retrieve current user UID (from `sl<AuthCubit>().state` or equivalent), call `context.read<GroupsCubit>().getGroups(currentUserId: uid)`.
    - `build`: returns `const GroupsBlocConsumer()`.
  - Acceptance criteria: `getGroups` is called exactly once on first render.

- [ ] T013 [US1] Create `GroupsBlocConsumer` in `lib/features/groups/presentation/widgets/groups_bloc_consumer.dart`
  - Goal: Handle all five `GroupsState` variants and render the appropriate UI.
  - Files: `lib/features/groups/presentation/widgets/groups_bloc_consumer.dart`
  - Details:
    - `BlocConsumer<GroupsCubit, GroupsState>` (listener can be empty for now).
    - `builder`:
      - `initial` / `loading` → `Center(child: CircularProgressIndicator())` or shimmer widget.
      - `empty` → `Center(child: TextApp(text: context.translate(LangKeys.noGroupsYet)))`.
      - `loaded` → `ListView.builder` producing `GroupCard` widgets.
      - `error` → `Center(child: TextApp(text: state.message))`.
  - Acceptance criteria: Each state branch renders without overflow or null-pointer errors.

- [ ] T014 [US1] Create `GroupCard` in `lib/features/groups/presentation/widgets/group_card.dart`
  - Goal: Single tappable group card displaying name and last message preview.
  - Files: `lib/features/groups/presentation/widgets/group_card.dart`
  - Details:
    - `StatelessWidget` with `required GroupModel group` parameter.
    - `ListTile` with `title: TextApp(text: group.name)` and `subtitle: TextApp(text: group.lastMessage ?? '')`.
    - `onTap`: `Navigator.push(context, MaterialPageRoute(builder: (_) => SelectedGroupChatScreen(group: group)))`.
    - Style with `context.color`.
  - Acceptance criteria: Tapping the card navigates to `SelectedGroupChatScreen`. No `Text` widget used — only `TextApp`.

**Checkpoint**: User Story 1 — real-time group list is fully functional. User can see groups and tap into them.

---

## Phase 4: User Story 2 — Create a New Group (P1)

**Goal**: Logged-in user creates a group by entering a name and member emails.

**Independent Test**: User taps the FAB, fills in group name and one member email, taps Create — group appears in the list. An empty name is rejected with validation feedback.

- [ ] T015 [P] [US2] Create `CreateGroupState` in `lib/features/groups/presentation/bloc/create_group_cubit/create_group_state.dart`
  - Goal: Four-variant Freezed state for group creation only.
  - Files: `lib/features/groups/presentation/bloc/create_group_cubit/create_group_state.dart`
  - Details:
    - `part of 'create_group_cubit.dart';`
    - `@freezed class CreateGroupState with _$CreateGroupState`: `initial()`, `loading()`, `success()`, `error({required String message})`.
  - Acceptance criteria: After build_runner (T017), state pattern-matches exhaustively.

- [ ] T016 [US2] Create `CreateGroupCubit` in `lib/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart`
  - Goal: Simple async Cubit for group creation — completely independent of `GroupsCubit`.
  - Files: `lib/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart`
  - Details:
    - `part 'create_group_state.dart';`
    - Constructor takes `GroupsRepo`.
    - `createGroup({required String currentUserId, required String currentUserEmail, required String groupName, required List<String> membersIds, required List<String> membersEmails})`:
      - `emit(const CreateGroupState.loading())`.
      - Await `_groupsRepo.createGroup(...)`.
      - On success: `emit(const CreateGroupState.success())`.
      - On error: `emit(CreateGroupState.error(message: e.toString()))`.
    - No `StreamSubscription` needed — no `close()` override required.
  - Acceptance criteria: `createGroup` emits `loading` then `success` or `error`. `GroupsCubit` state is not touched.

- [ ] T017 [US2] Run `build_runner` to generate `create_group_cubit.freezed.dart`
  - Goal: Generate Freezed code for `CreateGroupState`.
  - Files: `lib/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.freezed.dart` (generated)
  - Details: `flutter pub run build_runner build --delete-conflicting-outputs`.
  - Acceptance criteria: No errors. `CreateGroupState.success()` and `.error(...)` compile.

- [ ] T018 [US2] Create `CreateGroupBottomSheet` in `lib/features/groups/presentation/widgets/create_group_bottom_sheet.dart`
  - Goal: Bottom sheet with form fields, providing its own `CreateGroupCubit` scope.
  - Files: `lib/features/groups/presentation/widgets/create_group_bottom_sheet.dart`
  - Details:
    - `StatefulWidget`.
    - Declare `final TextEditingController _groupNameController = TextEditingController();` and `final TextEditingController _membersEmailsController = TextEditingController();` as instance fields (never inside `build()`).
    - `dispose()` overrides `_groupNameController.dispose()` and `_membersEmailsController.dispose()`.
    - `build()` wraps content with `BlocProvider<CreateGroupCubit>(create: (_) => sl<CreateGroupCubit>(), child: _buildBody())`.
    - `_buildBody()` returns a `Column` with:
      - `CustomField(controller: _groupNameController, hint: context.translate(LangKeys.groupName))`.
      - `CustomField(controller: _membersEmailsController, hint: context.translate(LangKeys.membersEmails))`.
      - `CreateGroupBlocConsumer(groupNameController: _groupNameController, membersEmailsController: _membersEmailsController)`.
  - Acceptance criteria: Controllers are NOT created inside `build()`. `dispose()` is overridden. `CreateGroupCubit` is provided only within this bottom sheet.

- [ ] T019 [US2] Create `CreateGroupBlocConsumer` in `lib/features/groups/presentation/widgets/create_group_bloc_consumer.dart`
  - Goal: Controls the submit button state and shows toast notifications.
  - Files: `lib/features/groups/presentation/widgets/create_group_bloc_consumer.dart`
  - Details:
    - `StatelessWidget` with `TextEditingController` params for name and emails.
    - `BlocConsumer<CreateGroupCubit, CreateGroupState>`.
    - `listener`:
      - `success`: `ShowToast.show(context.translate(LangKeys.groupCreatedSuccessfully))`, then `Navigator.pop(context)`.
      - `error`: `ShowToast.showError(state.message)` (or equivalent).
    - `builder`:
      - `loading`: `CustomLinearButton(text: context.translate(LangKeys.createGroup), onTap: null)` with loading indicator.
      - All others: active `CustomLinearButton(text: context.translate(LangKeys.createGroup), onTap: _onCreateTapped)`.
    - `_onCreateTapped` reads current user UID/email (from AuthCubit or GetIt), parses the members emails field by `split(',').map((e) => e.trim()).where(isNotEmpty).toList()`, validates group name is non-empty, then calls `context.read<CreateGroupCubit>().createGroup(...)`.
  - Acceptance criteria: Empty group name does not trigger `createGroup`. Success toast is shown. Bottom sheet closes on success. `ElevatedButton` is NOT used — only `CustomLinearButton`.

**Checkpoint**: User Story 2 — group creation works. Creating a group does not disrupt the live group list.

---

## Phase 5: User Story 3 — Send and Receive Messages in a Group (P1)

**Goal**: Group member sends and receives real-time text messages inside a selected group.

**Independent Test**: Two authenticated users both in the same group open the group chat — User A sends a message; User B sees it without refreshing. Messages are in chronological order (oldest top, newest bottom).

- [ ] T020 [P] [US3] Create `SelectedGroupChatState` in `lib/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_state.dart`
  - Goal: Five-variant Freezed state for the selected group chat messages.
  - Files: `lib/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_state.dart`
  - Details:
    - `part of 'selected_group_chat_cubit.dart';`
    - `@freezed class SelectedGroupChatState with _$SelectedGroupChatState`: `initial()`, `loading()`, `loaded({required List<GroupMessageModel> messages})`, `empty()`, `error({required String message})`.
  - Acceptance criteria: After build_runner (T022), state exhaustive-matches.

- [ ] T021 [US3] Create `SelectedGroupChatCubit` in `lib/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart`
  - Goal: Stream-based cubit for group messages + a fire-and-forget send method.
  - Files: `lib/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart`
  - Details:
    - `part 'selected_group_chat_state.dart';`
    - Constructor takes `GroupsRepo`.
    - Private fields: `StreamSubscription<List<GroupMessageModel>>? _messagesSubscription;` and `bool _isListeningToMessages = false;`.
    - `getGroupMessages({required String groupId})`: same guard pattern as `GroupsCubit`, emit loading → loaded/empty/error from stream.
    - `sendGroupMessage({required String groupId, required String senderId, required String senderEmail, required String text})`: `await _groupsRepo.sendGroupMessage(...)`. Does NOT emit any state — the stream delivers the new message automatically.
    - Override `close()`: `await _messagesSubscription?.cancel(); return super.close();`.
  - Acceptance criteria: Messages stream is independent of `GroupsCubit`. `sendGroupMessage` does not emit a loading state. Subscription is cancelled on close.

- [ ] T022 [US3] Run `build_runner` to generate `selected_group_chat_cubit.freezed.dart`
  - Goal: Generate Freezed code for `SelectedGroupChatState`.
  - Files: `lib/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.freezed.dart` (generated)
  - Details: `flutter pub run build_runner build --delete-conflicting-outputs`.
  - Acceptance criteria: No errors. `SelectedGroupChatState.loaded(messages: [...])` compiles.

- [ ] T023 [US3] Create `SelectedGroupChatScreen` in `lib/features/groups/presentation/screens/selected_group_chat_screen.dart`
  - Goal: Root screen for the selected group, owns `SelectedGroupChatCubit` lifecycle.
  - Files: `lib/features/groups/presentation/screens/selected_group_chat_screen.dart`
  - Details:
    - `StatelessWidget` with `required GroupModel group` parameter.
    - `Scaffold` with `AppBar(title: TextApp(text: group.name))`.
    - `BlocProvider<SelectedGroupChatCubit>(create: (_) => sl<SelectedGroupChatCubit>(), child: SelectedGroupChatBody(group: group))`.
  - Acceptance criteria: Screen compiles. `SelectedGroupChatCubit` is a fresh instance per navigation.

- [ ] T024 [US3] Create `SelectedGroupChatBody` in `lib/features/groups/presentation/refactor/selected_group_chat_body.dart`
  - Goal: StatefulWidget that starts the messages stream and lays out the chat view.
  - Files: `lib/features/groups/presentation/refactor/selected_group_chat_body.dart`
  - Details:
    - `StatefulWidget` with `required GroupModel group` parameter.
    - `initState`: retrieve current user (UID + email), call `context.read<SelectedGroupChatCubit>().getGroupMessages(groupId: group.id)`.
    - `build`: `Column` with `Expanded(child: GroupMessagesBlocConsumer(currentUserId: currentUserId))` and `GroupMessageInput(group: group, currentUserId: currentUserId, currentUserEmail: currentUserEmail)`.
  - Acceptance criteria: `getGroupMessages` is called once. Layout renders without overflow.

- [ ] T025 [US3] Create `GroupMessagesBlocConsumer` in `lib/features/groups/presentation/widgets/group_messages_bloc_consumer.dart`
  - Goal: Handle all five `SelectedGroupChatState` variants and display the message list.
  - Files: `lib/features/groups/presentation/widgets/group_messages_bloc_consumer.dart`
  - Details:
    - `BlocConsumer<SelectedGroupChatCubit, SelectedGroupChatState>` with `required String currentUserId`.
    - `builder`:
      - `initial` / `loading` → spinner.
      - `empty` → `Center(child: TextApp(text: context.translate(LangKeys.noMessagesYet)))`.
      - `loaded` → `ListView.builder` of `GroupMessageBubble`, `reverse: false`, attach a `ScrollController` and scroll to bottom when state is `loaded`.
      - `error` → error `TextApp`.
  - Acceptance criteria: All five states render. New messages cause auto-scroll to bottom.

- [ ] T026 [US3] Create `GroupMessageBubble` in `lib/features/groups/presentation/widgets/group_message_bubble.dart`
  - Goal: Single message bubble aligned by sender.
  - Files: `lib/features/groups/presentation/widgets/group_message_bubble.dart`
  - Details:
    - `StatelessWidget` with `required GroupMessageModel message` and `required String currentUserId`.
    - If `message.senderId == currentUserId`: align right, use `context.color` for self-bubble background.
    - Otherwise: align left, show `TextApp(text: message.senderEmail)` as a small label above the bubble.
    - Show `TextApp(text: message.text)` as the message body.
    - No `Text` widget — only `TextApp`.
  - Acceptance criteria: Self messages appear right-aligned; others appear left with sender email.

- [ ] T027 [US3] Create `GroupMessageInput` in `lib/features/groups/presentation/widgets/group_message_input.dart`
  - Goal: Text input + send button for composing and sending messages.
  - Files: `lib/features/groups/presentation/widgets/group_message_input.dart`
  - Details:
    - `StatefulWidget` with `required GroupModel group`, `required String currentUserId`, `required String currentUserEmail`.
    - Declare `final TextEditingController _messageController = TextEditingController();` as an instance field — NOT inside `build()`.
    - `dispose()`: `_messageController.dispose(); super.dispose();`.
    - `build()`: `Row` with `Expanded(child: CustomField(controller: _messageController, hint: context.translate(LangKeys.enterMessage)))` and an `IconButton` / `CustomLinearButton` for send.
    - On send: validate `_messageController.text.trim().isNotEmpty`, call `context.read<SelectedGroupChatCubit>().sendGroupMessage(...)`, clear controller.
    - Do NOT use `TextField` — use `CustomField` only.
  - Acceptance criteria: Empty message does not call `sendGroupMessage`. Controller is disposed. `TextField` is not used.

**Checkpoint**: User Story 3 — real-time messaging is complete. All three user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

### Localization

- [ ] T028 [P] Add 10 `LangKeys` constants to `lib/core/language/lang_keys.dart`
  - Goal: Define string constants for all new user-visible strings.
  - Files: `lib/core/language/lang_keys.dart`
  - Details: Add `static const String groups = 'groups';`, `noGroupsYet = 'no_groups_yet'`, `createGroup = 'create_group'`, `groupName = 'group_name'`, `groupCreatedSuccessfully = 'group_created_successfully'`, `noMessagesYet = 'no_messages_yet'`, `sendMessage = 'send_message'`, `enterMessage = 'enter_message'`, `addMembers = 'add_members'`, `membersEmails = 'members_emails'`.
  - Acceptance criteria: All 10 constants exist. No raw string is used in any group feature widget.

- [ ] T029 [P] Add 10 English translations to `lang/en.json`
  - Goal: English values for all new keys.
  - Files: `lang/en.json`
  - Details: Add `"groups": "Groups"`, `"no_groups_yet": "No groups yet"`, `"create_group": "Create Group"`, `"group_name": "Group Name"`, `"group_created_successfully": "Group created successfully"`, `"no_messages_yet": "No messages yet"`, `"send_message": "Send Message"`, `"enter_message": "Enter a message..."`, `"add_members": "Add Members"`, `"members_emails": "Members Emails"`.
  - Acceptance criteria: All 10 keys are present in `en.json`. JSON is valid.

- [ ] T030 [P] Add 10 Arabic translations to `lang/ar.json`
  - Goal: Arabic values for all new keys.
  - Files: `lang/ar.json`
  - Details: Add `"groups": "المجموعات"`, `"no_groups_yet": "لا توجد مجموعات بعد"`, `"create_group": "إنشاء مجموعة"`, `"group_name": "اسم المجموعة"`, `"group_created_successfully": "تم إنشاء المجموعة بنجاح"`, `"no_messages_yet": "لا توجد رسائل بعد"`, `"send_message": "إرسال الرسالة"`, `"enter_message": "اكتب رسالة..."`, `"add_members": "إضافة أعضاء"`, `"members_emails": "البريد الإلكتروني للأعضاء"`.
  - Acceptance criteria: All 10 keys are present in `ar.json`. Switching app language to Arabic shows Arabic strings in the group feature.

### Build Runner — Final Pass

- [ ] T031 Run final `build_runner` pass to confirm all generated files are current
  - Goal: Ensure no stale `.g.dart` or `.freezed.dart` files remain after all tasks are done.
  - Files: All `*.g.dart` and `*.freezed.dart` files in `lib/features/groups/`
  - Details: `flutter pub run build_runner build --delete-conflicting-outputs`. Fix any conflicts before proceeding.
  - Acceptance criteria: Zero errors. App compiles with `flutter build` or `flutter run`.

### Firestore Security Rules

- [ ] T032 Add Firestore Security Rules for the `groups` collection and `messages` subcollection
  - Goal: Enforce member-only access as required by FR-016.
  - Files: `firestore.rules` (project root)
  - Details:
    - For `groups/{groupId}`: allow read and write only if `request.auth.uid` is in `resource.data.members`.
    - For `groups/{groupId}/messages/{messageId}`: allow read and write only if `request.auth.uid` is in the parent group's `members` array. Use `get(/databases/$(database)/documents/groups/$(groupId)).data.members`.
    - Deploy rules with `firebase deploy --only firestore:rules`.
  - Acceptance criteria: A non-member UID cannot read any group document or its messages. A member UID can read and write to their group.

### Manual Testing

- [ ] T033 Manual test — Create a group and verify it appears in the real-time list
  - Goal: Confirm US2 end-to-end: group creation → list update.
  - Files: N/A (testing only)
  - Details: Log in as User A. Open Groups screen. Tap FAB. Enter a group name and User B's email. Tap Create. Confirm success toast appears and the new group card appears in the list immediately, without navigating away.
  - Acceptance criteria: Group appears in list within 2 seconds. No error toast. Groups list did not show a loading spinner during creation.

- [ ] T034 Manual test — Open selected group chat and verify message history
  - Goal: Confirm US1 end-to-end: navigate to group → see empty state or message history.
  - Files: N/A (testing only)
  - Details: Tap any group card. Confirm navigation to `SelectedGroupChatScreen`. If no messages: empty state message shown. If messages exist: list renders in chronological order (oldest top).
  - Acceptance criteria: Navigation works. Message order is oldest-first. Empty state shows correct translated text.

- [ ] T035 Manual test — Send a message and verify real-time delivery to another user
  - Goal: Confirm US3 end-to-end: send → both users see the message.
  - Files: N/A (testing only)
  - Details: Log in as User A on one device (or emulator) and User B on another. Both open the same group chat. User A types a message and taps send. Verify User A's message appears right-aligned on their screen and left-aligned on User B's screen — without User B refreshing. Confirm User A's message input is cleared after send.
  - Acceptance criteria: Message appears on User B's device within 3 seconds. Sender email shown on User B's side. Input cleared.

- [ ] T036 Manual test — Verify `lastMessage` and `lastMessageTime` update after sending
  - Goal: Confirm the group document updates on every send, enabling list previews.
  - Files: N/A (testing only)
  - Details: After sending a message, navigate back to the Groups screen. Confirm the group card shows the sent message text as the subtitle. Open Firestore Console and verify `groups/{groupId}` has updated `lastMessage` and `lastMessageTime` fields.
  - Acceptance criteria: Group card subtitle reflects the last sent message. Firestore document fields are updated (not null).

- [ ] T037 Manual test — Verify `CreateGroupCubit` isolation (creating group does not reload list)
  - Goal: Confirm FR-011: group creation loading state is independent of groups list state.
  - Files: N/A (testing only)
  - Details: Open the Groups screen while at least one group exists (loaded state visible). Open the bottom sheet. During the Create button loading state, confirm the groups list behind the bottom sheet still shows the loaded group cards — it does NOT replace them with a loading spinner.
  - Acceptance criteria: Groups list state is `loaded` during and after group creation. Only the Create button shows a loading indicator.

### Cleanup and Refactor

- [ ] T038 Code review pass — verify conventions, disposal, and no-raw-string usage
  - Goal: Catch common convention violations before code review.
  - Files: All files in `lib/features/groups/`
  - Details:
    - Confirm no `TextEditingController` is declared inside any `build()` method.
    - Confirm no `FirebaseFirestore.instance` is used in any file other than `groups_remote_data_source.dart`, and only for `.doc().id`.
    - Confirm no `Text(...)` widget — only `TextApp(...)`.
    - Confirm no `ElevatedButton` — only `CustomLinearButton`.
    - Confirm no `TextField` — only `CustomField`.
    - Confirm `ShowToast` is used for all success/error feedback.
    - Confirm all user-visible strings go through `context.translate(LangKeys.key)`.
    - Confirm `dispose()` is overridden in `CreateGroupBottomSheet` and `GroupMessageInput`.
    - Confirm `groups_cubit.dart` and `selected_group_chat_cubit.dart` both override `close()` and cancel their subscriptions.
    - Confirm Firestore paths use constants (`groupsCollection`, `messagesCollection`), not hard-coded strings.
  - Acceptance criteria: All conventions pass. No raw collection strings remain in Dart files.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Constants)**: Start immediately — no dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1. **Blocks all user story phases.**
- **Phase 3 (US1)**: Depends on Phase 2 completion.
- **Phase 4 (US2)**: Depends on Phase 2 completion. Can run in parallel with Phase 3.
- **Phase 5 (US3)**: Depends on Phase 2 completion. Can run in parallel with Phases 3 and 4.
- **Phase 6 (Polish)**: Depends on Phases 3–5.

### Within Phase 2

```
T001 → T002, T003 (parallel) → T004 → T005 → T006 → T007
```

### Within Phase 3 (US1)

```
T008, T009 (parallel) → T010 → T011 → T012 → T013 → T014
```

### Within Phase 4 (US2)

```
T015, T016 (parallel) → T017 → T018 → T019
```

### Within Phase 5 (US3)

```
T020, T021 (parallel) → T022 → T023 → T024 → T025 → T026 → T027
```

### Parallel Opportunities Within Phases

```bash
# Phase 2 — run together:
T002 "Create GroupModel"
T003 "Create GroupMessageModel"

# Phase 3 — run together:
T008 "Create GroupsState"
T009 "Create GroupsCubit"

# Phase 4 — run together:
T015 "Create CreateGroupState"
T016 "Create CreateGroupCubit"

# Phase 5 — run together:
T020 "Create SelectedGroupChatState"
T021 "Create SelectedGroupChatCubit"

# Phase 6 — run together:
T028 "Add LangKeys"
T029 "Add en.json translations"
T030 "Add ar.json translations"
```

---

## Implementation Strategy

### MVP First (All Three Stories — All P1)

All three user stories are P1 in this feature. Complete them in order:

1. **Phase 1 + Phase 2** → Foundation ready
2. **Phase 3** → Real-time group list (independently testable: T033, T034)
3. **Phase 4** → Group creation (independently testable: T033, T037)
4. **Phase 5** → Messaging (independently testable: T035, T036)
5. **Phase 6** → Polish, rules, cleanup

### Common Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| `TextEditingController` inside `build()` | Declare as instance field, dispose in `dispose()` |
| `FirebaseFirestore.instance` used everywhere | Only permitted in `groups_remote_data_source.dart` for `.doc().id` |
| `CreateGroupCubit` mixed with `GroupsCubit` | Provide `CreateGroupCubit` inside bottom sheet only — never at screen level |
| `SelectedGroupChatCubit` state bleeding into `GroupsCubit` | They share no state; `SelectedGroupChatCubit` is provided at `SelectedGroupChatScreen` level only |
| Wrong Firestore path for messages | Always `'$groupsCollection/$groupId/$messagesCollection'` — never `'messages'` alone |
| `.g.dart` / `.freezed.dart` files missing | Run build_runner after T003, T010, T017, T022, and once more at T031 |
| Missing `empty` / `error` / `loading` state handlers | Every `BlocConsumer.builder` must handle all five states explicitly |
| Using `Text`, `ElevatedButton`, or `TextField` | Use `TextApp`, `CustomLinearButton`, `CustomField` everywhere |

---

## Notes

- Mark tasks complete with `[x]` as you finish them.
- Run `build_runner` after EVERY batch of model or Freezed state file creation.
- Commit after each phase checkpoint.
- Stop at each checkpoint to verify the story works independently before continuing.
