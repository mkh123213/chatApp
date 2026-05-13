# Implementation Requirements Checklist: Group Chats

**Purpose**: Validate that requirements and design artifacts are complete, clear, and consistent enough to implement each layer of the Group Chat feature without ambiguity.
**Created**: 2026-05-04
**Feature**: [spec.md](../spec.md) | [plan.md](../plan.md) | [data-model.md](../data-model.md)

---

## 1. Firestore Constants

- [ ] CHK001 - Are the two new Firestore collection constants (`groupsCollection = 'groups'` and `messagesCollection = 'messages'`) explicitly defined in `data-model.md` and referenced in the plan? [Completeness, data-model.md §Firestore Path Constants, plan.md §Step 1]
- [ ] CHK002 - Are all four composite Firestore path formulas (group list, single group, message list, single message) documented with concrete string templates? [Clarity, data-model.md §Firestore Path Constants]
- [ ] CHK003 - Is the requirement to add constants to the existing constants file (not inline strings scattered across files) explicitly stated? [Completeness, plan.md §Step 1]

---

## 2. Models

- [ ] CHK004 - Are all required `GroupModel` fields (`id`, `name`, `imageUrl`, `members`, `membersEmails`, `admins`, `lastMessage`, `lastMessageTime`, `createdAt`) specified with Dart types and nullability? [Completeness, Spec §FR-014, data-model.md §GroupModel]
- [ ] CHK005 - Are all required `GroupMessageModel` fields (`id`, `senderId`, `senderEmail`, `text`, `createdAt`) specified with types and nullability? [Completeness, Spec §FR-015, data-model.md §GroupMessageModel]
- [ ] CHK006 - Is the Firestore `Timestamp` ↔ Dart `DateTime` conversion behavior documented for the nullable date fields (`lastMessageTime`, `createdAt`)? [Clarity, data-model.md §GroupModel]
- [ ] CHK007 - Is the `fromFirestore` factory requirement specified, including the `{'id': id, ...data}` merge pattern that prevents the `id` field from being missing after deserialization? [Clarity, plan.md §Step 2]
- [ ] CHK008 - Is `imageUrl` specified to default to an empty string `''` (not null) when no image is set, making the field non-nullable? [Clarity, Spec §Assumptions, data-model.md §groups collection]
- [ ] CHK009 - Is the json_serializable `@JsonKey(fromJson:..., toJson:...)` annotation requirement documented for Timestamp fields to avoid default serialization errors? [Completeness, plan.md §Step 2-3]

---

## 3. Remote Data Source

- [ ] CHK010 - Is the abstract class + `Impl` suffix pattern required for `GroupsRemoteDataSource`, consistent with `ChatsRemoteDataSource`? [Consistency, plan.md §Step 4]
- [ ] CHK011 - Is the constraint to use `DataBaseService` for all reads and writes — with `FirebaseFirestore.instance` permitted only for document ID generation — clearly stated? [Clarity, Spec §Assumptions, plan.md §Step 4]
- [ ] CHK012 - Is the `arrayContains: currentUserId` query requirement for `getGroups` documented, as this is the only way Firestore can filter by membership? [Completeness, plan.md §Step 4, research.md]
- [ ] CHK013 - Is the `orderBy('createdAt', descending: false)` requirement for `getGroupMessages` documented so messages appear oldest-first? [Completeness, plan.md §Step 4, Spec Clarification §Session 2026-05-04]
- [ ] CHK014 - Is the two-write strategy in `sendGroupMessage` (write message document, then update group's `lastMessage` + `lastMessageTime`) documented with rationale? [Completeness, plan.md §Step 4, research.md]
- [ ] CHK015 - Is it specified that the group document update in `sendGroupMessage` uses partial update (`merge: true`) to preserve fields like `name`, `members`, and `admins`? [Clarity, plan.md §Step 4, research.md]

---

## 4. Repository

- [ ] CHK016 - Is the thin delegation pattern (no business logic in repository, only delegates to data source) explicitly required? [Completeness, plan.md §Step 5]
- [ ] CHK017 - Are all four repository method signatures (`getGroups`, `createGroup`, `getGroupMessages`, `sendGroupMessage`) consistent between the abstract data source and repository interfaces? [Consistency, data-model.md, plan.md §Step 4-5]

---

## 5. GroupsCubit

- [ ] CHK018 - Is the double-subscription guard (`_isListeningToGroups` flag) requirement documented to prevent redundant Firestore stream subscriptions? [Completeness, plan.md §Step 6, plan.md §Pitfalls]
- [ ] CHK019 - Are all five states (`initial`, `loading`, `loaded`, `empty`, `error`) specified with their exact trigger conditions for `GroupsState`? [Completeness, data-model.md §GroupsState]
- [ ] CHK020 - Is the `StreamSubscription.cancel()` call requirement in the overridden `close()` method documented to prevent stream leaks? [Completeness, plan.md §Step 6]
- [ ] CHK021 - Is the distinction between `loaded` (non-empty list) and `empty` (list exists but has zero items) clearly specified? [Clarity, data-model.md §GroupsState]
- [ ] CHK022 - Is it specified that `GroupsCubit` depends only on `GroupsRepo` (not `GroupsRemoteDataSource` directly), respecting the data → domain layer boundary? [Completeness, plan.md §Step 9]

---

## 6. CreateGroupCubit

- [ ] CHK023 - Is it explicitly specified that `CreateGroupCubit` uses a completely separate Freezed state class from `GroupsCubit`, ensuring creation loading never replaces the groups list? [Completeness, Spec §FR-011, plan.md §Step 7]
- [ ] CHK024 - Are all four `CreateGroupState` variants (`initial`, `loading`, `success`, `error`) documented with their trigger conditions? [Completeness, data-model.md §CreateGroupState]
- [ ] CHK025 - Is the requirement that `CreateGroupCubit` does NOT interact with or affect `GroupsState` explicitly stated? [Clarity, Spec §FR-011]

---

## 7. SelectedGroupChatCubit

- [ ] CHK026 - Is the requirement for an independent `SelectedGroupChatCubit` separate from `GroupsCubit` explicitly stated, so message state never bleeds into the group list? [Completeness, Spec §FR-012, plan.md §Step 8]
- [ ] CHK027 - Is the `sendGroupMessage` behavior specified — that it does NOT emit `loading`/`success` states, relying on the real-time stream to deliver the new message automatically? [Clarity, plan.md research.md]
- [ ] CHK028 - Are all five `SelectedGroupChatState` variants (`initial`, `loading`, `loaded`, `empty`, `error`) documented? [Completeness, data-model.md §SelectedGroupChatState]
- [ ] CHK029 - Is the `StreamSubscription.cancel()` in `close()` requirement documented for `SelectedGroupChatCubit` as well, not just `GroupsCubit`? [Completeness, plan.md §Step 8]

---

## 8. GetIt Registration

- [ ] CHK030 - Is it specified that data sources and repositories use `registerLazySingleton` while Cubits use `registerFactory` (to ensure a fresh instance per screen)? [Completeness, plan.md §Step 9]
- [ ] CHK031 - Is the complete dependency resolution chain (`DataBaseService` → `GroupsRemoteDataSource` → `GroupsRepo` → Cubits) documented for the new `_initGroups()` function? [Clarity, plan.md §Step 9]
- [ ] CHK032 - Is it specified that all three Cubits (`GroupsCubit`, `CreateGroupCubit`, `SelectedGroupChatCubit`) are registered via `registerFactory`? [Completeness, plan.md §Step 9]

---

## 9. Groups List UI

- [ ] CHK033 - Is the `BlocProvider<GroupsCubit>` scope requirement (provided at the screen level, not inside the body widget) specified to ensure correct lifecycle? [Completeness, plan.md §Step 11]
- [ ] CHK034 - Is the `initState` requirement (calling `getGroups` from inside the body's `initState`) documented to trigger the first load at the correct lifecycle point? [Completeness, plan.md §Step 11]
- [ ] CHK035 - Are all four builder state branches (`loading`, `empty`, `loaded`, `error`) required in `GroupsBlocConsumer`? [Completeness, plan.md §Step 11]
- [ ] CHK036 - Is the empty state message requirement (`context.translate(LangKeys.noGroupsYet)`) explicitly tied to `FR-007`? [Completeness, Spec §FR-007, plan.md §Step 10]

---

## 10. Create Group UI

- [ ] CHK037 - Is it specified that `CreateGroupCubit` is provided inside the bottom sheet widget only (not at the groups screen level), preventing state leakage into the groups list? [Completeness, plan.md §Step 11, plan.md §Pitfalls]
- [ ] CHK038 - Is the `TextEditingController` disposal requirement for both the group name controller and members emails controller documented? [Completeness, plan.md §Step 11, CLAUDE.md §Build Method Discipline]
- [ ] CHK039 - Is the requirement to use `CustomField` (not `TextField`) for all input fields specified? [Completeness, plan.md §Step 11]
- [ ] CHK040 - Is the `CustomLinearButton` requirement (instead of `ElevatedButton`) specified for the create group submit action? [Completeness, plan.md §Step 11]
- [ ] CHK041 - Is the `ShowToast` requirement for both success (`groupCreatedSuccessfully`) and error notifications documented? [Completeness, Spec §FR-009, Spec §FR-010, plan.md §Step 11]
- [ ] CHK042 - Is the comma-separated email parsing requirement (split and trim before calling `createGroup`) documented to prevent raw strings being passed as a single email? [Clarity, plan.md §Step 11, plan.md §Pitfalls]

---

## 11. Selected Group Chat UI

- [ ] CHK043 - Is the `BlocProvider<SelectedGroupChatCubit>` scope (provided at the selected group chat screen level) requirement specified? [Completeness, plan.md §Step 11]
- [ ] CHK044 - Is the `initState` requirement (calling `getGroupMessages(groupId: group.id)` from the body's `initState`) documented? [Completeness, plan.md §Step 11]
- [ ] CHK045 - Is the message ordering display requirement (oldest at top, newest at bottom, auto-scroll to latest) specified in both spec and plan? [Completeness, Spec §Clarification, plan.md §Step 11]
- [ ] CHK046 - Is the sender identity display requirement (show `senderEmail` label on non-self messages) explicitly tied to `FR-005`? [Completeness, Spec §FR-005, plan.md §Step 11]
- [ ] CHK047 - Is the `TextEditingController` disposal requirement for the message input controller documented? [Completeness, plan.md §Step 11, CLAUDE.md §Build Method Discipline]
- [ ] CHK048 - Is the blank message prevention requirement (`FR-006`) specified to be enforced in the input widget before calling the Cubit? [Completeness, Spec §FR-006, plan.md §Step 11]

---

## 12. Localization

- [ ] CHK049 - Are all 10 required `LangKeys` constants (`groups`, `noGroupsYet`, `createGroup`, `groupName`, `groupCreatedSuccessfully`, `noMessagesYet`, `sendMessage`, `enterMessage`, `addMembers`, `membersEmails`) listed in the plan? [Completeness, plan.md §Step 10]
- [ ] CHK050 - Are Arabic translations required for all 10 new keys alongside English, consistent with the existing bilingual requirement? [Completeness, plan.md §Step 10, Spec §Assumptions]
- [ ] CHK051 - Is the `context.translate(LangKeys.key)` usage requirement (instead of hardcoded strings) specified for all user-visible text introduced by this feature? [Completeness, plan.md §Step 11]

---

## 13. Build Runner

- [ ] CHK052 - Is the requirement to run `build_runner` after all model and state files are created documented with the exact command and `--delete-conflicting-outputs` flag? [Completeness, plan.md §Step 12]
- [ ] CHK053 - Is it specified that both `.g.dart` (json_serializable) and `.freezed.dart` (Freezed) files must be generated before the app will compile? [Completeness, plan.md §Step 12]

---

## 14. Firestore Security Rules

- [ ] CHK054 - Is the access restriction requirement (`FR-016`: only group members can read group data and messages) testable against Firestore Security Rules? [Measurability, Spec §FR-016]
- [ ] CHK055 - Is the member-check rule — verifying `request.auth.uid` exists in the `members` array of the group document — specified clearly enough to write a Firestore rule without ambiguity? [Clarity, Spec §FR-016, data-model.md §groups collection]
- [ ] CHK056 - Is the write-access rule for messages (only members can write to the messages subcollection) documented? [Coverage, Gap — Spec §FR-016 currently specifies read restriction only; write restriction is implied but not stated]

---

## 15. Manual Testing Scenarios

- [ ] CHK057 - Does the spec define an acceptance scenario for the group list real-time update when another user sends a message (last message preview refreshes without manual navigation)? [Coverage, Spec §FR-001, Gap]
- [ ] CHK058 - Are acceptance scenarios for group creation success and failure defined independently, confirming the groups list is not disrupted during creation? [Completeness, Spec §User Story 2, FR-011]
- [ ] CHK059 - Is the two-user real-time messaging scenario (both users see each other's messages without refresh) defined with observable outcomes? [Completeness, Spec §User Story 3, Independent Test]
- [ ] CHK060 - Is the offline send failure edge case defined with a specific expected outcome (error shown, message not persisted, form preserved)? [Coverage, Spec §Edge Cases — currently listed without a resolved behavior]

---

## 16. Common Pitfalls — Requirements Coverage

- [ ] CHK061 - Is the double-subscription prevention requirement documented in the plan with sufficient clarity for an implementer to apply the `_isListeningToGroups` guard correctly? [Clarity, plan.md §Pitfalls]
- [ ] CHK062 - Is the `CreateGroupCubit` scope restriction (bottom sheet only) documented in the plan to prevent it from being mistakenly provided at the screen level? [Clarity, plan.md §Pitfalls]
- [ ] CHK063 - Is the `merge: true` setData requirement documented explicitly enough to prevent an implementer from accidentally overwriting all group fields when updating `lastMessage`? [Clarity, plan.md §Pitfalls, research.md]
- [ ] CHK064 - Is the prohibition on instantiating `TextEditingController` inside `build()` documented in the plan (beyond just `CLAUDE.md`) as it applies directly to this feature's two bottom sheet controllers and one message input controller? [Completeness, plan.md §Pitfalls, CLAUDE.md §Build Method Discipline]

---

## Notes

- Mark items complete with `[x]` as the spec/plan gaps are resolved.
- `[Gap]` items indicate requirements that exist in the plan/spec but are not explicitly documented — resolve before generating `tasks.md`.
- Items referencing `CLAUDE.md §Build Method Discipline` draw from project-wide conventions already enforced; verify they are echoed in the plan for this specific feature.
