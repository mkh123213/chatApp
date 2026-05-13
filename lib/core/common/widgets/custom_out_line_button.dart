import 'package:flutter/material.dart';

class CustomOutLineButton extends StatelessWidget {
  const CustomOutLineButton(
      {super.key, required this.onPressed, required this.child});
  final VoidCallback onPressed;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
