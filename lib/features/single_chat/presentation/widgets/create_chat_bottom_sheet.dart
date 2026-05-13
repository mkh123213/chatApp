import 'package:chat_material3/constants/app_images.dart';
import 'package:chat_material3/core/common/widgets/app_back_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/create_chat_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

class CreateChatBottomSheet extends StatefulWidget {
  const CreateChatBottomSheet({super.key});

  @override
  State<CreateChatBottomSheet> createState() => _CreateChatBottomSheetState();
}

class _CreateChatBottomSheetState extends State<CreateChatBottomSheet> {
  late final TextEditingController _emailCon;
  late final ValueNotifier<AutovalidateMode> _notifier;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _emailCon = TextEditingController();
    _notifier = ValueNotifier(AutovalidateMode.disabled);
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailCon.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AppBackButton(),
              widthspace(width: 20),
              TextApp(
                text: context.translate(LangKeys.createChat),
                theme: Theme.of(context).textTheme.titleLarge!,
              ),
            ],
          ),
          highspace(height: 16),
          Row(
            children: [
              TextApp(
                text: context.translate(LangKeys.enterFriendEmail),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () {},
                icon: const Icon(Iconsax.scan_barcode),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _notifier,
            builder: (context, value, child) => Form(
              key: _formKey,
              autovalidateMode: value,
              child: CustomTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translate(LangKeys.pleaseEnterEmail);
                  } else if (!AppRegex.isEmailValid(value)) {
                    return context.translate(LangKeys.pleaseEnterValidEmail);
                  }
                  return null;
                },
                controller: _emailCon,
                hintText: context.translate(LangKeys.friendEmail),
                prefixIcon: const Icon(Iconsax.user),
              ),
            ),
          ),
          highspace(height: 16),
          CreateChatBlocConsumer(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<CreateChatCubit>().createChat(
                      currentUserId: getCurrentUser().uid,
                      currentUserEmail: getCurrentUser().email ?? '',
                      friendEmail: _emailCon.text.trim(),
                    );
              } else {
                _notifier.value = AutovalidateMode.always;
              }
            },
          ),
        ],
      ),
    );
  }
}
