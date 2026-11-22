import 'package:flutter/material.dart';
import 'package:bondtrack/core/theme/app_theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const [],
    this.showBack = false,
    this.onBack,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!.toUpperCase(),
                      style: context.texts.labelSmall?.copyWith(
                        color: context.scheme.primary,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(title, style: context.texts.headlineLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle!,
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.mutedColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: 8),
              Wrap(spacing: 8, children: actions),
            ],
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20)),
      ),
    );
  }
}
