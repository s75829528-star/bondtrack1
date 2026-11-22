import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/domain/entities/app_settings.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/entities/interest_schedule.dart';
import 'package:bondtrack/features/notifications/data/notification_service.dart';
import 'package:bondtrack/features/settings/data/backup_restore_service.dart';
import 'package:bondtrack/features/security/data/app_lock_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<bool> _update(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    try {
      await ref.read(settingsRepositoryProvider).save(settings);
      if (context.mounted) showAppSnackBar(context, 'Settings saved.');
      return true;
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Could not save settings: $error',
          error: true,
        );
      }
      return false;
    }
  }

  Future<void> _toggleSystemNotifications(
    BuildContext context,
    WidgetRef ref,
    AppSettings current,
  ) async {
    final service = NotificationService(
      ref.read(notificationRepositoryProvider),
    );
    final granted = await service.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      showAppSnackBar(
        context,
        'Notification permission was not granted. Enable it in Android Settings to receive reminders.',
        error: true,
      );
      return;
    }
    await _update(
      context,
      ref,
      current.copyWith(systemNotifications: true, remindersEnabled: true),
    );
    if (!context.mounted) return;
    await _refreshReminders(ref, service);
  }

  Future<void> _editReminderOffsets(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings, {
    required bool maturity,
  }) async {
    final values = maturity ? const [30, 15, 7, 1, 0] : const [7, 3, 1, 0];
    final selected = <int>{
      ...(maturity
          ? settings.maturityReminderDays
          : settings.interestReminderDays),
    };
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            maturity
                ? 'Maturity reminder offsets'
                : 'Interest reminder offsets',
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final days in values)
                FilterChip(
                  label: Text(days == 0 ? 'Due day' : '$days days'),
                  selected: selected.contains(days),
                  onSelected: (value) => setDialogState(() {
                    if (value) {
                      selected.add(days);
                    } else {
                      selected.remove(days);
                    }
                  }),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () => Navigator.pop(
                      dialogContext,
                      (selected.toList()..sort((a, b) => b.compareTo(a))).join(
                        ',',
                      ),
                    ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !context.mounted) return;
    await _update(
      context,
      ref,
      maturity
          ? settings.copyWith(maturityReminderOffsets: result)
          : settings.copyWith(interestReminderOffsets: result),
    );
  }

  Future<void> _refreshReminders(
    WidgetRef ref,
    NotificationService service,
  ) async {
    final settings = await ref.read(settingsRepositoryProvider).get();
    final bonds = ref.read(bondsProvider).valueOrNull ?? <Bond>[];
    final schedules =
        ref.read(schedulesProvider).valueOrNull ?? <InterestSchedule>[];
    await service.refreshReminders(
      bonds: bonds,
      schedules: schedules,
      settings: settings,
      permissionGranted: settings.systemNotifications,
    );
  }

  Future<void> _setAppLock(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool enabled,
  ) async {
    final lock = AppLockService();
    try {
      if (enabled) {
        final pin = await _promptPin(context);
        if (pin == null) return;
        await lock.setPin(pin);
      } else {
        final pin = await _promptPin(context, title: 'Confirm current PIN');
        if (pin == null) return;
        if (!await lock.verifyPin(pin)) {
          if (context.mounted) {
            showAppSnackBar(context, 'That PIN is incorrect.', error: true);
          }
          return;
        }
      }
      if (!context.mounted) return;
      final saved = await _update(
        context,
        ref,
        settings.copyWith(appLockEnabled: enabled),
      );
      if (saved && !enabled) await lock.clearPin();
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Could not update app lock: $error',
          error: true,
        );
      }
    }
  }

  Future<String?> _promptPin(
    BuildContext context, {
    String title = 'Set a 4–8 digit app PIN',
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 8,
          decoration: const InputDecoration(
            labelText: 'PIN',
            helperText: 'Only a salted hash is stored securely on this device.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!RegExp(r'^\d{4,8}$').hasMatch(controller.text)) return;
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final encrypt = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Protect your backup?'),
          content: const Text(
            'Encrypted backups use a password with AES-256-GCM. Keep the password safe; it cannot be recovered.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No encryption'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Encrypt'),
            ),
          ],
        ),
      );
      if (encrypt == null) return;
      if (!context.mounted) return;
      final password = encrypt
          ? await _promptBackupPassword(context, confirm: true)
          : null;
      if (encrypt && password == null) return;
      final backupService = BackupRestoreService(ref.read(databaseProvider));
      await backupService.createLocalBackup(password: password);
      final bytes = await backupService.createBackup(password: password);
      final uri = await FilePicker.saveFile(
        fileName: 'bondtrack-backup-${Money.isoDate(DateTime.now())}.json',
        bytes: bytes,
        mimeType: 'application/json',
        dialogTitle: 'Save BondTrack backup',
      );
      if (uri != null) {
        await ref
            .read(settingsRepositoryProvider)
            .setLastBackupAt(DateTime.now());
      }
      if (context.mounted) {
        showAppSnackBar(
          context,
          uri == null ? 'Backup cancelled.' : 'Backup saved successfully.',
        );
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, 'Backup failed: $error', error: true);
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    try {
      final backupService = BackupRestoreService(ref.read(databaseProvider));
      final useLocal = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Choose backup source'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const ListTile(
                leading: Icon(Icons.folder_open_rounded),
                title: Text('Choose a backup file'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const ListTile(
                leading: Icon(Icons.phone_android_rounded),
                title: Text('Local snapshots on this device'),
              ),
            ),
          ],
        ),
      );
      if (useLocal == null || !context.mounted) return;
      late final Uint8List bytes;
      if (useLocal) {
        final backups = await backupService.listLocalBackups();
        if (!context.mounted) return;
        if (backups.isEmpty) {
          showAppSnackBar(context, 'No local snapshots are available.');
          return;
        }
        if (!context.mounted) return;
        final selected = await showDialog<LocalBackupFile>(
          context: context,
          builder: (dialogContext) => SimpleDialog(
            title: const Text('Select a local snapshot'),
            children: [
              for (final backup in backups)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, backup),
                  child: ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: Text(backup.name),
                    subtitle: Text(
                      '${Money.dateTime(backup.createdAt)} · ${backup.sizeBytes} bytes',
                    ),
                  ),
                ),
            ],
          ),
        );
        if (selected == null) return;
        bytes = await File(selected.path).readAsBytes();
      } else {
        final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: const ['json'],
          dialogTitle: 'Select a BondTrack backup',
        );
        if (file == null) return;
        bytes = await file.readAsBytes();
      }
      if (bytes.isEmpty) {
        throw const FormatException('Could not read the selected backup.');
      }
      if (!context.mounted) return;
      final password = await _promptBackupPassword(
        context,
        confirm: false,
        optional: true,
      );
      if (password == null) return;
      if (!context.mounted) return;
      final mode = await showDialog<RestoreMode>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Restore backup'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, RestoreMode.merge),
              child: const ListTile(
                leading: Icon(Icons.merge_type_rounded),
                title: Text('Merge into this portfolio'),
                subtitle: Text('Keep current data and skip duplicate bonds'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, RestoreMode.replace),
              child: const ListTile(
                leading: Icon(Icons.delete_forever_outlined),
                title: Text('Replace local portfolio'),
                subtitle: Text('Remove current data before restoring'),
              ),
            ),
          ],
        ),
      );
      if (mode == null || !context.mounted) return;
      if (mode == RestoreMode.replace) {
        final confirmed = await showConfirmDialog(
          context,
          title: 'Replace local portfolio?',
          message: 'Restoring replaces all bonds, schedules, payments and preferences currently on this device.',
          confirmLabel: 'Replace and restore',
          destructive: true,
          icon: Icons.restore_rounded,
        );
        if (!confirmed) return;
      }
      final result = await BackupRestoreService(ref.read(databaseProvider))
          .restore(
            bytes,
            password: password.isEmpty ? null : password,
            mode: mode,
          );
      ref.invalidate(bondsProvider);
      ref.invalidate(schedulesProvider);
      ref.invalidate(paymentsProvider);
      ref.invalidate(settingsProvider);
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Restored ${result.bondsImported} bonds; skipped ${result.duplicatesSkipped} duplicates.',
        );
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, 'Restore failed: $error', error: true);
      }
    }
  }

  Future<String?> _promptBackupPassword(
    BuildContext context, {
    required bool confirm,
    bool optional = false,
  }) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(confirm ? 'Set backup password' : 'Backup password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: optional
                    ? 'Password (leave blank if unencrypted)'
                    : 'Password',
              ),
            ),
            if (confirm)
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                ),
              ),
          ],
        ),
        actions: [
          if (optional)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, ''),
              child: const Text('No password'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final password = passwordController.text;
              if (password.length < 8 ||
                  (confirm && confirmController.text != password)) {
                return;
              }
              Navigator.pop(dialogContext, password);
            },
            child: Text(confirm ? 'Use password' : 'Continue'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    confirmController.dispose();
    if (result == null || result.isEmpty) return result;
    return result;
  }

  Widget _hourDropdown(int value, ValueChanged<int> onChanged) {
    return DropdownButton<int>(
      value: value,
      underline: const SizedBox.shrink(),
      items: [
        for (var hour = 0; hour < 24; hour++)
          DropdownMenuItem(
            value: hour,
            child: Text('${hour.toString().padLeft(2, '0')}:00'),
          ),
      ],
      onChanged: (hour) {
        if (hour != null) onChanged(hour);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsValueProvider);
    final backupLabel = settings.lastBackupAt == null
        ? 'No backup saved on this device yet'
        : 'Last backup ${Money.dateTime(settings.lastBackupAt!)}';

    return AppPage(
      title: 'Settings',
      subtitle: 'Make BondTrack work the way you do',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsSection(
            title: 'Preferences',
            subtitle: 'Currency and appearance',
            icon: Icons.tune_rounded,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Display currency',
                  subtitle: 'INR is used by default',
                  trailing: DropdownButton<String>(
                    value: settings.currencyCode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR · ₹')),
                      DropdownMenuItem(value: 'USD', child: Text('USD · \$')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR · €')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP · £')),
                      DropdownMenuItem(value: 'AED', child: Text('AED · د.إ')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _update(
                          context,
                          ref,
                          settings.copyWith(currencyCode: value),
                        );
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  subtitle: 'Choose light, dark or follow your device',
                  trailing: DropdownButton<AppThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final mode in AppThemeMode.values)
                        DropdownMenuItem(value: mode, child: Text(mode.label)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _update(
                          context,
                          ref,
                          settings.copyWith(themeMode: value),
                        );
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.repeat_rounded,
                  title: 'Default interest frequency',
                  subtitle: 'Used when adding a new bond',
                  trailing: DropdownButton<String>(
                    value: settings.defaultFrequency,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'quarterly',
                        child: Text('Quarterly'),
                      ),
                      DropdownMenuItem(
                        value: 'halfYearly',
                        child: Text('Half-yearly'),
                      ),
                      DropdownMenuItem(value: 'annual', child: Text('Annual')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _update(
                          context,
                          ref,
                          settings.copyWith(defaultFrequency: value),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: 'Reminders',
            subtitle: 'Local notifications for important dates',
            icon: Icons.notifications_active_outlined,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  subtitle: 'Enable in-app and Android notifications',
                  trailing: Switch(
                    value: settings.remindersEnabled,
                    onChanged: (value) {
                      if (!value) {
                        _update(
                          context,
                          ref,
                          settings.copyWith(remindersEnabled: false),
                        );
                      } else if (!settings.systemNotifications) {
                        _toggleSystemNotifications(context, ref, settings);
                      } else {
                        _update(
                          context,
                          ref,
                          settings.copyWith(remindersEnabled: true),
                        );
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.payments_outlined,
                  title: 'Interest payment reminders',
                  subtitle: 'Remind me before a scheduled credit',
                  trailing: Switch(
                    value: settings.interestReminders,
                    onChanged: settings.remindersEnabled
                        ? (value) => _update(
                            context,
                            ref,
                            settings.copyWith(interestReminders: value),
                          )
                        : null,
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.flag_outlined,
                  title: 'Maturity reminders',
                  subtitle: 'Remind me before principal repayment',
                  trailing: Switch(
                    value: settings.maturityReminders,
                    onChanged: settings.remindersEnabled
                        ? (value) => _update(
                            context,
                            ref,
                            settings.copyWith(maturityReminders: value),
                          )
                        : null,
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.alarm_on_outlined,
                  title: 'Interest reminder days',
                  subtitle: settings.interestReminderDays
                      .map((day) => day == 0 ? 'due day' : '$day days')
                      .join(' · '),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _editReminderOffsets(
                    context,
                    ref,
                    settings,
                    maturity: false,
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.event_repeat_outlined,
                  title: 'Maturity reminder days',
                  subtitle: settings.maturityReminderDays
                      .map((day) => day == 0 ? 'due day' : '$day days')
                      .join(' · '),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _editReminderOffsets(
                    context,
                    ref,
                    settings,
                    maturity: true,
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.notification_important_outlined,
                  title: 'Overdue follow-ups',
                  subtitle: 'Follow up 1 and 7 days after an unpaid event',
                  trailing: Switch(
                    value: settings.overdueRemindersEnabled,
                    onChanged: (value) => _update(
                      context,
                      ref,
                      settings.copyWith(overdueRemindersEnabled: value),
                    ),
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.do_not_disturb_on_outlined,
                  title: 'Quiet hours',
                  subtitle: settings.quietHoursEnabled
                      ? '${settings.quietStartHour.toString().padLeft(2, '0')}:00–${settings.quietEndHour.toString().padLeft(2, '0')}:00'
                      : 'Reminders are scheduled at 9:00 AM',
                  trailing: Switch(
                    value: settings.quietHoursEnabled,
                    onChanged: (value) => _update(
                      context,
                      ref,
                      settings.copyWith(quietHoursEnabled: value),
                    ),
                  ),
                ),
                if (settings.quietHoursEnabled) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Quiet start')),
                        _hourDropdown(
                          settings.quietStartHour,
                          (hour) => _update(
                            context,
                            ref,
                            settings.copyWith(quietStartHour: hour),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text('Quiet end'),
                        const SizedBox(width: 8),
                        _hourDropdown(
                          settings.quietEndHour,
                          (hour) => _update(
                            context,
                            ref,
                            settings.copyWith(quietEndHour: hour),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.alarm_outlined,
                  title: 'Reminder lead time',
                  subtitle: '${settings.reminderDays} days before each event',
                  trailing: DropdownButton<int>(
                    value: settings.reminderDays,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Same day')),
                      DropdownMenuItem(value: 1, child: Text('1 day')),
                      DropdownMenuItem(value: 3, child: Text('3 days')),
                      DropdownMenuItem(value: 7, child: Text('7 days')),
                      DropdownMenuItem(value: 14, child: Text('14 days')),
                      DropdownMenuItem(value: 30, child: Text('30 days')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _update(
                          context,
                          ref,
                          settings.copyWith(reminderDays: value),
                        );
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.phone_android_rounded,
                  title: 'Android notifications',
                  subtitle: settings.systemNotifications
                      ? 'Permission granted on this device'
                      : 'Permission not enabled',
                  trailing: settings.systemNotifications
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: context.scheme.primary,
                        )
                      : TextButton(
                          onPressed: () => _toggleSystemNotifications(
                            context,
                            ref,
                            settings,
                          ),
                          child: const Text('Enable'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: 'Your data',
            subtitle: 'Offline, private and under your control',
            icon: Icons.shield_outlined,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.table_chart_outlined,
                  title: 'Excel import & export',
                  subtitle: 'Import bonds or export a workbook',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/import'),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.backup_outlined,
                  title: 'Create full backup',
                  subtitle: 'Bonds, schedules, payments and settings · JSON',
                  trailing: const Icon(Icons.download_outlined),
                  onTap: () => _exportBackup(context, ref),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.restore_rounded,
                  title: 'Restore from backup',
                  subtitle: backupLabel,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _restoreBackup(context, ref),
                ),
                Divider(height: 1, color: context.borderColor),
                _SettingsRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'App lock with PIN',
                  subtitle: settings.appLockEnabled
                      ? 'PIN required when BondTrack is reopened'
                      : 'Protect this portfolio with a local PIN',
                  trailing: Switch(
                    value: settings.appLockEnabled,
                    onChanged: (value) =>
                        _setAppLock(context, ref, settings, value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            shadow: false,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: context.scheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your portfolio stays on this device. BondTrack never requests banking passwords, card numbers or PINs. Keep exported backups in a secure location.',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.mutedColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'BONDTRACK  ·  PERSONAL BOND INVESTMENT MANAGER  ·  v1.0.0',
              textAlign: TextAlign.center,
              style: context.texts.labelSmall?.copyWith(
                color: context.mutedColor,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.scheme.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: context.scheme.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.texts.titleSmall),
                    Text(
                      subtitle,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.mutedColor,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.mutedColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.labelMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: row,
    );
  }
}
