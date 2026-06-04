import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_image_viewer.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaLinksDocsScreen extends StatelessWidget {
  const MediaLinksDocsScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final repo = sl<GroupsRepo>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.color.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: context.color.surfaceContainerLowest,
          elevation: 0.5,
          shadowColor: context.color.outlineVariant,
          iconTheme: IconThemeData(color: context.color.primary),
          title: Text(
            'Media, Links & Docs',
            style: TextStyle(
              color: context.color.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: context.color.primary,
            unselectedLabelColor: context.color.onSurfaceVariant,
            indicatorColor: context.color.primary,
            tabs: const [
              Tab(text: 'Media'),
              Tab(text: 'Links'),
              Tab(text: 'Docs'),
            ],
          ),
        ),
        body: StreamBuilder<List<GroupMessageModel>>(
          stream: repo.getGroupMessages(groupId: groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final messages = snapshot.data ?? <GroupMessageModel>[];

            final media = messages
                .where((m) => m.type == GroupMessageType.image)
                .toList();

            final links = messages
                .where((m) =>
                    m.type == GroupMessageType.link || _isLink(m.text))
                .toList();

            final docs = messages
                .where((m) => m.type == GroupMessageType.file)
                .toList();

            return TabBarView(
              children: [
                _MediaTab(messages: media),
                _LinksTab(messages: links),
                _DocsTab(messages: docs),
              ],
            );
          },
        ),
      ),
    );
  }

  static bool _isLink(String value) {
    final text = value.trim().toLowerCase();

    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }
}

class _LinksTab extends StatelessWidget {
  const _LinksTab({required this.messages});

  final List<GroupMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _EmptyTab(
        icon: Icons.link,
        title: 'No links yet',
        subtitle: 'Links sent in chat will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: messages.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final message = messages[i];

        final time = message.createdAt == null
            ? ''
            : DateFormat('MMM d, h:mm a').format(message.createdAt!);

        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.link,
                  color: context.color.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.color.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time.isEmpty
                          ? message.senderEmail
                          : '${message.senderEmail} • $time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MediaTab extends StatelessWidget {
  const _MediaTab({required this.messages});

  final List<GroupMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _EmptyTab(
        icon: Icons.image_outlined,
        title: 'No media yet',
        subtitle: 'Photos and videos sent in chat will appear here.',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(8.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.h,
      ),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final url = messages[i].fileUrl ?? '';
        return GestureDetector(
          onTap: () => openChatImageViewer(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          ),
        );
      },
    );
  }
}

class _DocsTab extends StatelessWidget {
  const _DocsTab({required this.messages});

  final List<GroupMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _EmptyTab(
        icon: Icons.insert_drive_file_outlined,
        title: 'No docs yet',
        subtitle: 'Documents sent in chat will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: messages.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, i) {
        final message = messages[i];
        final time = message.createdAt == null
            ? ''
            : DateFormat('MMM d, h:mm a').format(message.createdAt!);

        return GestureDetector(
          onTap: () async {
            final uri = Uri.tryParse(message.fileUrl ?? '');
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: context.color.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: context.color.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.insert_drive_file_outlined,
                    color: context.color.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.fileName ?? 'File',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.color.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        time.isEmpty
                            ? message.senderEmail
                            : '${message.senderEmail} • $time',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: context.color.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
