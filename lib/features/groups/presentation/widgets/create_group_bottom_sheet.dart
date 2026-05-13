import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/create_group_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _membersEmailsController =
      TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    _membersEmailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateGroupCubit>(
      create: (_) => sl<CreateGroupCubit>(),
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextApp(
                text: context.translate(LangKeys.createGroup),
                theme: context.textStyle),
            CustomTextField(
                prefixIcon: Icon(Iconsax.group),
                hintText: context.translate(LangKeys.groupName),
                controller: _groupNameController),
            highspace(height: 20),
            CustomTextField(
                prefixIcon: Icon(Iconsax.sms),
                hintText: context.translate(LangKeys.membersEmails),
                controller: _membersEmailsController),
            highspace(height: 20),
            CreateGroupBlocConsumer(
                groupNameController: _groupNameController,
                membersEmailsController: _membersEmailsController),
          ],
        ),
      ),
    );
  }
}
