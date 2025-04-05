import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Function()? onTap;
  final double? width;
  final double? height;
  final Border? border;
  final EdgeInsetsGeometry? margin;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
    this.border,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    final card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border ?? Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  blurRadius: elevation! * 3,
                  spreadRadius: 0,
                  offset: Offset(0, elevation! / 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: elevation!,
                  spreadRadius: 0,
                  offset: Offset(0, elevation! / 3),
                ),
              ]
            : null,
        gradient: backgroundColor == null ? 
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0.03),
              ],
              stops: const [0.1, 1.0],
            ) : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          splashColor: AppTheme.accentColor.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: card,
        ),
      );
    }

    return Container(
      margin: margin,
      child: card,
    );
  }
}
