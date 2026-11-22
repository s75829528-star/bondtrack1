import 'package:flutter/material.dart';
import 'package:bondtrack/core/widgets/page_header.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const [],
    this.header,
    this.showBack = false,
    this.onBack,
    this.leading,
    required this.child,
    this.fab,
    this.maxWidth = 1160,
    this.horizontalPadding,
    this.bottomPadding = 120,
  });

  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget> actions;
  final Widget? header;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget child;
  final Widget? fab;
  final double maxWidth;
  final double? horizontalPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: fab,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final padding = horizontalPadding ?? (wide ? 32.0 : 20.0);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    wide ? 26 : 16,
                    padding,
                    bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (header != null)
                        header!
                      else if (title != null)
                        PageHeader(
                          title: title!,
                          subtitle: subtitle,
                          eyebrow: eyebrow,
                          actions: actions,
                          showBack: showBack,
                          onBack: onBack,
                          leading: leading,
                        ),
                      const SizedBox(height: 22),
                      child,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
