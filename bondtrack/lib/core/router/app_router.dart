import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/router/app_shell.dart';
import 'package:bondtrack/features/analytics/presentation/analytics_page.dart';
import 'package:bondtrack/features/bonds/presentation/bond_detail_page.dart';
import 'package:bondtrack/features/bonds/presentation/bond_form_page.dart';
import 'package:bondtrack/features/bonds/presentation/bonds_page.dart';
import 'package:bondtrack/features/calendar/presentation/calendar_page.dart';
import 'package:bondtrack/features/dashboard/presentation/dashboard_page.dart';
import 'package:bondtrack/features/import_export/presentation/import_page.dart';
import 'package:bondtrack/features/maturity/presentation/maturity_page.dart';
import 'package:bondtrack/features/more/presentation/more_page.dart';
import 'package:bondtrack/features/notifications/presentation/notifications_page.dart';
import 'package:bondtrack/features/payments/presentation/payments_page.dart';
import 'package:bondtrack/features/settings/presentation/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _page(state, const DashboardPage()),
          ),
          GoRoute(
            path: '/bonds',
            pageBuilder: (context, state) => _page(state, const BondsPage()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (context, state) =>
                    _page(state, const BondFormPage()),
              ),
              GoRoute(
                path: ':bondId',
                pageBuilder: (context, state) => _page(
                  state,
                  BondDetailPage(
                    bondId: int.tryParse(state.pathParameters['bondId']!) ?? -1,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _page(
                      state,
                      BondFormPage(
                        bondId:
                            int.tryParse(state.pathParameters['bondId']!) ?? -1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => _page(state, const CalendarPage()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) =>
                _page(state, const AnalyticsPage()),
          ),
          GoRoute(
            path: '/payments',
            pageBuilder: (context, state) => _page(state, const PaymentsPage()),
          ),
          GoRoute(
            path: '/maturity',
            pageBuilder: (context, state) => _page(state, const MaturityPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _page(state, const SettingsPage()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) =>
                _page(state, const NotificationsPage()),
          ),
          GoRoute(
            path: '/import',
            pageBuilder: (context, state) => _page(state, const ImportPage()),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => _page(state, const MorePage()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.route_outlined, size: 44),
                const SizedBox(height: 14),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('This page is not part of BondTrack.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.015, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
