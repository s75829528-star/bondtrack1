import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/widgets/brand_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = <_NavItem>[
    _NavItem(
      path: '/',
      label: 'Home',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _NavItem(
      path: '/bonds',
      label: 'Bonds',
      icon: Icons.account_balance_outlined,
      selectedIcon: Icons.account_balance_rounded,
    ),
    _NavItem(
      path: '/calendar',
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _NavItem(
      path: '/analytics',
      label: 'Insights',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
    _NavItem(
      path: '/more',
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
  ];

  int _indexFor(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/bonds')) return 1;
    if (path.startsWith('/calendar')) return 2;
    if (path.startsWith('/analytics')) return 3;
    if (path.startsWith('/payments') ||
        path.startsWith('/maturity') ||
        path.startsWith('/settings') ||
        path.startsWith('/more')) {
      return 4;
    }
    return 0;
  }

  void _go(BuildContext context, int index) {
    final path = _destinations[index].path;
    if (GoRouterState.of(context).uri.path != path) {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _indexFor(path);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  right: false,
                  child: NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: (value) => _go(context, value),
                    labelType: NavigationRailLabelType.all,
                    minWidth: 84,
                    leading: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 18),
                      child: BrandMark(size: 36, showWordmark: false),
                    ),
                    trailing: Expanded(
                      child: Column(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: IconButton(
                              tooltip: 'Settings',
                              onPressed: () => context.go('/settings'),
                              icon: Icon(
                                Icons.settings_outlined,
                                color: context.mutedColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: context.borderColor),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => _go(context, value),
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
