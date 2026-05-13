# Feature Specification: Group Chats

**Feature Branch**: `001-group-chat`  
**Created**: 2026-05-04  
**Status**: Draft  
**Input**: User description: "Add GROUP CHATS to Flutter chat app using same architecture as existing single chat"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and Open Group Conversations (Priority: P1)

As a logged-in user, I want to see a list of all groups I belong to so I can quickly open any group conversation.

**Why this priority**: Without visibility into existing groups, no other group feature delivers value. This is the entry point.

**Independent Test**: A user with two group memberships opens the groups screen and sees both group names, and can tap one to enter.

**Acceptance Scenarios**:

1. **Given** a user is a member of one or more groups, **When** they navigate to the Groups screen, **Then** each group is displayed with its name and last message preview.
2. **Given** a user has no group memberships, **When** they navigate to the Groups screen, **Then** a clear empty-state message is shown with an option to create a group.
3. **Given** a user is on the Groups screen, **When** they tap a group card, **Then** they are taken to that group's chat and see the message history.

---

### User Story 2 - Create a New Group (Priority: P1)

As a logged-in user, I want to create a new group by providing a name and selecting other members so I can start a multi-person conversation.

**Why this priority**: Creating groups is the prerequisite for all group messaging. Without it, the feature has no content.

**Independent Test**: A user fills in a group name and provides at least one member email, taps Create, and the group appears in their groups list.

**Acceptance Scenarios**:

1. **Given** a user is on the Groups screen, **When** they tap the "Create Group" action and submit a valid name with at least one member email, **Then** the group is created and the user is returned to the updated groups list.
2. **Given** a user attempts to create a group with an empty name, **When** they submit the form, **Then** a validation message is shown and no group is created.
3. **Given** group creation succeeds, **When** the user returns to the groups list, **Then** the new group appears immediately.
4. **Given** group creation fails (network error), **When** the error occurs, **Then** an error notification is shown and the form remains open.

---

### User Story 3 - Send and Receive Messages in a Group (Priority: P1)

As a group member, I want to send text messages to the group and see messages from all other members in real time.

**Why this priority**: This is the core value proposition of group chat — without it the feature is incomplete.

**Independent Test**: Two users in the same group each send a message; both see both messages in chronological order (oldest at top, newest at bottom) with sender identification.

**Acceptance Scenarios**:

1. **Given** a user is inside a group chat, **When** they type a message and send it, **Then** the message appears in the conversation immediately attributed to them.
2. **Given** another member sends a message to the group, **When** the current user has the chat open, **Then** the new message appears without requiring a page refresh.
3. **Given** a group has no messages, **When** a user opens it, **Then** a clear empty-state message is shown.
4. **Given** a user attempts to send an empty message, **When** they tap send, **Then** the message is not sent.

---

### Edge Cases

- What happens when a user is removed from a group after they already have it open?
- What if two users create groups simultaneously with the same name? → Allowed — duplicate names are permitted; each group has a unique ID regardless of name.
- How does the system behave when the device goes offline while a message is being sent?
- What happens when a member email provided during group creation does not correspond to any registered user? → Emails are stored as-is; no validation is performed against registered users.

## Clarifications

### Session 2026-05-04

- Q: Should reading group messages and group data be restricted to group members only? → A: Yes — only group members can read the group's messages and metadata; non-members are denied access.
- Q: If a member email entered during group creation doesn't match a registered user, what should the system do? → A: Store the email as-is; no pre-validation against registered users — the group is created with whatever emails were entered.
- Q: Should the groups list update in real time (streaming) or load once? → A: Real-time stream — last-message previews and newly joined groups appear automatically without manual refresh.
- Q: How should messages be ordered in the group chat view? → A: Oldest at top, newest at bottom — standard chat order; new messages append at the bottom and the view scrolls down.
- Q: Are duplicate group names allowed? → A: Yes — group names are display labels only; uniqueness is not enforced.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a real-time streaming list of all groups the current user is a member of, ordered by most recent activity — updates (new messages, new groups) appear automatically without manual refresh.
- **FR-002**: System MUST allow a user to create a group by providing a name and one or more member email addresses.
- **FR-003**: The creating user MUST automatically become an admin and member of the newly created group.
- **FR-004**: System MUST stream group messages in real time so all members see new messages without manual refresh.
- **FR-005**: System MUST display each message's sender identity (email) within the group conversation.
- **FR-006**: System MUST prevent sending blank messages.
- **FR-007**: System MUST show a clear empty state when a user has no groups.
- **FR-008**: System MUST show a clear empty state when a group has no messages yet.
- **FR-009**: System MUST show a success notification after a group is created successfully.
- **FR-010**: System MUST show an error notification if group creation fails.
- **FR-011**: Group list loading and group creation loading MUST be independent — creating a group must not block or replace the groups list display.
- **FR-012**: Group messages loading MUST be independent of the groups list state.
- **FR-013**: The groups list MUST update (show the new group) immediately after successful creation without requiring a full page reload.
- **FR-014**: Each group MUST store: name, image URL (optional), member user IDs, member emails, admin user IDs, last message text, last message timestamp, and creation timestamp.
- **FR-015**: Each group message MUST store: sender user ID, sender email, message text, and creation timestamp.
- **FR-016**: Access to group data and messages MUST be restricted to current members of that group only — non-members must be denied read access.

### Key Entities

- **Group**: A named conversation channel with a set of member users; has one or more admins; tracks the last message for preview.
- **Group Message**: A single text message sent within a group, attributed to a specific member.
- **Group Member**: A user participating in a group, identified by their user ID and email.
- **Group Admin**: A member with elevated privileges (initially the creator); stored as a subset of members.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a group and send their first message within 60 seconds of tapping "Create Group".
- **SC-002**: Messages from other group members appear on the recipient's screen within 3 seconds under normal network conditions.
- **SC-003**: The groups list screen loads and displays existing groups within 2 seconds of navigation.
- **SC-004**: Group creation fails gracefully — an error is visible within 5 seconds if the network request does not complete.
- **SC-005**: 100% of sent messages include sender identification visible to all group members.

## Assumptions

- Users are already authenticated — this feature does not introduce a new auth flow.
- Member selection during group creation is done by entering email addresses manually (no in-app user search UI in scope for this version).
- Group image upload is out of scope for this version (imageUrl field stored as empty string by default).
- The app already has a working navigation stack — routing to the group chat screen will follow the existing navigation pattern.
- Only text messages are supported; no media, files, or reactions in scope.
- There is no group member management UI in scope (no add/remove members post-creation).
- The existing `DataBaseService` abstraction covers all Firestore read/write operations needed; direct Firestore SDK usage is limited to document ID generation only.
- Localization (English and Arabic) is required for all user-visible strings introduced by this feature.
