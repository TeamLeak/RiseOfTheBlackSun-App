import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonType { primary, secondary, text, accent }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool disabled;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
    this.disabled = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonContent =
        isLoading
            ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );

    final buttonStyle = getButtonStyle(context);

    return SizedBox(
      width: width,
      height: height,
      child:
          type == ButtonType.text
              ? TextButton(
                onPressed: disabled || isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonContent,
              )
              : type == ButtonType.secondary
              ? OutlinedButton(
                onPressed: disabled || isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonContent,
              )
              : ElevatedButton(
                onPressed: disabled || isLoading ? null : onPressed,
                style: buttonStyle,
                child: buttonContent,
              ),
    );
  }

  ButtonStyle getButtonStyle(BuildContext context) {
    Theme.of(context);
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppTheme.accentColor,
          disabledBackgroundColor: AppTheme.accentColor.withAlpha(128),
          disabledForegroundColor: Colors.black54,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        );
      case ButtonType.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          side: BorderSide(color: AppTheme.accentColor),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        );
      case ButtonType.accent:
        return ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withAlpha(128),
          disabledForegroundColor: Colors.white70,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        );
    }
  }
}
