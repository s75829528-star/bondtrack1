import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_colors.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/metric_card.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/core/widgets/section_header.dart';
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/services/spreadsheet_import_service.dart';
import 'package:bondtrack/features/import_export/data/portfolio_spreadsheet_service.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  Uint8List? _bytes;
  String? _fileName;
  List<String> _sheetNames = const [];
  String? _sheetName;
  SpreadsheetTable? _table;
  Map<int, ImportField> _mapping = {};
  ImportPreview? _preview;
  String? _error;
  bool _busy = false;
  int _step = 0;

  Future<void> _pickFile() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        dialogTitle: 'Select your bond portfolio Excel file',
      );
      if (file == null) {
        setState(() => _busy = false);
        return;
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('Could not read the selected file.');
      }
      final names = SpreadsheetImportService.sheetNames(bytes);
      if (names.isEmpty) {
        throw const FormatException('This workbook has no worksheets.');
      }
      setState(() {
        _bytes = bytes;
        _fileName = file.name;
        _sheetNames = names;
        _sheetName = names.first;
        _step = 1;
      });
      await _loadSheet(names.first);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not open this workbook: $error';
        });
      }
    }
  }

  Future<void> _loadSheet(String sheetName) async {
    final bytes = _bytes;
    if (bytes == null) return;
    setState(() {
      _busy = true;
      _sheetName = sheetName;
      _error = null;
      _preview = null;
    });
    try {
      final table = SpreadsheetImportService.readSheet(bytes, sheetName);
      final mapping = SpreadsheetImportService.suggestMapping(table.headers);
      setState(() {
        _table = table;
        _mapping = mapping;
        _step = 2;
      });
      await _buildPreview();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _buildPreview() async {
    final table = _table;
    if (table == null) return;
    setState(() => _busy = true);
    try {
      final repository = ref.read(bondRepositoryProvider);
      final existing = await repository.existingDuplicateKeys();
      final existingBonds = await repository.getAll();
      final preview = SpreadsheetImportService.preview(
        table: table,
        mapping: _mapping,
        existingDuplicateKeys: existing,
        existingBonds: existingBonds,
      );
      if (mounted) {
        setState(() {
          _preview = preview;
          _busy = false;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not validate rows: $error';
        });
      }
    }
  }

  Future<void> _changeMapping(int column, ImportField field) async {
    final mapping = {..._mapping, column: field};
    setState(() => _mapping = mapping);
    await _buildPreview();
  }

  void _toggleRow(int index, bool selected) {
    final preview = _preview;
    if (preview == null) return;
    final rows = [...preview.rows];
    rows[index] = rows[index].copyWith(selected: selected);
    setState(() => _preview = preview.copyWith(rows: rows));
  }

  void _toggleUpdate(int index, bool selected) {
    final preview = _preview;
    if (preview == null) return;
    final rows = [...preview.rows];
    rows[index] = rows[index].copyWith(updateSelected: selected);
    setState(() => _preview = preview.copyWith(rows: rows));
  }

  Future<void> _import() async {
    final preview = _preview;
    if (preview == null || preview.selectedCount == 0) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updates = preview.rows
          .where(
            (row) =>
                row.isValid && row.updateSelected && row.existingBond != null,
          )
          .toList();
      if (updates.isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              'Apply ${updates.length} bond update${updates.length == 1 ? '' : 's'}?',
            ),
            content: const Text(
              'Bond terms will be updated and unpaid schedule entries regenerated. Recorded payment history and bonds not selected for update will be preserved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirm updates'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (confirmed != true) {
          setState(() => _busy = false);
          return;
        }
      }
      final drafts = preview.rows
          .where((row) => row.isValid && row.selected && !row.duplicate)
          .map((row) => row.draft!)
          .toList();
      final updateDrafts = updates.map((row) {
        final old = row.existingBond!;
        return row.draft!.copyWith(
          id: old.id,
          interestMethod: old.interestMethod,
          compoundingFrequency: old.compoundingFrequency,
          dayCountConvention: old.dayCountConvention,
          creditDay: old.creditDay,
          manualInterestPerPeriodPaise: old.manualInterestPerPeriodPaise,
          remindersEnabled: old.remindersEnabled,
          interestReminderOffsets: old.interestReminderOffsets,
          maturityReminderOffsets: old.maturityReminderOffsets,
        );
      }).toList();
      final repository = ref.read(bondRepositoryProvider);
      final imported = await repository.syncImport(
        newBonds: drafts,
        updates: updateDrafts,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _step = 3;
      });
      showAppSnackBar(
        context,
        '$imported new bond${imported == 1 ? '' : 's'} imported; ${updates.length} existing bond${updates.length == 1 ? '' : 's'} updated.',
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Import failed; no records were added: $error';
        });
      }
    }
  }

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bonds = await ref.read(bondRepositoryProvider).getAll();
      final schedules = await ref.read(scheduleRepositoryProvider).getAll();
      final payments = await ref.read(paymentRepositoryProvider).getAll();
      final bytes = PortfolioSpreadsheetService.exportXlsx(
        bonds: bonds,
        schedules: schedules,
        payments: payments,
      );
      final uri = await FilePicker.saveFile(
        fileName: PortfolioSpreadsheetService.exportFileName(),
        bytes: bytes,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        dialogTitle: 'Export BondTrack portfolio',
      );
      if (mounted) {
        showAppSnackBar(
          context,
          uri == null ? 'Export cancelled.' : 'Excel portfolio exported.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _reset() {
    setState(() {
      _bytes = null;
      _fileName = null;
      _sheetNames = const [];
      _sheetName = null;
      _table = null;
      _mapping = {};
      _preview = null;
      _error = null;
      _busy = false;
      _step = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return AppPage(
      showBack: true,
      title: 'Import & export',
      subtitle: 'Bring in an existing portfolio or export a fresh workbook',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumCard(
            gradient: AppColors.navyGradient,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.table_chart_rounded,
                    color: AppColors.mint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your spreadsheet, your way',
                        style: context.texts.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'BondTrack detects headers in any column order, lets you map them manually and validates every row before anything is saved.',
                        style: context.texts.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.68),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StepIndicator(step: _step),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: context.scheme.error,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _error!,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.scheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_step == 3)
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Import complete',
              message: 'Your valid bonds were added to the existing portfolio. Interest schedules are ready in the calendar.',
              primaryLabel: 'View portfolio',
              onPrimary: () => Navigator.of(context).pop(),
              secondaryLabel: 'Import another file',
              onSecondary: _reset,
            )
          else if (_bytes == null)
            _StartImport(busy: _busy, onPick: _pickFile, onExport: _export)
          else ...[
            if (_sheetNames.length > 1)
              PremiumCard(
                shadow: false,
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _sheetName,
                  decoration: const InputDecoration(
                    labelText: 'Worksheet',
                    prefixIcon: Icon(Icons.tab_rounded),
                  ),
                  items: [
                    for (final name in _sheetNames)
                      DropdownMenuItem(value: name, child: Text(name)),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) {
                          if (value != null) _loadSheet(value);
                        },
                ),
              ),
            if (_sheetNames.length > 1) const SizedBox(height: 12),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '$_fileName${_sheetName == null ? '' : ' · $_sheetName'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.labelMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _reset,
                      child: const Text('Choose another'),
                    ),
                  ],
                ),
              ),
            if (_table != null)
              PremiumCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: 'Map spreadsheet columns',
                      subtitle: 'BondTrack suggests a mapping. Adjust any column before importing.',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _table!.headers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _table!.headers[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.texts.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.teal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<ImportField>(
                                initialValue: _mapping[i] ?? ImportField.ignore,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                                items: [
                                  for (final field in ImportField.values)
                                    DropdownMenuItem(
                                      value: field,
                                      child: Text(
                                        field.label,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.texts.bodySmall,
                                      ),
                                    ),
                                ],
                                onChanged: _busy
                                    ? null
                                    : (field) {
                                        if (field != null) {
                                          _changeMapping(i, field);
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        for (final field in [
                          ImportField.name,
                          ImportField.issuer,
                          ImportField.principal,
                          ImportField.rate,
                          ImportField.purchaseDate,
                          ImportField.maturityDate,
                        ])
                          _RequiredChip(
                            label: field.label,
                            mapped: _mapping.values.contains(field),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_busy) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
            if (preview != null) ...[
              const SizedBox(height: 14),
              ResponsiveGrid(
                minItemWidth: 120,
                maxColumns: 4,
                children: [
                  _CountCard(
                    label: 'Ready',
                    count: preview.validCount,
                    color: AppColors.emerald,
                  ),
                  _CountCard(
                    label: 'Duplicates',
                    count: preview.duplicateCount,
                    color: AppColors.gold,
                  ),
                  _CountCard(
                    label: 'Updates',
                    count: preview.updateCount,
                    color: AppColors.chart[2],
                  ),
                  _CountCard(
                    label: 'Invalid',
                    count: preview.invalidCount,
                    color: AppColors.danger,
                  ),
                  _CountCard(
                    label: 'Selected',
                    count: preview.selectedCount,
                    color: AppColors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PreviewList(
                preview: preview,
                onToggle: _toggleRow,
                onToggleUpdate: _toggleUpdate,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy || preview.selectedCount == 0 ? null : _import,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_done_rounded, size: 19),
                label: Text(
                  preview.updateCount > 0
                      ? 'Import and update ${preview.selectedCount} bonds'
                      : 'Import ${preview.selectedCount} valid bonds',
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Existing bonds are only changed when you select “Update” and confirm. Duplicate workbook rows and invalid rows are skipped.',
                textAlign: TextAlign.center,
                style: context.texts.bodySmall?.copyWith(
                  color: context.mutedColor,
                  fontSize: 10.5,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Choose file', 'Map columns', 'Review', 'Complete'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: i <= step
                        ? context.scheme.primary
                        : context.scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: i < step
                        ? Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: context.scheme.onPrimary,
                          )
                        : Text(
                            '${i + 1}',
                            style: context.texts.labelSmall?.copyWith(
                              color: i <= step
                                  ? context.scheme.onPrimary
                                  : context.mutedColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[i],
                  style: context.texts.labelSmall?.copyWith(
                    color: i <= step
                        ? context.scheme.primary
                        : context.mutedColor,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          if (i != labels.length - 1)
            Expanded(
              child: Container(
                height: 1.5,
                margin: const EdgeInsets.only(bottom: 15),
                color: i < step ? context.scheme.primary : context.borderColor,
              ),
            ),
        ],
      ],
    );
  }
}

class _StartImport extends StatelessWidget {
  const _StartImport({
    required this.busy,
    required this.onPick,
    required this.onExport,
  });

  final bool busy;
  final VoidCallback onPick;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmptyState(
          icon: Icons.upload_file_rounded,
          title: 'Import your Excel portfolio',
          message: 'Select an .xlsx workbook. BondTrack detects headers, offers manual mapping and previews every row before import.',
          primaryLabel: busy ? 'Opening…' : 'Choose .xlsx file',
          onPrimary: busy ? null : onPick,
          compact: true,
        ),
        const SizedBox(height: 12),
        PremiumCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Export your portfolio',
                subtitle: 'Create an Excel workbook with bonds, interest schedule and payments.',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: busy ? null : onExport,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export to Excel'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequiredChip extends StatelessWidget {
  const _RequiredChip({required this.label, required this.mapped});

  final String label;
  final bool mapped;

  @override
  Widget build(BuildContext context) {
    final color = mapped ? AppColors.emerald : AppColors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          mapped ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: color,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      shadow: false,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, size: 8, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: context.texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.mutedColor,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({
    required this.preview,
    required this.onToggle,
    required this.onToggleUpdate,
  });

  final ImportPreview preview;
  final void Function(int index, bool selected) onToggle;
  final void Function(int index, bool selected) onToggleUpdate;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Preview records',
            subtitle: '${preview.rows.length} spreadsheet rows',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < preview.rows.length; i++)
            _PreviewRow(
              row: preview.rows[i],
              onChanged: (value) => onToggle(i, value),
              onUpdateChanged: (value) => onToggleUpdate(i, value),
            ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.row,
    required this.onChanged,
    required this.onUpdateChanged,
  });

  final ImportPreviewRow row;
  final ValueChanged<bool> onChanged;
  final ValueChanged<bool> onUpdateChanged;

  @override
  Widget build(BuildContext context) {
    final color = !row.isValid
        ? AppColors.danger
        : row.duplicate
        ? AppColors.gold
        : AppColors.emerald;
    final title =
        row.draft?.name ??
        (row.values.isEmpty ? 'Empty row' : row.values.first);
    final subtitle =
        row.error ??
        (row.draft == null
            ? ''
            : row.existingBond == null
            ? '${row.draft!.issuer} · ${row.draft!.frequency.label} · ${row.draft!.annualRate}%'
            : '${row.existingBond!.issuer} · ${Money.formatPaise(row.existingBond!.principalPaise)} → ${Money.formatPaise(row.draft!.principalPaise)} · ${row.existingBond!.annualRate}% → ${row.draft!.annualRate}%');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.scheme.surfaceContainerHighest.withValues(
          alpha: context.isDark ? 0.45 : 0.55,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (row.isValid && !row.duplicate)
            Checkbox(
              value: row.selected,
              onChanged: (value) => onChanged(value ?? false),
              visualDensity: VisualDensity.compact,
            )
          else
            SizedBox(
              width: 40,
              child: Icon(
                row.duplicate
                    ? Icons.content_copy_rounded
                    : Icons.error_outline_rounded,
                size: 17,
                color: color,
              ),
            ),
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '${row.rowNumber}',
              style: context.texts.labelSmall?.copyWith(
                color: color,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.labelMedium,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    row.duplicate ? 'Possible duplicate · $subtitle' : subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: color,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (row.draft != null) ...[
            const SizedBox(width: 8),
            if (row.existingBond != null && !row.duplicateWithinFile)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => onUpdateChanged(!row.updateSelected),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(row.updateSelected ? 'Update ✓' : 'Update'),
                  ),
                  Text(
                    Money.formatPaise(row.draft!.principalPaise),
                    style: context.texts.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            else
              Text(
                Money.formatPaise(row.draft!.principalPaise),
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
