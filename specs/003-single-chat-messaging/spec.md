# Feature Specification: Single Chat Messaging

**Feature Branch**: `003-single-chat-messaging`  
**Created**: 2026-05-06  
**Status**: Draft  
**Input**: User description: "in the folder @lib\features\single_chat i create the ui and i want u to help me to create the functionality of the single chat, send message, receive message, send image, send audio, send file, i use firestore and supabase to save the files like image, audio"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Send and Receive Text Messages (Priority: P1)

A user opens an existing one-on-one chat conversation and can send text messages to another user. Messages appear in real time on both sides — the sender sees their message immediately, and the recipient sees it arrive without needing to refresh. Messages are ordered chronologically and each shows the sender's name/avatar, the message body, and the time it was sent.

**Why this priority**: Text messaging is the core feature — all other message types build on top of this foundation. Without it, the chat screen has no value.

**Independent Test**: Open a chat between two accounts, send a text from Account A, verify it appears on Account B in real time.

**Acceptance Scenarios**:

1. **Given** a user is on a single chat screen, **When** they type a message and tap Send, **Then** the message appears in the chat immediately with a "sent" indicator.
2. **Given** another user is on the same chat screen, **When** a new message arrives, **Then** the message appears in real time without requiring a manual refresh.
3. **Given** a user sends a message, **When** the connection is temporarily lost, **Then** the message shows a "failed" indicator and the user can retry.
4. **Given** a chat has many messages, **When** the user opens the chat, **Then** they see the most recent messages first and can scroll up to load older ones.

---

### User Story 2 - Send and Receive Images (Priority: P2)

A user can select an image from their device gallery or take a new photo and send it in the chat. The image is uploaded to storage, and a thumbnail preview is displayed inline in the message thread. The recipient sees the image appear in real time and can tap it to view it full-screen.

**Why this priority**: Image sharing is the most common media type used in chat apps and is essential after text messaging.

**Independent Test**: Send an image from Account A; verify Account B sees the image thumbnail inline and can open it full-screen.

**Acceptance Scenarios**:

1. **Given** a user taps the attachment button and selects "Image", **When** they choose an image from the gallery, **Then** the image is uploaded and a thumbnail appears in the chat.
2. **Given** an image is being uploaded, **When** the upload is in progress, **Then** a loading/progress indicator is shown in place of the image.
3. **Given** an image message is received, **When** the recipient taps the thumbnail, **Then** the full-resolution image is shown in a full-screen viewer.
4. **Given** an image upload fails, **When** the error occurs, **Then** the user is notified and given the option to retry.

---

### User Story 3 - Send and Receive Audio Messages (Priority: P3)

A user can record a voice message directly from within the chat and send it. The recipient sees an audio player in the message thread with play/pause controls and a duration indicator. The audio file is stored in the cloud and streamed on playback.

**Why this priority**: Voice messages add expressive communication and are commonly expected in modern messaging apps.

**Independent Test**: Record and send a voice note from Account A; verify Account B sees a playable audio message with correct duration.

**Acceptance Scenarios**:

1. **Given** a user holds the record button, **When** they release it, **Then** the audio recording stops, is uploaded, and appears as a playable message in the chat.
2. **Given** an audio message exists in the chat, **When** the recipient taps Play, **Then** the audio plays back correctly with progress indication.
3. **Given** a recording is in progress, **When** the user slides to cancel, **Then** the recording is discarded and no message is sent.

---

### User Story 4 - Send and Receive Files (Priority: P4)

A user can attach a file (PDF, document, etc.) from their device and send it in the chat. The file is uploaded to storage and appears as a file attachment message showing the file name, type icon, and size. The recipient can tap to download and open the file.

**Why this priority**: File sharing completes the full media suite, enabling document exchange within conversations.

**Independent Test**: Send a PDF from Account A; verify Account B sees the file attachment with name and size, and can download it.

**Acceptance Scenarios**:

1. **Given** a user taps the attachment button and selects "File", **When** they choose a file from the device, **Then** the file is uploaded and appears as an attachment card in the chat.
2. **Given** a file message is received, **When** the recipient taps the download icon, **Then** the file is saved to the device and can be opened.
3. **Given** a file exceeds the maximum allowed size, **When** the user tries to send it, **Then** an error message is shown before upload begins.

---

### Edge Cases

- What happens when the user sends a message while offline? Show a pending/failed indicator; allow retry when connectivity is restored.
- How does the system handle very large files or images? Enforce a maximum file size (assumed 25 MB) and show an error.
- What happens if the other user has been deleted or blocked? Show appropriate messaging and disable the input field.
- What if two messages arrive at the exact same timestamp? Order by server timestamp; use a secondary sort key (document ID) to break ties.
- What happens when the app is in the background and a new message arrives? A push notification should be shown (out of scope for this feature, but the data model must support it).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow a user to send a plain text message to another user in a one-on-one chat.
- **FR-002**: System MUST deliver incoming messages to the recipient in real time without requiring a manual refresh.
- **FR-003**: System MUST allow a user to select an image from the device gallery and send it as a chat message.
- **FR-004**: System MUST upload image files to cloud storage and display a thumbnail preview inline in the message thread.
- **FR-005**: System MUST allow a user to record and send a voice/audio message directly from the chat input area.
- **FR-006**: System MUST upload audio files to cloud storage and display a playable audio player in the message thread.
- **FR-007**: System MUST allow a user to select a file from the device and send it as a chat attachment.
- **FR-008**: System MUST upload files to cloud storage and display the file name, type, and size as an attachment card.
- **FR-009**: System MUST show a send-in-progress indicator while any media (image, audio, file) is being uploaded.
- **FR-010**: System MUST show an error indicator when a message or media upload fails, with a retry option.
- **FR-011**: System MUST load the most recent messages when the chat screen opens, with the ability to paginate older messages by scrolling up.
- **FR-012**: System MUST persist all messages (text, image, audio, file) in Firestore under the relevant chat document.
- **FR-013**: System MUST store binary media files (images, audio, files) in Supabase Storage, saving only the download URL in Firestore.
- **FR-014**: System MUST display each message with the sender's identifier, content, and timestamp.
- **FR-015**: System MUST enforce a maximum attachment size (25 MB) and reject oversized files before upload.

### Key Entities

- **Message**: Represents a single message in a conversation. Key attributes: `id`, `chatId`, `senderId`, `type` (text | image | audio | file), `content` (text body or storage URL), `fileName` (for file/audio), `fileSize`, `duration` (audio), `sentAt` (timestamp), `status` (sending | sent | failed).
- **Chat**: Represents a one-on-one conversation. Key attributes: `id`, `participants` (list of user IDs), `lastMessage`, `lastMessageTime`.
- **CurrentUser**: The authenticated user sending/receiving messages — resolved from app-level state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A text message is visible to both the sender and recipient within 2 seconds under normal network conditions.
- **SC-002**: An image thumbnail appears in the chat within 5 seconds of the user selecting the image (on a standard mobile connection).
- **SC-003**: Audio playback starts within 2 seconds of the user tapping Play.
- **SC-004**: 95% of send operations complete successfully on first attempt under normal network conditions.
- **SC-005**: The chat screen loads the most recent 20 messages in under 3 seconds on app open.
- **SC-006**: Oversized attachments (>25 MB) are rejected instantly with a user-visible error before any upload begins.

## Assumptions

- The UI for the single chat screen already exists in `lib/features/single_chat/presentation/` and will not be redesigned — only the business logic and data layer are being added.
- A `ChatModel` and chat ID are already available when the user navigates to the single chat screen (passed as route arguments).
- User authentication is handled by the existing `AuthCubit`/`AuthService` and the current user's ID is available globally via `AppCubit`.
- Firestore is the primary data store for message metadata; Supabase Storage is used exclusively for binary media files.
- Real-time message delivery is achieved via Firestore's `snapshots()` stream — no additional push notification integration is required for this feature.
- Audio recording uses the device microphone; the app already has (or will request) the necessary permissions.
- Pagination loads 20 messages per page; older messages load on scroll-up.
- Files of all types (PDF, DOCX, etc.) are supported up to 25 MB.
- The feature targets Android and iOS; web is out of scope.
- No Freezed or code generation — Dart 3+ sealed classes and native patterns will be used for state management per project rules.
