# Feature Specification: Sign Up Screen

**Feature Branch**: `007-signup-screen`  
**Created**: 2026-05-12  
**Status**: Draft  
**Input**: User description: "Create sign up screen similar to the login screen in design/theme, add UserAvatarImage widget to add an image to the account, email field, name field, phone field, password and confirm password field"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Account Registration (Priority: P1)

A new user opens the app for the first time and navigates to the sign-up screen from the login screen. They see a familiar layout matching the login screen's design and theme. They upload a profile avatar image, fill in their name, email, phone number, password, and confirm password, then submit the form to create their account.

**Why this priority**: Account registration is the gateway to using the app. Without it, no new users can join.

**Independent Test**: Can be fully tested by navigating to sign-up, filling all fields with valid data, submitting, and verifying the account is created and the user is logged in.

**Acceptance Scenarios**:

1. **Given** the user is on the login screen, **When** they tap the "Sign Up" button, **Then** the sign-up screen is displayed with the same design theme as the login screen.
2. **Given** the user is on the sign-up screen, **When** they fill all fields with valid data and submit, **Then** a new account is created and the user is navigated to the home screen.
3. **Given** the user is on the sign-up screen, **When** they upload a profile image using the avatar widget, **Then** the image is displayed in the avatar circle.

---

### User Story 2 - Form Validation Feedback (Priority: P2)

A user attempts to submit the sign-up form with invalid or incomplete data and receives clear, immediate feedback about what needs to be corrected.

**Why this priority**: Validation prevents bad data and guides users to successful registration. Critical for usability.

**Independent Test**: Can be tested by submitting the form with various invalid inputs and verifying appropriate error messages appear.

**Acceptance Scenarios**:

1. **Given** the user leaves required fields empty, **When** they tap submit, **Then** validation errors are shown for each empty required field.
2. **Given** the user enters an invalid email format, **When** they tap submit, **Then** an "invalid email" error is shown on the email field.
3. **Given** the user enters a password that does not meet requirements, **When** they tap submit, **Then** an "invalid password" error is shown.
4. **Given** the password and confirm password fields do not match, **When** they tap submit, **Then** a "passwords do not match" error is shown on the confirm password field.
5. **Given** the user enters an invalid phone number, **When** they tap submit, **Then** an "invalid phone number" error is shown.

---

### User Story 3 - Optional Profile Image Upload (Priority: P3)

A user decides to skip uploading a profile image and registers with only text fields. The avatar widget shows a default placeholder and account creation proceeds normally.

**Why this priority**: Profile image is a nice-to-have for onboarding but should not block registration.

**Independent Test**: Can be tested by completing registration without uploading an image and verifying the account is created with a default avatar.

**Acceptance Scenarios**:

1. **Given** the user has not uploaded a profile image, **When** they submit the form with valid text fields, **Then** the account is created with a default avatar.
2. **Given** the user uploaded an image but then removes it, **When** they submit the form, **Then** the account is created with a default avatar.

---

### Edge Cases

- What happens when the user enters an email that is already registered?
- What happens if the image upload fails due to network issues during registration?
- What happens when the user navigates away mid-registration and returns?
- How does the screen behave on very small or very large screen sizes?
- What happens if the user taps submit multiple times rapidly?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a sign-up screen with the same Material 3 design theme as the login screen (matching layout, spacing, typography, and color scheme).
- **FR-002**: System MUST display the `UserAvatarImage` widget at the top of the sign-up form for optional profile image upload.
- **FR-003**: System MUST provide a name text field with validation (non-empty, reasonable length).
- **FR-004**: System MUST provide an email text field with email format validation.
- **FR-005**: System MUST provide a phone number text field with phone number validation.
- **FR-006**: System MUST provide a password text field with password strength validation and visibility toggle.
- **FR-007**: System MUST provide a confirm password text field that validates it matches the password field.
- **FR-008**: System MUST provide a submit button that triggers account creation when all validations pass.
- **FR-009**: System MUST show a loading indicator during the account creation process.
- **FR-010**: System MUST navigate the user to the home screen upon successful registration.
- **FR-011**: System MUST display appropriate error messages when registration fails (e.g., email already in use).
- **FR-012**: System MUST provide a way to navigate back to the login screen.
- **FR-013**: System MUST support the app's existing localization (Arabic and English).

### Key Entities

- **User Account**: Represents a registered user with name, email, phone, password, and optional profile image URL.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the sign-up process (all fields + submit) in under 2 minutes.
- **SC-002**: 95% of users successfully register on their first attempt when entering valid data.
- **SC-003**: All validation errors are displayed within 1 second of form submission.
- **SC-004**: The sign-up screen is visually consistent with the login screen's design theme (same widget styles, spacing, color palette).
- **SC-005**: The sign-up screen is fully functional in both Arabic and English languages.

## Assumptions

- The existing authentication service (Firebase Auth) supports email/password registration with additional profile fields.
- The existing `UserAvatarImage` widget from the groups feature can be reused directly on the sign-up screen.
- The existing `CustomTextField`, `CustomLinearButton`, and other shared widgets from the login screen will be reused.
- Phone number is stored as profile data and is not used for phone-based authentication.
- The existing `AppRegex` utility provides phone number validation or can be extended.
- Profile image upload uses the existing `UploadImageCubit` infrastructure.
