import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/router/app_router.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/features/notifications/data/notification_service.dart';
import 'package:bondtrack/features/security/data/app_lock_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: BondTrackApp()));
}

class BondTrackApp extends ConsumerWidget {
  const BondTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'BondTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          _NotificationBootstrap(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Keeps durable in-app reminders and Android notifications in sync whenever
/// bond, schedule or notification preferences change. Android permission is
/// never requested without an explicit user action in Settings.
class _NotificationBootstrap extends ConsumerStatefulWidget {
  const _NotificationBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<_NotificationBootstrap>
    with WidgetsBindingObserver {
  bool _running = false;
  bool _pending = false;
  bool _launchHandled = false;
  bool? _lockConfigured;
  bool _locked = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final settings = ref.read(settingsProvider).valueOrNull;
      if (settings?.appLockEnabled ?? false) {
        setState(() => _locked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bondsProvider, (previous, next) => _sync());
    ref.listen(schedulesProvider, (previous, next) => _sync());
    ref.listen(settingsProvider, (previous, next) => _sync());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_locked)
            _AppLockOverlay(
              onUnlocked: () {
                if (mounted) setState(() => _locked = false);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _sync() async {
    if (_running) {
      _pending = true;
      return;
    }
    final bonds = ref.read(bondsProvider).valueOrNull;
    final schedules = ref.read(schedulesProvider).valueOrNull;
    final settings = ref.read(settingsProvider).valueOrNull;
    if (bonds == null || schedules == null || settings == null) return;
    if (_lockConfigured == null) {
      _lockConfigured = settings.appLockEnabled;
      if (settings.appLockEnabled && mounted) {
        setState(() => _locked = true);
      } else if (mounted) {
        setState(() => _locked = false);
      }
    } else if (!settings.appLockEnabled && _lockConfigured == true) {
      _lockConfigured = false;
      if (mounted) setState(() => _locked = false);
    } else if (settings.appLockEnabled && _lockConfigured != true) {
      _lockConfigured = true;
      if (mounted) setState(() => _locked = true);
    }
    _running = true;
    try {
      final service = NotificationService(
        ref.read(notificationRepositoryProvider),
      );
      service.onPayload = _openPayload;
      await service.initialise();
      await service.refreshReminders(
        bonds: bonds,
        schedules: schedules,
        settings: settings,
        permissionGranted: settings.systemNotifications,
      );
      final launchPayload = service.launchPayload;
      if (launchPayload != null && !_launchHandled) {
        _launchHandled = true;
        _openPayload(launchPayload);
      }
    } catch (_) {
      // Reminder failures must not prevent local portfolio access.
    } finally {
      _running = false;
      if (_pending) {
        _pending = false;
        await _sync();
      }
    }
  }

  void _openPayload(String payload) {
    final match = RegExp(r'^bond:(\d+)$').firstMatch(payload.trim());
    if (match == null) return;
    final id = int.tryParse(match.group(1)!);
    if (id == null) return;
    final router = ref.read(appRouterProvider);
    router.push('/bonds/$id');
  }
}

class _AppLockOverlay extends StatefulWidget {
  const _AppLockOverlay({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends State<_AppLockOverlay> {
  final _pin = TextEditingController();
  final _service = AppLockService();
  bool _busy = false;
  String? _error;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _loadBiometrics() async {
    final available = await _service.canUseBiometrics();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _unlockWithPin() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final valid = await _service.verifyPin(_pin.text);
    if (!mounted) return;
    if (valid) {
      widget.onUnlocked();
    } else {
      setState(() {
        _busy = false;
        _error = 'Incorrect PIN. Try again.';
        _pin.clear();
      });
    }
  }

  Future<void> _unlockWithBiometric() async {
    setState(() => _busy = true);
    final valid = await _service.authenticateBiometric();
    if (!mounted) return;
    if (valid) {
      widget.onUnlocked();
    } else {
      setState(() {
        _busy = false;
        _error = 'Biometric verification was not completed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock BondTrack',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pin,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    onSubmitted: (_) => _unlockWithPin(),
                    decoration: InputDecoration(
                      labelText: 'App PIN',
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _busy ? null : _unlockWithPin,
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Unlock'),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _unlockWithBiometric,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Use biometrics'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
