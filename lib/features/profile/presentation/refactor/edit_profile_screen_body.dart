import 'package:chat_material3/features/groups/presentation/widgets/user_avatar_image.dart';
import 'package:chat_material3/features/profile/presentation/widgets/edit_profile/edit_profile_form.dart';
import 'package:flutter/material.dart';

class EditProfileScreenBody extends StatefulWidget {
  const EditProfileScreenBody({super.key});

  @override
  State<EditProfileScreenBody> createState() => _EditProfileScreenBodyState();
}

class _EditProfileScreenBodyState extends State<EditProfileScreenBody> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const UserAvararImage(),
        const SizedBox(height: 20),
        EditProfileForm(formKey: formKey),
      ],
    );
  }
}
