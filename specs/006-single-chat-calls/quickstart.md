# Quickstart: Single Chat Calls

## Prerequisites

- Flutter SDK installed
- Firebase project configured (Auth + Firestore already set up)
- Agora account created at [agora.io](https://www.agora.io/)
- Agora App ID obtained from Agora Console

## Setup Steps

### 1. Add dependencies

```yaml
# pubspec.yaml
dependencies:
  agora_rtc_engine: ^6.3.0
  permission_handler: ^11.0.0
```

Run:
```bash
flutter pub get
```

### 2. Configure Agora App ID

Create or update a constants file:
```dart
// lib/constants/agora_constants.dart
const String agoraAppId = 'YOUR_AGORA_APP_ID_HERE';
```

### 3. Platform permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access for audio calls</string>
<key>NSCameraUsageDescription</key>
<string>This app requires camera access for video calls</string>
</xml>
```

### 4. Create Firestore indexes

Deploy indexes for the `calls` collection:
- `receiverId` ASC + `status` ASC (incoming call listener)
- `chatId` ASC + `status` ASC (duplicate prevention)
- `callerId` ASC + `createdAt` DESC (caller history)
- `receiverId` ASC + `createdAt` DESC (receiver history)

### 5. Generate model code

After creating `call_model.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Implementation order

1. `CallModel` + run build_runner
2. `fierstore_paths.dart` — add `callsCollection`
3. `CallProviderService` abstract + `AgoraCallProviderService`
4. `CallsRemoteDataSource` abstract + impl
5. `CallsRepo` abstract + impl
6. All 4 Cubits + states
7. GetIt registrations in `injection_container.dart`
8. LangKeys + JSON translations
9. Routes in `app_routes.dart`
10. UI: `CallScreen`, `CallBody`, `CallHeader`, `CallControls`
11. UI: `IncomingCallDialog`, `IncomingCallOverlay`
12. UI: `CallsHistoryScreen`, `CallsHistoryBody`, `CallHistoryCard`
13. Integration: `SingleChatScreen` AppBar actions
14. Integration: `MainScreen` IncomingCallCubit + Calls tab
15. Test all flows manually

## Verification

After implementation, verify:
```
1. Open chat → see call icons in header
2. Tap audio call → Firestore "calls" doc created → CallScreen shows
3. On second device: incoming call dialog appears
4. Accept → both on call, timer running
5. End → both return, duration saved
6. Calls tab → history shows the call
```
