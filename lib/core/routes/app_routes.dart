import 'dart:convert';

import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:chat_material3/features/auth/presentation/screens/login_screen.dart';
import 'package:chat_material3/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/presentation/screens/call_screen.dart';
import 'package:chat_material3/features/calls/presentation/screens/calls_history_screen.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/screens/group_info_screen.dart';
import 'package:chat_material3/features/groups/presentation/screens/selected_group_chat_screen.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/single_chat_screen.dart';
import 'package:chat_material3/features/groups/presentation/widgets/media_links_docs_screen.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/chat_home_screen.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/contact_info_screen.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/new_chat_screen.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/screens/status_screen.dart';
import 'package:chat_material3/features/status/presentation/screens/status_viewer_screen.dart';
import 'package:chat_material3/features/splash/presentation/screens/splash_screen.dart';
import 'package:chat_material3/features/status/presentation/screens/text_status_screen.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:chat_material3/features/main/presentation/screens/main_screen.dart';
import 'package:chat_material3/features/profile/presentation/screens/change_password_screen.dart';
import 'package:chat_material3/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:chat_material3/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_material3/core/app/upload_image/cubit/upload_image_cubit.dart';
import 'package:chat_material3/core/common/screens/custom_web_view.dart';
import 'package:chat_material3/core/common/screens/under_build_screen.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/routes/base_routes.dart';

class AppRoutes {
  static const String splash = 'splash';
  static const String logIn = 'login';
  static const String signUp = 'signUp';
  static const String forgetPassword = 'forgetPassword';
  static const String mainScreen = 'mainScreen';
  static const String chats = 'chats';
  static const String mediaLinksDocs = 'mediaLinksDocs';
  static const String mainCustomer = 'main-screen';
  static const String webview = 'webView';
  static const String profile = 'profile';
  static const String groupInfo = 'groupInfo';
  static const String editProfile = 'editProfile';
  static const String productDetails = 'product-details';
  static const String customerCategories = 'customerCategories';
  static const String customerProductsViewAll = 'customerProductsViewAll';
  static const String customerSearch = 'customerSearch';
  static const String security = 'security';
  static const String selectedGroupChat = 'selectedGroup';
  static const String singleChat = 'singleChat';
  static const String status = 'status';
  static const String textStatus = 'textStatus';
  static const String statusViewer = 'statusViewer';
  static const String callScreen = 'callScreen';
  static const String callsHistoryScreen = 'callsHistoryScreen';
  static const String newChat = 'newChat';
  static const String contactInfo = 'contactInfo';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case splash:
        return BaseRoute(page: const SplashScreen());
      case logIn:
        return BaseRoute(
          page: BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const LoginScreen(),
          ),
        );
      case signUp:
        return BaseRoute(
          page: BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const SignUpScreen(),
          ),
        );
      case mainScreen:
        return BaseRoute(
          page: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => sl<ChatsCubit>()
                  ..getChats(currentUserId: getCurrentUser().uid),
              ),
              BlocProvider(
                create: (context) => sl<CreateChatCubit>(),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => sl<MainCubit>(),
                ),
                BlocProvider(
                  create: (context) => sl<ChatsCubit>(),
                ),
              ],
              child: const MainScreen(),
            ),
          ),
        );

      case forgetPassword:
        return BaseRoute(
          page: BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const ForgetPasswordScreen(),
          ),
        );
      case chats:
        return BaseRoute(
            page: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<ChatsCubit>()
                ..getChats(currentUserId: getCurrentUser().uid),
            ),
            BlocProvider(
              create: (context) => sl<CreateChatCubit>(),
            ),
          ],
          child: const ChatHomeScreen(),
        ));
      case profile:
        return BaseRoute(
          page: Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: const ProfileScreen(),
          ),
        );
      case editProfile:
        return BaseRoute(
          page: BlocProvider(
            create: (context) => sl<UploadImageCubit>(),
            child: const EditProfileScreen(),
          ),
        );
      case security:
        return BaseRoute(
          page: BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const ChangePasswordScreen(),
          ),
        );
      case selectedGroupChat:
        return BaseRoute(
          page: SelectedGroupChatScreen(
            group: args as GroupModel,
          ),
        );
      case singleChat:
        return BaseRoute(
          page: SingleChatScreen(chat: args as ChatModel),
          settings: settings,
        );

      case status:
        return BaseRoute(page: const StatusScreen());

      case textStatus:
        return BaseRoute(page: const TextStatusScreen());

      case statusViewer:
        return BaseRoute(
          page: BlocProvider(
            create: (_) => sl<MyStatusCubit>()..subscribe(getCurrentUser().uid),
            child: const StatusViewerScreen(),
          ),
          settings: settings,
        );

      case callScreen:
        return BaseRoute(
          page: CallScreen(call: args as CallModel),
          settings: settings,
        );

      case callsHistoryScreen:
        return BaseRoute(
          page: const CallsHistoryScreen(),
        );

      case newChat:
        return BaseRoute(
          page: const NewChatScreen(),
        );
      case contactInfo:
        final map = args as Map<String, dynamic>;
        return BaseRoute(
          page: BlocProvider.value(
            value: map['blockCubit'] as BlockCubit,
            child: ContactInfoScreen(
              chat: map['chat'] as ChatModel?,
              friendDisplayName: map['friendDisplayName'] as String,
              friendId: map['friendId'] as String,
            ),
          ),
        );
      case groupInfo:
        return BaseRoute(
          page: GroupInfoScreen(
            group: args as GroupModel,
          ),
        );
      case webview:
        return BaseRoute(
          page: CustomWebView(
              url:
                  'https://app.base44.com/apps/6a096bcfed54bde6a22d65ef/editor/preview'),
        );

      default:
        return BaseRoute(page: const PageUnderBuildScreen());
    }
  }
}
