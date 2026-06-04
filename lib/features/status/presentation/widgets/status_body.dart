import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/status/presentation/widgets/create_status_bottom_sheet.dart';
import 'package:chat_material3/features/status/presentation/widgets/my_status_card.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_bloc_consumer.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBody extends StatelessWidget {
  const StatusBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusSectionHeader(
              title: context.translate(LangKeys.statusMyStatus),
            ),
            const MyStatusCard(),
            Divider(
              height: 1,
              color: context.color.outlineVariant,
              indent: 12.w,
              endIndent: 12.w,
            ),
            const StatusBlocConsumer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateStatusSheet(context),
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
