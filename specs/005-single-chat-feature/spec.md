# Feature Specification: Single Chat Feature

**Feature Branch**: `005-single-chat-feature`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "Complete single chat feature for one-to-one messaging with text, image, and file messages, real-time updates, search, edit/delete messages, and pull to refresh."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View All Single Chats (Priority: P1)

A user opens the chat home screen and sees a list of all one-to-one conversations where they are a participant. Each chat card displays the friend's email/name, the last message preview, and the time of the last message. The list updates in real time as new messages arrive.

**Why this priority**: The chats list is the entry point for the entire feature. Without it, users cannot access any conversation.

**Independent Test**: Log in as a user who has existing chats; verify the chats list displays all conversations with correct friend info, last message, and timestamp.

**Acceptance Scenarios**:

1. **Given** a user is logged in and has existing chats, **When** they navigate to the chat home screen, **Then** they see all chats where their uid exists in the `users` array, ordered by `lastMessageTime` descending.
2. **Given** a user has no chats, **When** they navigate to the chat home screen, **Then** they see an empty state message.
3. **Given** a new message arrives in any chat, **When** the user is on the chat home screen, **Then** the chat list updates in real time with the new last message.

---

### User Story 2 - Create a New Single Chat (Priority: P1)

A user taps the floating action button to open a bottom sheet, enters a friend's email address, and creates a new chat. The system validates the email, checks that the user is not chatting with themselves, prevents duplicate chats, and verifies the friend exists in the users collection.

**Why this priority**: Users need to initiate conversations. This is a core entry action alongside viewing chats.

**Independent Test**: Enter a valid friend email, create the chat, verify the chat appears in both users' chat lists.

**Acceptance Scenarios**:

1. **Given** a user enters a valid friend email that exists in the system, **When** they tap create, **Then** a new chat document is created with a stable ID and the chat appears in the list.
2. **Given** a user enters their own email, **When** they tap create, **Then** an error message is shown: "Cannot create chat with yourself."
3. **Given** a chat already exists between the two users, **When** the user tries to create another, **Then** an error message is shown: "Chat already exists."
4. **Given** the entered email does not belong to any registered user, **When** they tap create, **Then** an error message is shown: "No user found with this email."
5. **Given** the email field is empty or invalid, **When** they tap create, **Then** a validation error is shown.

---

### User Story 3 - Send Text Messages (Priority: P1)

A user opens a selected chat and sends a text message. The message appears immediately in the conversation, is saved to Firestore under the chat's messages subcollection, and the chat document's `lastMessage` and `lastMessageTime` fields are updated.

**Why this priority**: Text messaging is the fundamental chat action.

**Independent Test**: Open a chat, send a text, verify message appears in real time on both sides and lastMessage updates.

**Acceptance Scenarios**:

1. **Given** a user is in a selected chat, **When** they type a message and tap send, **Then** the message is saved to `chats/{chatId}/messages/{messageId}` and appears in the conversation.
2. **Given** a message is sent, **When** it is saved, **Then** the parent chat document's `lastMessage`, `lastMessageType`, and `lastMessageTime` are updated.
3. **Given** the message input is empty, **When** the user taps send, **Then** nothing happens (send button is disabled or ignored).

---

### User Story 4 - Send Image Messages (Priority: P2)

A user taps an attachment icon, selects an image from the device, and sends it. The image is uploaded to Supabase Storage and a message with the image URL is saved to Firestore.

**Why this priority**: Image sharing is the most common media type after text.

**Independent Test**: Select an image, send it, verify it appears as an image message with a preview in the chat.

**Acceptance Scenarios**:

1. **Given** a user selects an image from the gallery, **When** they send it, **Then** the image is uploaded to Supabase Storage and an image message appears in the chat.
2. **Given** an image is uploading, **When** the upload is in progress, **Then** a loading indicator is shown.
3. **Given** the upload fails, **When** the error occurs, **Then** the user sees an error toast.

---

### User Story 5 - Send File Messages (Priority: P2)

A user selects a file from the device and sends it. The file is uploaded to Supabase Storage and a message with the file URL, name, and storage path is saved to Firestore.

**Why this priority**: File sharing completes the media capabilities of the chat.

**Independent Test**: Select a PDF file, send it, verify the file message appears with the file name.

**Acceptance Scenarios**:

1. **Given** a user selects a file, **When** they send it, **Then** the file is uploaded and a file message appears showing the file name.
2. **Given** the file upload completes, **Then** the chat document's `lastMessage` is updated to reflect the file name or type.

---

### User Story 6 - View Messages in Real Time (Priority: P1)

When a user is in a selected chat, incoming messages from the other participant appear automatically without refreshing.

**Why this priority**: Real-time messaging is essential for a chat app.

**Independent Test**: Open the same chat on two devices; send a message from one and verify it appears on the other in real time.

**Acceptance Scenarios**:

1. **Given** two users are in the same chat, **When** one sends a message, **Then** the other sees it appear in real time via a Firestore stream.

---

### User Story 7 - Delete Own Messages (Priority: P3)

A user can long-press a message they sent to select it, then tap a delete action. The message is removed (or marked as deleted). If the message had a media file, the storage file is also removed.

**Why this priority**: Users need control over their own messages for privacy and corrections.

**Independent Test**: Send a message, long-press it, delete it, verify it disappears and storage file is removed if applicable.

**Acceptance Scenarios**:

1. **Given** a user long-presses their own message, **When** they confirm deletion, **Then** the message is deleted from Firestore and any associated storage file is removed.
2. **Given** a user tries to delete another user's message, **Then** the delete option is not available.

---

### User Story 8 - Edit Own Text Messages (Priority: P3)

A user can edit a text message they previously sent. Only text messages can be edited. The message's `isEdited` flag is set to true and `updatedAt` is updated.

**Why this priority**: Editing corrects typos without needing to delete and resend.

**Independent Test**: Send a text, edit it, verify the updated text and "edited" indicator appear.

**Acceptance Scenarios**:

1. **Given** a user selects their own text message, **When** they choose edit and submit new text, **Then** the message text is updated and `isEdited` becomes true.
2. **Given** a user selects an image or file message, **Then** the edit option is not available (only delete).

---

### User Story 9 - Search Chats (Priority: P2)

A user can search the chats list by friend email or last message content. Search results replace the current list. Clearing the search restores the full chat list.

**Why this priority**: As chats grow, finding specific conversations becomes important.

**Independent Test**: Search by a friend's email, verify matching chats appear; clear search, verify full list returns.

**Acceptance Scenarios**:

1. **Given** a user types in the search field, **When** results match, **Then** the chats list shows only matching chats.
2. **Given** no results match the search, **Then** an empty search state is shown.
3. **Given** the user clears the search, **Then** the full chats list is restored.

---

### User Story 10 - Pull to Refresh (Priority: P3)

A user can pull down on the chats list to refresh it, re-fetching the latest data.

**Why this priority**: Provides a manual fallback for data freshness.

**Independent Test**: Pull down on the chats list, verify the list reloads.

**Acceptance Scenarios**:

1. **Given** a user pulls down on the chats list, **When** the refresh completes, **Then** the chats list shows the latest data.

---

### Edge Cases

- What happens when a user sends a message while offline? The message should fail with an error toast; retry is not in scope for this feature.
- What happens if the friend's account is deleted? The chat still shows but the friend info may be stale.
- What if two messages arrive at the exact same timestamp? Order by `createdAt` timestamp; use document ID as tiebreaker.
- What happens when the user tries to edit a deleted message? This should not be possible as deleted messages are removed from Firestore.
- What if the stable chat ID generation produces the same ID for different user pairs? Impossible by design — sorted UIDs joined with underscore guarantees uniqueness.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display all single chats where the current user's UID is in the `users` array, ordered by `lastMessageTime` descending.
- **FR-002**: System MUST allow creating a new chat by entering a friend's email address.
- **FR-003**: System MUST prevent creating a chat with the current user's own email.
- **FR-004**: System MUST prevent duplicate chats between the same two users by using a stable chat ID (sorted UIDs joined with underscore).
- **FR-005**: System MUST verify the friend's email exists in the `users` collection before creating a chat.
- **FR-006**: System MUST allow sending text messages in a selected chat.
- **FR-007**: System MUST allow sending image messages by uploading to Supabase Storage and saving the URL in Firestore.
- **FR-008**: System MUST allow sending file messages by uploading to Supabase Storage and saving the URL, file name, and storage path in Firestore.
- **FR-009**: System MUST update `lastMessage`, `lastMessageType`, and `lastMessageTime` on the chat document after each message is sent.
- **FR-010**: System MUST stream messages in real time using Firestore snapshots.
- **FR-011**: System MUST allow deleting own messages, including removing associated storage files.
- **FR-012**: System MUST allow editing own text messages only, setting `isEdited` to true and updating `updatedAt`.
- **FR-013**: System MUST support searching chats by friend email or last message content (client-side filtering).
- **FR-014**: System MUST support pull-to-refresh on the chats list.
- **FR-015**: System MUST use separate cubits for chats list, chat creation, and selected chat messages.

### Key Entities

- **Chat**: A one-to-one conversation. Attributes: `id` (stable sorted UID pair), `users` (list of 2 UIDs), `usersEmails` (list of 2 emails), `lastMessage`, `lastMessageType`, `lastMessageTime`, `createdAt`, `updatedAt`.
- **ChatMessage**: A single message within a chat. Attributes: `id`, `chatId`, `senderId`, `senderEmail`, `receiverId`, `text`, `type` (text/image/file), `mediaUrl`, `storagePath`, `fileName`, `createdAt`, `updatedAt`, `isEdited`, `isDeleted`.
- **CurrentUser**: The authenticated user, resolved from SharedPreferences via `getCurrentUser()`. Provides `uid`, `name`, `email`, `photoUrl`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their chats list within 2 seconds of navigating to the chat home screen.
- **SC-002**: A sent text message is visible to both participants within 2 seconds under normal network conditions.
- **SC-003**: Users can create a new chat and see it in their list within 3 seconds.
- **SC-004**: Search results appear within 1 second of the user typing a query.
- **SC-005**: 95% of message send operations complete successfully on first attempt.
- **SC-006**: Image and file messages display in the chat within 5 seconds of upload completion.
- **SC-007**: Users can edit or delete their own messages and see the change reflected within 2 seconds.

## Assumptions

- The app uses Firebase Auth for authentication and the current user is accessible via `getCurrentUser()` from SharedPreferences.
- Firestore is the primary data store for chat and message documents.
- Supabase Storage is used for binary files (images, files) — not Firestore.
- The `DataBaseService` abstraction is used for all Firestore operations (not `FirebaseFirestore.instance` directly).
- The `SupabaseStorageService` is used for all storage operations.
- Search is performed client-side by filtering the already-loaded chats list.
- Pull-to-refresh re-subscribes to the Firestore stream.
- Audio messages are out of scope for this feature (handled separately if needed).
- Push notifications are out of scope for this feature.
- The feature targets Android and iOS.
- Freezed with build_runner is used for state classes and models (per existing project patterns with json_serializable).
- Messages are loaded as a real-time stream, not paginated (initial implementation).
