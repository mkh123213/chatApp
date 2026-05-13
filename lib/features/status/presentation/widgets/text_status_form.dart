import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _palette = [
  Color(0xFF1a73e8),
  Color(0xFF34a853),
  Color(0xFFfbbc05),
  Color(0xFFea4335),
  Color(0xFF9334e6),
  Color(0xFF000000),
];

class TextStatusForm extends StatefulWidget {
  const TextStatusForm({super.key});

  @override
  State<TextStatusForm> createState() => _TextStatusFormState();
}

class _TextStatusFormState extends State<TextStatusForm> {
  late final TextEditingController _controller;
  Color _selectedColor = _palette.first;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()
      ..addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: CustomTextField(
              controller: _controller,
              hintText: context.translate(LangKeys.statusTextHint),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              filled: false,
            ),
          ),
        ),
        _ColorPalette(
          selected: _selectedColor,
          onSelect: (color) => setState(() => _selectedColor = color),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Opacity(
            opacity: _hasText ? 1.0 : 0.4,
            child: CustomLinearButton(
              height: 52.h,
              onPressed: _hasText ? _submit : () {},
              child: TextApp(
                text: context.translate(LangKeys.statusCreate),
                theme: context.textStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeightHelper.medium,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final colorHex =
        '0x${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    context.read<CreateStatusCubit>().createTextStatus(
          text: text,
          backgroundColor: colorHex,
        );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.selected, required this.onSelect});

  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: _palette.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, index) {
          final color = _palette[index];
          final isSelected = color == selected;
          return GestureDetector(
            onTap: () => onSelect(color),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
