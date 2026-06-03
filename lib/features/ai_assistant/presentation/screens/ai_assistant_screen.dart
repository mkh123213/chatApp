import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/ai_assistant/presentation/bloc/ai_assistant_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  static const _quickPrompts = [
    'Tell me a fun fact 🧠',
    'Write me a joke 😄',
    "What's the weather like on Mars? 🚀",
    'Give me a motivational quote 💪',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: BlocBuilder<AiAssistantCubit, AiAssistantState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (state.messages.length <= 1) _buildQuickPrompts(context),
                  Expanded(child: _buildMessages(context, state)),
                  if (state.isLoading) _buildTypingIndicator(context),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                    child: ChatMessageInput(
                      onSendText: (text) {
                        context.read<AiAssistantCubit>().sendMessage(text);
                      },
                      hintText: 'Message',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withValues(alpha: 0.15),
            context.color.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: const Color(0xFF4CAF50),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant',
                    style: context.textStyle.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '✨ Powered by AI',
                    style: context.textStyle.copyWith(
                      fontSize: 12.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _quickPrompts.map((prompt) {
          return ActionChip(
            label: Text(
              prompt,
              style: TextStyle(fontSize: 13.sp),
            ),
            onPressed: () {
              context.read<AiAssistantCubit>().sendMessage(prompt);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessages(BuildContext context, AiAssistantState state) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[state.messages.length - 1 - index];
        return _AiMessageBubble(message: msg);
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 16.sp,
            color: const Color(0xFF4CAF50),
          ),
          SizedBox(width: 8.w),
          Text(
            'AI Assistant is typing...',
            style: context.textStyle.copyWith(
              fontSize: 12.sp,
              color: const Color(0xFF4CAF50),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeText = DateFormat.jm().format(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 14.sp,
                    color: const Color(0xFF4CAF50),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'AI Assistant',
                    style: context.textStyle.copyWith(
                      fontSize: 12.sp,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isUser
                  ? context.color.primary
                  : context.color.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
                bottomRight: Radius.circular(isUser ? 4.r : 16.r),
              ),
            ),
            child: Text(
              message.text,
              style: context.textStyle.copyWith(
                fontSize: 14.sp,
                color: isUser ? context.color.onPrimary : context.color.onSurface,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            timeText,
            style: context.textStyle.copyWith(
              fontSize: 11.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
