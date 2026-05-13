import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_family_helper.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/bloc/status_cubit/status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<StatusCubit>()..subscribe(getCurrentUser().uid),
        ),
        BlocProvider(
          create: (_) => sl<MyStatusCubit>()..subscribe(getCurrentUser().uid),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.color.surface,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => ZoomDrawer.of(context)?.toggle(),
            icon: Icon(Icons.menu, color: context.color.onSurface),
          ),
          title: Text(
            context.translate(LangKeys.statusTitle),
            style: context.textStyle.copyWith(
              fontSize: 20.sp,
              fontFamily: FontFamilyHelper.poppinsEnglish,
              fontWeight: FontWeightHelper.bold,
              color: context.color.onSurface,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: context.color.onSurface),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _ProfileAvatar(),
            ),
          ],
        ),
        body: const StatusBody(),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = getCurrentUser();
    final photoUrl = user.photoUrl;
    return CircleAvatar(
      radius: 16.r,
      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
          ? CachedNetworkImageProvider(photoUrl)
          : null,
      backgroundColor: context.color.tertiary,
      child: photoUrl == null || photoUrl.isEmpty
          ? Icon(Icons.person, size: 18.sp, color: Colors.white)
          : null,
    );
  }
}
