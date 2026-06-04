import 'dart:convert';

import 'package:chat_material3/core/app/upload_image/cubit/upload_image_cubit.dart';
import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/style/images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserAvararImage extends StatelessWidget {
  const UserAvararImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomFadeInDown(
      duration: 500,
      child: BlocConsumer<UploadImageCubit, UploadImageState>(
        listener: (context, state) {
          state.whenOrNull(success: () {
            SharedPref().setString(
              PrefKeys.currentUserUrl,
              context.read<UploadImageCubit>().getImageUrl,
            );

            ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.imageUploadedSuccessfully),
              seconds: 2,
            );
          }, removeImage: (removeImage) {
            ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.imageRemoved),
              seconds: 2,
            );
          }, error: (errorMessage) {
            ShowToast.showToastErrorTop(
              message: errorMessage,
            );
          });
        },
        builder: (context, state) {
          final isImageUploaded =
              context.read<UploadImageCubit>().getImageUrl.isNotEmpty;
          return state.maybeWhen(
            loading: () {
              return CircleAvatar(
                radius: 38,
                backgroundImage: const AssetImage(AppImages.userAvatar),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.color.primary,
                  ),
                ),
              );
            },
            orElse: () {
              return CircleAvatar(
                radius: 38,
                backgroundImage: SharedPref()
                            .getString(PrefKeys.currentUserUrl) !=
                        null
                    ? NetworkImage(
                            SharedPref().getString(PrefKeys.currentUserUrl)!)
                        as ImageProvider
                    : const AssetImage(AppImages.userAvatar),
                backgroundColor: Colors.grey.withOpacity(.1),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // remove image
                    if (isImageUploaded)
                      Positioned(
                        top: -15,
                        right: -15,
                        child: IconButton(
                          onPressed: () {
                            context.read<UploadImageCubit>().removeImage();
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isImageUploaded
                            ? Colors.transparent
                            : Colors.black.withOpacity(0.4),
                      ),
                    ),

                    //take image
                    if (isImageUploaded)
                      const SizedBox.shrink()
                    else
                      IconButton(
                        onPressed: () {
                          context.read<UploadImageCubit>().uploadImage();
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
