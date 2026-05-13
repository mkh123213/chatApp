# Data Model: Profile & Settings Screen

## Entities

### CurrentUserModel (existing — read-only on this screen)

| Field | Type | Nullable | Source |
|-------|------|----------|--------|
| `uid` | `String` | No | SharedPreferences / Firebase |
| `name` | `String?` | Yes | SharedPreferences / Firebase |
| `email` | `String?` | Yes | SharedPreferences / Firebase |
| `photoUrl` | `String?` | Yes | SharedPreferences / Firebase |
| `emailVerified` | `bool` | No | SharedPreferences / Firebase |
| `isAnonymous` | `bool` | No | SharedPreferences / Firebase |
| `phoneNumber` | `String?` | Yes | SharedPreferences / Firebase |
| `providerId` | `String?` | Yes | SharedPreferences / Firebase |
| `creationTime` | `DateTime?` | Yes | SharedPreferences / Firebase |
| `lastSignInTime` | `DateTime?` | Yes | SharedPreferences / Firebase |

**Fallback chain for display name**: `name` → `uid`  
**Fallback chain for avatar**: `photoUrl` → initials from `name[0]` → `"?"`

---

### ProfileState (new — Freezed sealed union)

```
ProfileState
├── initial()
├── profileLoaded(CurrentUserModel user)
├── logoutLoading()
├── logoutSuccess()
└── logoutError(String message)
```

**State transitions**:

```
initial
  └─(loadUser called)──► profileLoaded(user)
                               │
                               ├─(background refresh done)──► profileLoaded(updatedUser)
                               │
                               └─(user taps Logout)──► logoutLoading
                                                            │
                                                ┌───────────┴────────────┐
                                                ▼                        ▼
                                          logoutSuccess            logoutError
                                                                        │
                                                                        └──► profileLoaded(lastUser)
```

**Validation rules**:
- `logoutLoading` → if already in `logoutLoading`, the `logout()` method returns early (no duplicate request).
- `logoutSuccess` → `AppLogout().logout()` has already navigated to login; no further action in cubit.

---

### ProfileRemoteDataSource (new interface)

```dart
abstract interface class ProfileRemoteDataSource {
  /// Reloads current Firebase user, returns updated CurrentUserModel.
  /// Returns null if no user is signed in.
  Future<CurrentUserModel?> refreshCurrentUser();
}
```

Implementation (`ProfileRemoteDataSourceImpl`):
1. Call `FirebaseAuth.instance.currentUser?.reload()`
2. Read `FirebaseAuth.instance.currentUser` (now refreshed)
3. If null → return null
4. Map to `CurrentUserModel.fromFirebaseUser(user)`
5. Write JSON back to `SharedPref` under `PrefKeys.currentUser`
6. Return model

---

## Localization Entries

| `LangKeys` constant | JSON key | EN value |
|---|---|---|
| `profile` | `profile` | Profile |
| `editProfileInfo` | `edit_profile_info` | Edit Profile Info |
| `editProfileSubtitle` | `edit_profile_subtitle` | Update your name, photo and bio |
| `accountSecurity` | `account_security` | Account & Security |
| `accountSecuritySubtitle` | `account_security_subtitle` | Password, two-step verification |
| `notifications` | `notifications` | Notifications |
| `notificationsSubtitle` | `notifications_subtitle` | Manage notification preferences |
| `languageSubtitle` | `language_subtitle` | Change app language |
| `logout` | `logout` | Logout |
| `logoutSubtitle` | `logout_subtitle` | Sign out of your account |
| `profileSection` | `profile_section` | PROFILE |
| `appPreferences` | `app_preferences` | APP PREFERENCES |
| `loggedOutSuccessfully` | `logged_out_successfully` | Logged out successfully |

Note: `language` and `settings` keys already exist in `LangKeys` and `en.json`.
