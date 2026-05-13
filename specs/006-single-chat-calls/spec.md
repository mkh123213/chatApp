# Feature Specification: Single Chat Calls

**Feature Branch**: `006-single-chat-calls`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "Add one-to-one audio/video calls between two users inside the existing selected single chat screen"

## Clarifications

### Session 2026-05-08

- Q: Which call provider should be used for real audio/video streaming? → A: Agora (agora_rtc_engine Flutter SDK)
- Q: If the caller cancels before the receiver answers, what should the call status become? → A: "ended" with zero duration (caller actively terminated)
- Q: Where should the incoming call listener be active? → A: Global at MainScreen level — overlay/dialog shown from any screen in the app
- Q: Should call duration be measured from acceptedAt or startedAt? → A: From acceptedAt — duration = actual connected/talk time only
- Q: What are the exact route names for CallScreen and CallsHistoryScreen? → A: `callScreen` and `callsHistoryScreen` (camelCase convention)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start an Audio Call from Chat (Priority: P1)

A user is in an active single chat conversation and wants to make an audio call to the other participant. They tap the audio call icon in the chat header, the system verifies no duplicate active call exists and that the user is not calling themselves, creates a call record, and navigates the caller to the call screen showing the ringing state.

**Why this priority**: Initiating a call is the foundational action — without it, no other call functionality is usable.

**Independent Test**: Can be fully tested by opening an existing chat, tapping the audio call icon, verifying a call record is created, and confirming the caller sees the call screen with ringing status.

**Acceptance Scenarios**:

1. **Given** a user is viewing a selected single chat, **When** they tap the audio call icon, **Then** a call record is created with status "ringing" and the caller is navigated to the call screen showing friend avatar, name, and ringing status.
2. **Given** a user is viewing a selected single chat, **When** they tap the video call icon, **Then** a call record is created with type "video", status "ringing", and the caller is navigated to the call screen with video controls visible.
3. **Given** a user attempts to start a call with themselves (same user on both sides), **When** they tap a call icon, **Then** the system prevents the call and shows an appropriate message.
4. **Given** an active or ringing call already exists between the same two users, **When** either user attempts to start another call, **Then** the system prevents the duplicate call and shows an appropriate message.

---

### User Story 2 - Receive and Respond to an Incoming Call (Priority: P1)

A user receives an incoming call notification while the app is active. They see the caller's identity and call type (audio/video), and can choose to accept or reject the call. Accepting navigates them to the call screen; rejecting updates the call status and dismisses the notification.

**Why this priority**: Without the ability to receive and respond to calls, the calling feature is one-directional and unusable for real communication.

**Independent Test**: Can be tested by having User A start a call to User B, verifying User B sees the incoming call notification with caller info, and testing both accept and reject flows.

**Acceptance Scenarios**:

1. **Given** User B has the app open, **When** User A starts a call to User B, **Then** User B sees an incoming call notification showing User A's avatar, name, and call type (audio/video).
2. **Given** User B sees an incoming call notification, **When** User B taps accept, **Then** the call status updates to "accepted" in real time and User B is navigated to the call screen.
3. **Given** User B sees an incoming call notification, **When** User B taps reject, **Then** the call status updates to "rejected" and the notification is dismissed.
4. **Given** a call is ringing and the receiver does not respond within the timeout period, **When** the timeout elapses, **Then** the call status updates to "missed".

---

### User Story 3 - Manage an Active Call (Priority: P1)

Both users are on an active call. They can see real-time call status, a timer showing call duration, and controls to mute/unmute, toggle speaker, toggle camera (for video calls), and end the call. Either participant can end the call, which updates the status and records the duration.

**Why this priority**: Active call management is essential for a usable calling experience — users must be able to control and end their calls.

**Independent Test**: Can be tested by establishing a call between two users and verifying all controls work: mute toggles audio, speaker toggles output, camera toggles video feed, end call terminates and records duration.

**Acceptance Scenarios**:

1. **Given** both users are on an active call, **When** the call is accepted, **Then** a timer starts counting the call duration and both users see real-time "connected" status.
2. **Given** a user is on an active call, **When** they tap the mute button, **Then** their microphone is muted and the button reflects the muted state.
3. **Given** a user is on an active call, **When** they tap the speaker button, **Then** the audio output toggles between earpiece and speaker.
4. **Given** a user is on an active video call, **When** they tap the camera toggle, **Then** their video feed is turned on or off.
5. **Given** a user is on an active call, **When** either user taps end call, **Then** the call status updates to "ended", the duration is recorded, and both users exit the call screen.

---

### User Story 4 - View Call History (Priority: P2)

A user wants to review past calls. They navigate to the Calls tab and see a chronological list of all their calls (made, received, missed, rejected) with caller/receiver info, call type, status, timestamp, and duration.

**Why this priority**: Call history provides value after the core calling flow is working — it is important but not blocking for the primary call experience.

**Independent Test**: Can be tested by making several calls of different types and statuses, then navigating to the Calls tab and verifying all calls appear with correct details.

**Acceptance Scenarios**:

1. **Given** a user has made and received calls, **When** they navigate to the Calls tab, **Then** they see a list of all their calls sorted by most recent first.
2. **Given** a user views call history, **When** looking at a call entry, **Then** they see the other participant's info, call type icon (audio/video), status (ended/missed/rejected), timestamp, and duration if applicable.
3. **Given** a user has no call history, **When** they navigate to the Calls tab, **Then** they see an appropriate empty state message.

---

### Edge Cases

- What happens when a user loses internet connection during an active call? The call continues on the media channel; if the connection is not restored, the call should eventually be marked as ended.
- What happens when both users try to call each other simultaneously? The system prevents duplicate active calls for the same chat — the first call created takes precedence.
- What happens when a user tries to start a call while already on another call? The system should prevent starting a new call while an active/ringing call exists for the same chat pair.
- What happens when the receiver's app is not in the foreground? For this version, incoming calls are only detected while the app is actively open. Push notification support for background calls is deferred to a future version.
- What happens when a call is ringing and the caller navigates away? The call remains in "ringing" state until the receiver responds or the timeout triggers a "missed" status.
- What happens when the caller cancels/hangs up before the receiver answers? The call status updates to "ended" with zero duration — distinct from "missed" (timeout) and "rejected" (receiver's action).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow a user to initiate an audio call from the selected single chat header.
- **FR-002**: System MUST allow a user to initiate a video call from the selected single chat header.
- **FR-003**: System MUST create a call record with all participant details and "ringing" status when a call is initiated.
- **FR-004**: System MUST prevent a user from calling themselves.
- **FR-005**: System MUST prevent duplicate active or ringing calls between the same two users.
- **FR-006**: System MUST notify the receiver of an incoming call in real time via a global overlay/dialog (visible from any screen in the app while it is active), showing caller identity and call type.
- **FR-007**: System MUST allow the receiver to accept an incoming call, updating status to "accepted".
- **FR-008**: System MUST allow the receiver to reject an incoming call, updating status to "rejected".
- **FR-009**: System MUST automatically mark a call as "missed" if the receiver does not respond within 30 seconds.
- **FR-010**: System MUST display the call screen (route: `callScreen`) with friend's avatar, name, call type, and real-time call status.
- **FR-011**: System MUST show a running timer starting from the moment the call is accepted (acceptedAt). Call duration represents actual connected talk time only.
- **FR-012**: System MUST provide mute/unmute control for the user's microphone during an active call.
- **FR-013**: System MUST provide speaker toggle control during an active call.
- **FR-014**: System MUST provide camera on/off toggle for video calls.
- **FR-015**: System MUST allow either participant to end an active call, recording the duration.
- **FR-016**: System MUST update call status in real time for both participants.
- **FR-017**: System MUST persist all call records for history retrieval.
- **FR-018**: System MUST display call history (route: `callsHistoryScreen`) in a dedicated tab showing participant info, call type, status, time, and duration.
- **FR-019**: System MUST show an empty state when no call history exists.
- **FR-020**: System MUST keep call state management fully separated from chat messaging state.
- **FR-021**: System MUST keep the call provider integration abstracted so it can be swapped without affecting call state management or UI.
- **FR-022**: All user-facing labels MUST be localized — no hardcoded text strings.

### Key Entities

- **Call**: Represents a single call between two chat participants. Key attributes: unique identifier, associated chat identifier, caller details (identity, name, email, photo), receiver details (identity, name, email, photo), call type (audio/video), status (ringing/accepted/rejected/ended/missed), timestamps (started, accepted, ended, created, updated), duration in seconds, and a media channel identifier for the call provider.
- **Call Status Lifecycle**: A call progresses through defined states — starts as "ringing", transitions to "accepted" (if receiver accepts), "rejected" (if receiver declines before accepting), "ended" (if either party terminates — including caller cancelling before answer, recorded with zero duration), or "missed" (if receiver does not respond within timeout).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can initiate a call and see the call screen within 3 seconds of tapping the call button.
- **SC-002**: The receiver sees the incoming call notification within 2 seconds of the caller initiating (while app is active).
- **SC-003**: Call status transitions (accept, reject, end) are reflected on both participants' screens within 2 seconds.
- **SC-004**: 100% of completed calls have accurate duration recorded (within 1-second tolerance).
- **SC-005**: Call history loads and displays within 3 seconds of navigating to the Calls tab.
- **SC-006**: Users can successfully complete an audio call end-to-end (start → accept → talk → end) on first attempt.
- **SC-007**: Users can successfully complete a video call end-to-end (start → accept → see video → end) on first attempt.
- **SC-008**: Duplicate call prevention works in 100% of attempts — no two simultaneous ringing/active calls between the same pair.
- **SC-009**: Self-call prevention works in 100% of attempts.
- **SC-010**: Existing chat messaging functionality remains fully operational after call feature integration.

## Assumptions

- Users have a stable internet connection sufficient for real-time audio/video streaming.
- The existing single chat feature is fully implemented and functional, including ChatModel with participant details (uid, name, email, photo URL).
- The app uses a single main screen with tabs, and a "Calls" tab already exists or will be added as part of this feature.
- Incoming call detection is global at the MainScreen level — the listener runs across all screens while the app is in the foreground. Background/push notification-based call detection is out of scope for this version.
- Agora (`agora_rtc_engine` Flutter SDK) is the chosen call provider for audio/video media streaming, integrated behind an abstraction layer so it can be swapped in the future.
- The ringing timeout before a call is marked as "missed" is 30 seconds.
- Call history is displayed for the current user only and includes all calls where they were either the caller or receiver.
- The call provider SDK integration is abstracted so it can be swapped without affecting the call state management or UI layers.
- All UI text is localized through the existing custom localization system.
- The existing chat screen structure (screen → body → bloc consumer → small widgets) is preserved; only call action buttons are added to the existing header.
