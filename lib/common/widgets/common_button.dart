import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';


class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Size? minimumSize;
  final Color? backgroundColor;
  final Color? textColor;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.minimumSize,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            foregroundColor: WidgetStateProperty.all(textColor),
            minimumSize: WidgetStateProperty.all(minimumSize),
          ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppColors.surfaceWhite,
                strokeWidth: 2,
              ),
            )
          : Text(text),
    );
  }
}

class CommonOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Size? minimumSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const CommonOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.minimumSize,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.all(backgroundColor),
            foregroundColor: WidgetStateProperty.all(textColor),
            side: WidgetStateProperty.all(
              borderColor != null ? BorderSide(color: borderColor!) : null,
            ),
            minimumSize: WidgetStateProperty.all(minimumSize),
          ),
      child: Text(text),
    );
  }
}
