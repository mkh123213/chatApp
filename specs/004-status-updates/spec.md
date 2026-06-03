# Feature Specification: Status / Updates

**Feature Branch**: `004-status-updates`
**Created**: 2026-05-06
**Status**: Draft
**Input**: User description: "Status feature similar to WhatsApp status — image and text statuses, 24-hour expiry, viewer tracking, delete own status."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Create Image Status (Priority: P1)

A user picks an image from their gallery or camera, which is uploaded to Supabase Storage. The resulting public URL and metadata are saved in Firestore under the `statuses` collection with an expiry 24 hours from now. Other users can then see this status in the Recent Updates list.

**Why this priority**: Image status is the core, most-used feature and unblocks all viewer flows.

**Independent Test**: Can be fully tested by uploading one image and confirming it appears in the active statuses list, and delivers a visible status to other users.

**Acceptance Scenarios**:

1. **Given** a logged-in user on the Status screen, **When** they tap the add button → Gallery and pick an image, **Then** the image is uploaded to Supabase Storage and a status document is written to Firestore with `type: "image"`, `expiresAt` set to 24 hours from now, and a public `mediaUrl`.
2. **Given** the upload is in progress, **When** the upload fails, **Then** the user sees an error toast and no partial document is written to Firestore.
3. **Given** a status has been created, **When** 24 hours have passed, **Then** the status no longer appears in the active statuses list.

---

### User Story 2 — Create Text Status (Priority: P2)

A user types a message and selects a background color. The text and color are saved directly in Firestore without any media upload.

**Why this priority**: Text status is a fast creation path with no upload dependency; complements image status.

**Independent Test**: Can be tested independently by creating a text status and confirming it appears in the active statuses list with the correct text and background.

**Acceptance Scenarios**:

1. **Given** a user on the text status screen, **When** they enter text and choose a background color and tap Create, **Then** a Firestore document is written with `type: "text"`, the entered text, backgroundColor, and correct `expiresAt`.
2. **Given** the user tries to submit an empty text field, **Then** the button remains disabled or an inline error is shown.

---

### User Story 3 — View Active Statuses (Priority: P1)

All authenticated users can see active statuses from other users in the Recent Updates section of the Status screen. Statuses older than 24 hours are not shown.

**Why this priority**: Viewing is the primary consumer-side interaction.

**Independent Test**: Can be tested by loading the Status screen and confirming only statuses with `expiresAt > now` appear, grouped under Recent Updates.

**Acceptance Scenarios**:

1. **Given** active statuses exist from other users, **When** the Status screen loads, **Then** they appear in the Recent Updates section ordered by most recent.
2. **Given** a status's `expiresAt` has passed, **When** the screen refreshes, **Then** that status is no longer shown.
3. **Given** no active statuses exist, **When** the screen loads, **Then** an empty-state message is shown.

---

### User Story 4 — View Status in Full-Screen Viewer (Priority: P2)

Tapping a user's status card opens a full-screen viewer. The viewer displays the image or text with background color, the author's name and photo, and a close button. Opening a status marks it as viewed by adding the current user's UID to the `viewers` array.

**Why this priority**: Core consumption experience; must work before replies or progress bars are considered.

**Independent Test**: Can be tested by tapping a status card, verifying the viewer opens, and confirming the `viewers` array in Firestore is updated.

**Acceptance Scenarios**:

1. **Given** a user taps a status card, **When** the status viewer opens, **Then** the image (or text with background) fills the screen, the author's name and photo are visible, and a close button is present.
2. **Given** the viewer opens, **When** the current user has not previously viewed this status, **Then** their UID is appended to the `viewers` array in Firestore.
3. **Given** the viewer opens, **When** the current user already viewed this status, **Then** their UID is not duplicated in `viewers`.

---

### User Story 5 — My Status Card and Delete Own Status (Priority: P2)

The Status screen shows a "My Status" card at the top. The user can view their own statuses and delete any of them. Deleting removes the Firestore document and, for image statuses, deletes the file from Supabase Storage.

**Why this priority**: Ownership and privacy control; required to avoid stale content.

**Independent Test**: Can be tested by creating a status, viewing the My Status card, tapping delete, and confirming the document and file are removed.

**Acceptance Scenarios**:

1. **Given** the current user has active statuses, **When** the Status screen loads, **Then** the My Status card reflects the count and the latest preview.
2. **Given** the user taps delete on one of their statuses, **When** confirmed, **Then** the Firestore document is deleted and, if `storagePath` is non-empty, the Supabase file is removed.
3. **Given** the user has no own statuses, **When** the My Status card is tapped, **Then** the add status bottom sheet opens.

---

### Edge Cases

- What happens when image upload to Supabase succeeds but the Firestore write fails? → Show error toast; the orphaned file should not block UX (no automatic cleanup in v1, noted as a known limitation).
- What if the user's device has no camera permission? → Show a permission-denied message via toast.
- What if `viewers` array update fails silently? → Tolerate; viewing is best-effort tracking.
- What if the user deletes a text status (no `storagePath`)? → Skip Supabase delete, only remove the Firestore document.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow authenticated users to create an image status by selecting an image from gallery or camera.
- **FR-002**: System MUST upload the selected image to Supabase Storage under path `statuses/{userId}/{fileName}` before writing the Firestore document.
- **FR-003**: System MUST allow authenticated users to create a text status with a text message and a background color.
- **FR-004**: System MUST write status metadata to the `statuses` Firestore collection with `createdAt` (now) and `expiresAt` (now + 24 hours).
- **FR-005**: System MUST display only statuses where `expiresAt > now` in the active statuses list.
- **FR-006**: System MUST display active statuses only from users who share a direct chat with the current user (i.e., contacts are derived from the existing chats collection — no separate contacts collection required).
- **FR-007**: System MUST display the current user's own active statuses in a dedicated My Status card at the top of the Status screen.
- **FR-008**: System MUST open a full-screen status viewer when a status card is tapped.
- **FR-009**: System MUST add the current viewer's UID to the `viewers` array in Firestore when the status viewer is opened (idempotent — no duplicates).
- **FR-010**: System MUST allow the current user to delete only their own statuses.
- **FR-011**: System MUST delete the associated Supabase Storage file when deleting an image status (where `storagePath` is non-empty).
- **FR-012**: System MUST show a success toast after status creation.
- **FR-013**: System MUST show an error toast on creation or deletion failure.
- **FR-014**: System MUST show an empty-state message when no active statuses are available.
- **FR-017**: System MUST split contacts' active statuses into two sections on the Status screen: "Recent Updates" (statuses the current user has NOT viewed) and "Viewed Updates" (statuses the current user HAS viewed), determined by whether the current user's UID is in the `viewers` array.
- **FR-015**: All user-visible labels MUST use the localization system (no hardcoded strings).
- **FR-016**: System MUST use separate Cubits for listing active statuses, creating a status, and managing own statuses — no shared loading state.

### Key Entities

- **StatusModel**: Represents a single status. Key attributes: `id`, `userId`, `userName`, `userEmail`, `userPhotoUrl`, `mediaUrl`, `storagePath`, `type` (image | text), `text`, `backgroundColor`, `viewers` (list of UIDs), `createdAt`, `expiresAt`.
- **CurrentUserModel**: Existing model providing `uid`, `name`, `email`, `photoUrl` — used as author metadata when creating a status.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create and publish an image status in under 30 seconds on a standard connection.
- **SC-002**: A user can create a text status in under 10 seconds.
- **SC-003**: Active statuses appear on the Status screen within 2 seconds of opening the screen.
- **SC-004**: Expired statuses (older than 24 hours) never appear in the active statuses list.
- **SC-005**: Deleting a status removes it from all users' views within 5 seconds.
- **SC-006**: 100% of user-visible labels are translated via the localization system — zero hardcoded strings.
- **SC-007**: Viewing a status is recorded (UID added to `viewers`) without requiring any explicit user action beyond opening the viewer.

## Clarifications

### Session 2026-05-06

- Q: Who can see a user's status? → A: Only mutual contacts / friends can see each other's statuses.
- Q: What are the named routes for the three status screens? → A: `/status` (StatusScreen), `/text-status` (TextStatusScreen), `/status-viewer` (StatusViewerScreen).
- Q: How is the contacts/friends relationship stored? → A: Contacts = users who share a direct chat; reuse the existing chats collection (no new collection).
- Q: Should viewed statuses be visually separated from unviewed ones? → A: Yes — two sections: "Recent Updates" (unviewed) and "Viewed Updates" (already seen).
- Q: Is `image_picker` already in pubspec.yaml? → A: Yes — already present; no new package needed.

## Assumptions

- Statuses are visible **only to users who share a direct chat** with the author — contact relationships are derived from the existing chats collection; no separate contacts collection is needed.
- Video status is out of scope for v1; only image and text types are supported.
- The progress bar in the status viewer is deferred to a future version; v1 shows a static full-screen view.
- Status replies (reply to a status) are out of scope for v1.
- Image picking (both gallery and camera) uses the existing `image_picker` package; no new package is added.
- The Status screen is accessible as a dedicated tab in the existing bottom navigation bar, routed at `/status`. TextStatusScreen is at `/text-status` and StatusViewerScreen is at `/status-viewer`.
- The current user's own statuses appear at the top in a "My Status" card, separate from the Recent Updates section.
- Contacts' active statuses are split into two UI sections: "Recent Updates" (current user's UID not in `viewers`) and "Viewed Updates" (current user's UID in `viewers`).
- Only the status author can delete their own statuses; moderator/admin deletion is out of scope.
- Orphaned Supabase files (upload succeeded but Firestore write failed) are a known v1 limitation; no automatic cleanup.
- `image_picker` is confirmed present in `pubspec.yaml`; no new package is required for this feature.
