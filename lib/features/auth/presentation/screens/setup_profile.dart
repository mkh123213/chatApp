import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  @override
  Widget build(BuildContext context) {
    TextEditingController nameCon = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Iconsax.logout_1))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                "Welcome,",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                "Nabil AL Amawi Course",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "Please Enter Your Name",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              CustomTextField(
                controller: nameCon,
                hintText: context.translate(LangKeys.name),
                prefixIcon: Icon(Iconsax.user),
              ),
              const SizedBox(
                height: 16,
              ),
              // button
              CustomLinearButton(
                onPressed: () {},
                child: Center(
                  child: TextApp(
                    text: context.translate(LangKeys.continuo),
                    theme: context.textStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
