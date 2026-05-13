# Feature Specification: Profile & Settings Screen

**Feature Branch**: `002-profile-settings-screen`  
**Created**: 2026-05-05  
**Status**: Draft  
**Input**: User description: "Create a Profile / Settings screen for my Flutter chat app."

## Clarifications

### Session 2026-05-05

- Q: Should profile data be read only from SharedPreferences, or also silently refreshed from Firestore in the background? → A: Read from SharedPreferences first (instant render), then silently refresh from Firestore in the background and update the UI if data changed.
- Q: Should tapping Logout show a confirmation dialog before starting the logout process? → A: No dialog — logout begins immediately with a loading indicator on tap.
- Q: When photoUrl is null, what should the avatar fallback be? → A: Display the user's initials (first letter of name) inside a colored circle; show "?" if name is also null.
- Q: Should the profile screen clear `PrefKeys.currentUser` from SharedPreferences before calling `AppLogout().logout()`? → A: No — `AppLogout` is solely responsible for its own cleanup; this screen calls it without pre-clearing user data.
- Q: Should any settings tile (Edit Profile, Account & Security, Notifications, Language) be fully implemented in this feature? → A: No — all four route to the existing `PageUnderBuildScreen` placeholder; each sub-screen is a separate future feature.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Profile & Settings (Priority: P1)

A logged-in user opens the Settings tab in the bottom navigation bar and sees their full profile information along with organized settings sections.

**Why this priority**: This is the primary value of the screen — users must be able to see who they are logged in as and access all settings from one place.

**Independent Test**: Navigate to the Settings tab; confirm the profile card displays the current user's name, email, and avatar (or fallback icon), and that all four setting tiles and the logout tile are visible.

**Acceptance Scenarios**:

1. **Given** a logged-in user with a complete profile (name, email, photoUrl), **When** they tap the Settings tab, **Then** the screen shows name, email, and avatar loaded from local storage without a network request.
2. **Given** a logged-in user whose photoUrl is null, **When** the Settings tab is opened, **Then** the avatar shows the user's initials in a colored circle (or "?" if name is also null).
3. **Given** a logged-in user whose display name is null, **When** the Settings tab is opened, **Then** the username or UID is shown as a fallback label.

---

### User Story 2 - Navigate to Profile Sub-Screens (Priority: P2)

A user taps any setting tile (Edit Profile Info, Account & Security, Notifications, Language) and is taken to the corresponding screen or a clearly marked placeholder.

**Why this priority**: Navigation correctness is essential; broken tiles would undermine user trust even if sub-screens are not yet fully built.

**Independent Test**: Tap each of the four setting tiles in turn; confirm each navigates without crashing.

**Acceptance Scenarios**:

1. **Given** the Settings screen is open, **When** the user taps "Edit Profile Info", **Then** they are navigated to the edit profile route (or a placeholder screen).
2. **Given** the Settings screen is open, **When** the user taps "Account & Security", **Then** they are navigated to the account security route (or a placeholder screen).
3. **Given** the Settings screen is open, **When** the user taps "Notifications", **Then** they are navigated to the notifications settings route (or a placeholder screen).
4. **Given** the Settings screen is open, **When** the user taps "Language", **Then** they are navigated to the language settings route (or a placeholder screen).

---

### User Story 3 - Logout (Priority: P3)

A user taps the Logout tile and is signed out, their local session data is cleared, and they are returned to the Login screen.

**Why this priority**: Logout must be reliable and complete; partial logout is a security risk. Lower priority than viewing because it is an infrequent action.

**Independent Test**: Tap Logout; confirm the user is on the Login screen and cannot navigate back to protected screens.

**Acceptance Scenarios**:

1. **Given** the Settings screen is open, **When** the user taps the Logout tile, **Then** a loading indicator appears while the logout operation runs.
2. **Given** logout completes successfully, **When** the operation finishes, **Then** all local user session data is cleared, a success toast is shown, and the user is navigated to the Login screen with no back-stack entry to the main app.
3. **Given** logout fails (network or service error), **When** the error is received, **Then** an error toast is shown and the user remains on the Settings screen.

---

### Edge Cases

- What happens when the local user data (CurrentUserModel in SharedPreferences) is corrupted or missing? The screen must handle a null/incomplete model gracefully and still render without crashing.
- What happens if the user taps Logout while a previous logout is still in progress? Duplicate logout requests must be prevented (disable the tile or ignore taps while loading).
- What happens if the user's name AND username are both null? UID must be shown as the ultimate fallback.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Settings screen MUST display within the existing main bottom navigation (Settings tab, `NavBarEnum.settings`) — no separate route push needed to reach it.
- **FR-002**: On load, the screen MUST immediately display user data from local storage (`SharedPreferences` via `PrefKeys.currentUser`). After the initial render, it MUST silently fetch the latest profile from Firestore in the background and update the profile card if the data has changed — no blocking spinner for this refresh.
- **FR-003**: The profile card MUST display: display name (fallback: username or UID), email address, and avatar image. When `photoUrl` is null, the avatar MUST show the user's initials (first letter of name) inside a colored circle; if name is also null, display "?" inside the circle.
- **FR-004**: The screen MUST present a "PROFILE" section with two navigable tiles: "Edit Profile Info" and "Account & Security".
- **FR-005**: The screen MUST present an "APP PREFERENCES" section with two navigable tiles: "Notifications" and "Language".
- **FR-006**: The screen MUST present a Logout tile styled distinctly (red icon/text) separate from the settings sections.
- **FR-007**: Each navigable settings tile MUST show a title, a subtitle, a leading icon, and a trailing arrow icon.
- **FR-008**: All visible labels MUST use the app's localization system via `LangKeys` constants — no hardcoded strings.
- **FR-009**: Tapping any of the four settings tiles MUST navigate to `PageUnderBuildScreen`. Edit Profile Info, Account & Security, Notifications, and Language are all placeholders in this feature iteration — none are fully implemented here.
- **FR-010**: Tapping Logout MUST invoke `AppLogout().logout()`, show a loading state while in progress, show a success toast on completion, and navigate to the Login screen removing all back-stack entries.
- **FR-011**: If logout fails, the screen MUST show an error toast and remain on the Settings screen.
- **FR-012**: The following `LangKeys` constants MUST be added: `profile`, `settings` (already exists), `editProfileInfo`, `editProfileSubtitle`, `accountSecurity`, `accountSecuritySubtitle`, `notifications`, `notificationsSubtitle`, `language`, `languageSubtitle`, `logout`, `logoutSubtitle`, `profileSection`, `appPreferences`, `loggedOutSuccessfully`.
- **FR-013**: The screen title ("Settings") is already rendered by `MainAppBar` for the settings tab — the screen body itself MUST NOT duplicate the app bar.
- **FR-014**: The screen MUST be composed of the required widget files: `profile_screen.dart`, `profile_body.dart`, `profile_user_card.dart`, `profile_section_title.dart`, `profile_setting_tile.dart`, `profile_logout_tile.dart`, and a `profile_cubit.dart` / `profile_bloc_consumer.dart` if state management for logout is needed.

### Key Entities

- **CurrentUserModel**: The locally-stored representation of the authenticated user. Key fields used on this screen: `uid`, `name`, `email`, `photoUrl`. Read from `SharedPreferences` using `PrefKeys.currentUser`.
- **ProfileState**: Cubit state covering: (a) logout — loading, success, and error outcomes; (b) profile refresh — a background state that updates the profile card when Firestore returns fresher data, without blocking the initial render.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The Settings screen renders the profile card within 200 ms of tab selection using local storage data — no blocking spinner. A silent Firestore refresh may update displayed data after the initial render without disrupting the user.
- **SC-002**: All four settings tiles and the logout tile are tappable and navigate without crashes on every supported device.
- **SC-003**: Logout completes and the user reaches the Login screen within 3 seconds under normal network conditions.
- **SC-004**: Zero hardcoded UI strings — all labels pass through the localization system.
- **SC-005**: Null safety: the screen renders without runtime errors when `name`, `email`, and `photoUrl` are all null simultaneously.
- **SC-006**: The logout action leaves no accessible route back to the authenticated main app (full stack removal confirmed).

## Assumptions

- The logged-in user's data is always persisted to `SharedPreferences` under `PrefKeys.currentUser` at login time; this screen does not need to handle the case where the user was never stored there (that case implies a broken auth flow outside this feature's scope). The background Firestore refresh overwrites the local cache on success so subsequent screen visits see fresher data.
- Sub-screens for Edit Profile Info, Account & Security, Notifications, and Language are explicitly out of scope — all four route to `PageUnderBuildScreen` (confirmed in clarification). Each will be a separate future feature.
- The "Settings" title in the app bar is already provided by `MainAppBar` switching on `NavBarEnum.settings` — this feature does not change the app bar.
- The screen lives inside the bottom navigation (no separate push route); the `AppRoutes.profile` constant already exists but is not used for this screen.
- `AppLogout().logout()` handles Firebase sign-out, clears local tokens, clears Hive, and navigates to login. The profile screen calls it directly without pre-clearing `PrefKeys.currentUser` — cleanup of that key is `AppLogout`'s responsibility (confirmed in clarification).
- Language settings will route to a placeholder; integration with the existing localization system is a separate feature.
- No logout confirmation dialog is shown; tapping the Logout tile immediately begins the logout operation with a loading indicator (confirmed in clarification).
