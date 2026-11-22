import 'package:flutter/material.dart';
import 'package:bondtrack/core/theme/app_theme.dart';

/// Elevated surface used throughout the app. Subtle border + soft shadow,
/// optional gradient, and full ripple support.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.gradient,
    this.color,
    this.borderColor,
    this.radius = 20,
    this.shadow = true,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool shadow;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final resolvedColor = color ?? context.cardColor;
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? resolvedColor : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? scheme.outline),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: context.isDark
                      ? Colors.black.withValues(alpha: 0.24)
                      : const Color(0x0D0B1F3A),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: 0.06),
          highlightColor: scheme.primary.withValues(alpha: 0.03),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
