import 'package:chat_material3/core/app/app_cubit/cubit/app_cubit.dart';
import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/service/auth_service_fierbase/auth_service_fierbase.dart';
import 'package:chat_material3/core/service/network/api_service.dart';
import 'package:chat_material3/core/service/network/dio_factory.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:chat_material3/features/single_chat/data/datasources/block_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/datasources/chats_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/datasources/messages_remote_data_source.dart';
import 'package:chat_material3/core/app/data_source/un_read_messages_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/repositories/block_repo.dart';
import 'package:chat_material3/features/single_chat/data/repositories/chats_repo.dart';
import 'package:chat_material3/features/single_chat/data/repositories/messages_repo_impl.dart';
import 'package:chat_material3/core/app/repo/unread_messages_repo.dart';
import 'package:chat_material3/features/single_chat/domain/repositories/messages_repo.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:chat_material3/features/single_chat/data/datasources/user_presence_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/repositories/user_presence_repo.dart';
import 'package:chat_material3/core/service/user_presence/user_presence_service.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/user_presence_cubit/user_presence_cubit.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:chat_material3/features/groups/data/datasources/groups_remote_data_source.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';
import 'package:chat_material3/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart';
import 'package:chat_material3/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart';
import 'package:chat_material3/features/groups/presentation/bloc/group_info_cubit/group_info_cubit.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:chat_material3/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:chat_material3/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:chat_material3/features/status/data/datasources/status_remote_data_source.dart';
import 'package:chat_material3/features/status/data/repositories/status_repo.dart';
import 'package:chat_material3/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/bloc/status_cubit/status_cubit.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:chat_material3/core/service/call_service/agora_call_provider_service.dart';
import 'package:chat_material3/features/calls/data/datasources/calls_remote_data_source.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';
import 'package:chat_material3/features/calls/presentation/bloc/start_call_cubit/start_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_material3/core/app/upload_image/cubit/upload_image_cubit.dart';
import 'package:chat_material3/core/app/upload_image/data_source/upload_image_data_source.dart';
import 'package:chat_material3/core/app/upload_image/repo/upload_image_repo.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  await _initCore();
  await _initAuth();

  await _initChats();
  await _initGroups();
  await _initProfile();
  await _initStatus();
  await _initCalls();
  // await _initHome();
  // await _initProductDetails();
  // await _initCategory();
  // await _initProductsViewAll();
  // await _initSearch();
  // await _initFavorites();
}

Future<void> _initStatus() async {
  sl
    ..registerLazySingleton<StatusRepo>(
      () => StatusRepo(sl()),
    )
    ..registerLazySingleton<StatusRemoteDataSource>(
      () => StatusRemoteDataSourceImpl(
        db: sl<DataBaseService>(),
        storage: sl<SupabaseStorageService>(),
      ),
    )
    ..registerFactory(
      () => CreateStatusCubit(statusRepo: sl()),
    )
    ..registerFactory(
      () => MyStatusCubit(statusRepo: sl()),
    )
    ..registerFactory(
      () => StatusCubit(statusRepo: sl()),
    );
}

Future<void> _initProfile() async {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(profileRemoteDataSource: sl()),
    );
}

Future<void> _initChats() async {
  sl
    ..registerLazySingleton<ChatsRemoteDataSource>(
      () => ChatsRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
      ),
    )
    ..registerLazySingleton<ChatsRepo>(
      () => ChatsRepoImpl(
        chatsRemoteDataSource: sl<ChatsRemoteDataSource>(),
      ),
    )
    ..registerFactory<ChatsCubit>(
      () => ChatsCubit(
        chatsRepo: sl<ChatsRepo>(),
      ),
    )
    ..registerFactory<CreateChatCubit>(
      () => CreateChatCubit(
        chatsRepo: sl<ChatsRepo>(),
      ),
    )
    ..registerLazySingleton<SupabaseStorageService>(
      () => SupabaseStorageService(),
    )
    ..registerLazySingleton<MessagesRemoteDataSource>(
      () => MessagesRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
        storageService: sl<SupabaseStorageService>(),
      ),
    )
    ..registerLazySingleton<MessagesRepo>(
      () => MessagesRepoImpl(
        messagesRemoteDataSource: sl<MessagesRemoteDataSource>(),
      ),
    )
    ..registerFactory<MessagesCubit>(
      () => MessagesCubit(messagesRepo: sl<MessagesRepo>()),
    )
    ..registerFactory<SendMessageCubit>(
      () => SendMessageCubit(messagesRepo: sl<MessagesRepo>()),
    )
    ..registerLazySingleton<UserPresenceRemoteDataSource>(
      () => UserPresenceRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
      ),
    )
    ..registerLazySingleton<UserPresenceRepo>(
      () => UserPresenceRepo(
        remoteDataSource: sl<UserPresenceRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<UserPresenceService>(
      () => UserPresenceService(
        userPresenceRepo: sl<UserPresenceRepo>(),
      ),
    )
    ..registerFactory<UserPresenceCubit>(
      () => UserPresenceCubit(
        userPresenceRepo: sl<UserPresenceRepo>(),
      ),
    )
    ..registerLazySingleton<BlockRemoteDataSource>(
      () => BlockRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<BlockRepo>(
      () => BlockRepo(dataSource: sl<BlockRemoteDataSource>()),
    )
    ..registerFactory<BlockCubit>(
      () => BlockCubit(blockRepo: sl<BlockRepo>()),
    )
    ..registerFactory(
      () => UnreadMessagesCubit(unReadMessagesReo: sl()),
    )
    ..registerLazySingleton(() => UnreadMessagesRepo(
          unreadMessageDataSource: sl(),
        ))
    ..registerLazySingleton(
      () => UnReadMessagesRemoteDataSource(
        firestore: sl(),
      ),
    );
}

Future<void> _initCore() async {
  final dio = DioFactory.getDio();
  final navigatorKey = GlobalKey<NavigatorState>();

  sl
    ..registerFactory(AppCubit.new)
    ..registerLazySingleton<ApiService>(() => ApiService(dio))
    ..registerSingleton<GlobalKey<NavigatorState>>(navigatorKey)
    ..registerLazySingleton(() => UploadImageDataSource(sl()))
    ..registerLazySingleton(() => UploadImageRepo(sl()))
    ..registerFactory(() => UploadImageCubit(sl()))
    ..registerFactory(() => MainCubit())
    ..registerLazySingleton<AuthService>(() => FirebaseAuthService())
    ..registerLazySingleton<DataBaseService>(() => FirestoreServices());
  // ..registerFactory(ShareCubit.new)
  ;
}

Future<void> _initAuth() async {
  sl.registerFactory(() => AuthCubit(authService: sl(), dataBaseService: sl()));
  // ..registerLazySingleton(() => AuthRepo(authDataSource: sl()))
  //   ..registerFactory(() => AuthBloc(authRepo: sl()))
  //   ..registerLazySingleton(
  //     () => AuthDataSource(
  //       apiService: sl(),
  //       dataBaseService: FirestoreServices(),
  //     ),
  //   );
}

Future<void> _initCalls() async {
  sl
    ..registerLazySingleton<CallProviderService>(
      () => AgoraCallProviderService(),
    )
    ..registerLazySingleton<CallsRemoteDataSource>(
      () => CallsRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
      ),
    )
    ..registerLazySingleton<CallsRepo>(
      () => CallsRepoImpl(
        callsRemoteDataSource: sl<CallsRemoteDataSource>(),
      ),
    )
    ..registerFactory<StartCallCubit>(
      () => StartCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<IncomingCallCubit>(
      () => IncomingCallCubit(callsRepo: sl<CallsRepo>()),
    )
    ..registerFactory<ActiveCallCubit>(
      () => ActiveCallCubit(
        callsRepo: sl<CallsRepo>(),
        callProviderService: sl<CallProviderService>(),
      ),
    )
    ..registerFactory<CallsHistoryCubit>(
      () => CallsHistoryCubit(callsRepo: sl<CallsRepo>()),
    );
}

Future<void> _initGroups() async {
  sl
    ..registerLazySingleton<GroupsRemoteDataSource>(
      () => GroupsRemoteDataSourceImpl(
        dataBaseService: sl<DataBaseService>(),
        blockRemoteDataSource: sl<BlockRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<GroupsRepo>(
      () =>
          GroupsRepoImpl(groupsRemoteDataSource: sl<GroupsRemoteDataSource>()),
    )
    ..registerFactory<GroupsCubit>(
        () => GroupsCubit(groupsRepo: sl<GroupsRepo>()))
    ..registerFactory<CreateGroupCubit>(() => CreateGroupCubit(
        groupsRepo: sl<GroupsRepo>(), blockRepo: sl<BlockRepo>()))
    ..registerFactory<SelectedGroupChatCubit>(
      () => SelectedGroupChatCubit(
        groupsRepo: sl<GroupsRepo>(),
        storageService: sl<SupabaseStorageService>(),
      ),
    )
    ..registerFactory<GroupInfoCubit>(
        () => GroupInfoCubit(groupsRepo: sl<GroupsRepo>()));
}
