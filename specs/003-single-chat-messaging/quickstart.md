# Quickstart: Single Chat Messaging

## Prerequisites

- Flutter SDK installed; run `flutter pub get`
- Firebase project configured (existing `google-services.json` / `GoogleService-Info.plist`)
- Supabase project with bucket `chatapp` already created
- Add `record` package to `pubspec.yaml` if not already present:
  ```yaml
  record: ^5.1.2
  ```

## Running the Feature

1. Navigate to any existing chat from the home screen.
2. The single chat screen loads the last 20 messages in real time.
3. Type a message and tap **Send** to send text.
4. Tap the **attachment icon** (paperclip / `Iconsax.attach_circle`) to open the attachment bottom sheet:
   - **Image** → opens gallery picker
   - **Audio** → hold to record, release to send
   - **File** → opens file picker

## Key Files

| Layer | File | Purpose |
|-------|------|---------|
| Data — model | `lib/features/single_chat/data/models/message_model.dart` | Firestore ↔ Dart mapping |
| Data — source | `lib/features/single_chat/data/datasources/messages_remote_data_source.dart` | Firestore reads/writes |
| Data — repo | `lib/features/single_chat/data/repositories/messages_repo_impl.dart` | Wraps data source, returns `ApiResult` |
| Domain — repo | `lib/features/single_chat/domain/repositories/messages_repo.dart` | Abstract contract |
| Domain — use cases | `lib/features/single_chat/domain/use_cases/` | `GetMessagesUseCase`, `SendTextMessageUseCase`, `SendImageMessageUseCase`, `SendAudioMessageUseCase`, `SendFileMessageUseCase` |
| Presentation — cubits | `lib/features/single_chat/presentation/bloc/messages_cubit/` | Stream messages |
| Presentation — cubits | `lib/features/single_chat/presentation/bloc/send_message_cubit/` | Send + upload lifecycle |
| Presentation — screen | `lib/features/single_chat/presentation/screens/single_chat_screen.dart` | Main screen scaffold |
| Presentation — widgets | `lib/features/single_chat/presentation/widgets/` | Message bubble, input bar, attachment sheet, media viewers |
| Core — storage | `lib/core/service/supabase/supabase_storage_service.dart` | Add `uploadChatImage`, `uploadChatAudio`, `uploadChatFile` |
| Core — DI | `lib/core/di/injection_container.dart` | Register new cubits, use cases, repos |

## DI Registration (summary)

```dart
// In injection_container.dart
sl.registerLazySingleton<MessagesRepo>(
  () => MessagesRepoImpl(
    dataSource: MessagesRemoteDataSourceImpl(dataBaseService: sl()),
    storageService: sl<SupabaseStorageService>(),
  ),
);
sl.registerFactory(() => MessagesCubit(sl<GetMessagesUseCase>()));
sl.registerFactory(() => SendMessageCubit(
  sl<SendTextMessageUseCase>(),
  sl<SendImageMessageUseCase>(),
  sl<SendAudioMessageUseCase>(),
  sl<SendFileMessageUseCase>(),
));
```
