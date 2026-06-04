# Research: Group Chats

**Feature**: `001-group-chat`  
**Date**: 2026-05-04

---

## Decision: Firestore Query for Group Membership

**Decision**: Use `query.where('members', arrayContains: currentUserId)` in `getGroups`.

**Rationale**: Firestore supports `arrayContains` for filtering documents where a list field contains a given value. This is the idiomatic, index-friendly way to query "groups I'm in". It works directly with the `collectionStream` queryBuilder in `DataBaseService`.

**Alternatives considered**: Storing a top-level user-to-groups index in a separate collection — rejected because it adds write complexity (denormalization) without benefit at this scale.

---

## Decision: Document ID Generation

**Decision**: Use `FirebaseFirestore.instance.collection(groupsCollection).doc().id` to generate Firestore document IDs before writing.

**Rationale**: `DataBaseService.setData` takes a `path` string, so the ID must be known before the write. Firestore's SDK generates a unique, collision-resistant ID client-side without a network round-trip. This is the only acceptable direct SDK usage (as agreed in the spec).

**Alternatives considered**: Using server-generated IDs via `addDocument` — not available through the current `DataBaseService` abstraction; would require a new method.

---

## Decision: Updating `lastMessage` on Group Document

**Decision**: After writing a message, call `setData` on the group document with `{lastMessage: text, lastMessageTime: Timestamp.now()}`. Since `merge: true` is the default, existing group fields (name, members, etc.) are preserved.

**Rationale**: Two separate `setData` calls (message write + group update) are simpler and safer than a Firestore transaction at this scale. Message ordering is by `createdAt` on the messages subcollection, not on the group document, so a brief inconsistency in `lastMessage` has no functional impact on message display.

**Alternatives considered**: Firestore transactions — adds complexity; only needed if consistency between two writes is strictly required by a business rule (it is not here).

---

## Decision: Message Ordering

**Decision**: `orderBy('createdAt', descending: false)` in the `getGroupMessages` queryBuilder.

**Rationale**: Standard chat convention (oldest at top, newest at bottom). Confirmed in clarification session 2026-05-04.

**Alternatives considered**: Client-side sort — rejected because `orderBy` is server-side and more efficient.

---

## Decision: No Member Email Validation

**Decision**: Member emails entered during group creation are stored as-is; no lookup against registered users.

**Rationale**: Confirmed in clarification session 2026-05-04. Avoids extra Firestore read per email, reduces latency, and avoids leaking user-existence information.

---

## Decision: Groups List is a Real-Time Stream

**Decision**: `GroupsCubit.getGroups` uses `collectionStream`, not `getCollection`, so the list updates automatically.

**Rationale**: Confirmed in clarification session 2026-05-04. Consistent with how `ChatsCubit` works for single chats.

---

## Decision: Separate Cubits for Separate Concerns

**Decision**: Three Cubits — `GroupsCubit`, `CreateGroupCubit`, `SelectedGroupChatCubit` — each with independent state.

**Rationale**: Prevents loading-state pollution: creating a group must not replace the loaded group list with a loading spinner. This follows the existing pattern (separate `ChatsCubit` and `CreateChatCubit`).

---

## Decision: `SelectedGroupChatCubit.sendGroupMessage` Does Not Emit State

**Decision**: `sendGroupMessage` calls the repo and returns; it does not emit a loading/success state.

**Rationale**: The real-time message stream (from `getGroupMessages`) will automatically deliver the new message. Emitting a success state would be redundant and could cause a brief UI flicker (loaded → something → loaded).

**Exception**: If the send fails, the error should be surfaced — either via a `ShowToast` call directly in the UI or by emitting a lightweight error state. A simple try/catch with `ShowToast` in the widget is sufficient for now.
