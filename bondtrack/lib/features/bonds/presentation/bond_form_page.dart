import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bondtrack/core/providers/app_providers.dart';
import 'package:bondtrack/core/theme/app_theme.dart';
import 'package:bondtrack/core/utils/date_utils.dart' as dates;
import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/core/widgets/app_page.dart';
import 'package:bondtrack/core/widgets/common.dart';
import 'package:bondtrack/core/widgets/empty_state.dart';
import 'package:bondtrack/core/widgets/premium_card.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/services/schedule_generator.dart';

class BondFormPage extends ConsumerWidget {
  const BondFormPage({super.key, this.bondId});

  final int? bondId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bondId == null) {
      return const _BondForm(existing: null);
    }
    final bond = ref.watch(bondByIdProvider(bondId!));
    return AsyncValueView<Bond?>(
      value: bond,
      builder: (data) {
        if (data == null) {
          return AppPage(
            showBack: true,
            title: 'Bond not found',
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'This bond no longer exists',
              message: 'It may have been deleted. Return to your portfolio.',
              primaryLabel: 'Back to bonds',
              onPrimary: () => Navigator.of(context).maybePop(),
            ),
          );
        }
        return _BondForm(existing: data);
      },
    );
  }
}

class _BondForm extends ConsumerStatefulWidget {
  const _BondForm({required this.existing});

  final Bond? existing;

  @override
  ConsumerState<_BondForm> createState() => _BondFormState();
}

class _BondFormState extends ConsumerState<_BondForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _issuer;
  late final TextEditingController _principal;
  late final TextEditingController _rate;
  late final TextEditingController _maturityAmount;
  late final TextEditingController _account;
  late final TextEditingController _notes;
  late final TextEditingController _creditDay;
  late final TextEditingController _manualInterest;

  late DateTime _purchaseDate;
  late DateTime _firstInterestDate;
  late DateTime _maturityDate;
  late InterestFrequency _frequency;
  late InterestMethod _interestMethod;
  late CompoundingFrequency _compoundingFrequency;
  late DayCountConvention _dayCountConvention;
  late Set<int> _interestReminderDays;
  late Set<int> _maturityReminderDays;
  late bool _inheritInterestReminders;
  late bool _inheritMaturityReminders;

  bool _saving = false;
  bool _dirty = false;
  bool _maturityAmountEdited = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final today = dates.today();
    _name = TextEditingController(text: existing?.name ?? '');
    _issuer = TextEditingController(text: existing?.issuer ?? '');
    _principal = TextEditingController(
      text: existing == null
          ? ''
          : (existing.principalPaise / 100).toStringAsFixed(0),
    );
    _rate = TextEditingController(
      text: existing == null ? '' : _rateText(existing.annualRate),
    );
    _maturityAmount = TextEditingController(
      text: existing == null
          ? ''
          : (existing.expectedMaturityAmountPaise / 100).toStringAsFixed(0),
    );
    _account = TextEditingController(text: existing?.paymentAccount ?? '');
    _notes = TextEditingController(text: existing?.notes ?? '');
    _creditDay = TextEditingController(
      text: existing?.creditDay?.toString() ?? '',
    );
    _manualInterest = TextEditingController(
      text: existing?.manualInterestPerPeriodPaise == null
          ? ''
          : (existing!.manualInterestPerPeriodPaise! / 100).toStringAsFixed(2),
    );
    _purchaseDate = existing?.purchaseDate ?? today;
    _firstInterestDate =
        existing?.firstInterestDate ?? dates.addMonthsClamped(today, 1);
    _maturityDate = existing?.maturityDate ?? dates.addMonthsClamped(today, 36);
    _frequency =
        existing?.frequency ??
        InterestFrequency.fromText(
          ref.read(settingsValueProvider).defaultFrequency,
        );
    _interestMethod = existing?.interestMethod ?? InterestMethod.simple;
    _compoundingFrequency =
        existing?.compoundingFrequency ?? CompoundingFrequency.annual;
    _dayCountConvention =
        existing?.dayCountConvention ?? DayCountConvention.equalPeriods;
    final appSettings = ref.read(settingsValueProvider);
    _inheritInterestReminders =
        existing == null ||
        existing.interestReminderOffsets.isEmpty ||
        existing.interestReminderOffsets == '7,3,1,0';
    _inheritMaturityReminders =
        existing == null ||
        existing.maturityReminderOffsets.isEmpty ||
        existing.maturityReminderOffsets == '30,15,7,1,0';
    _interestReminderDays = {
      ...(_inheritInterestReminders
          ? appSettings.interestReminderDays
          : existing!.interestReminderDays),
    };
    _maturityReminderDays = {
      ...(_inheritMaturityReminders
          ? appSettings.maturityReminderDays
          : existing!.maturityReminderDays),
    };
    _maturityAmountEdited = existing != null;

    for (final controller in [
      _name,
      _issuer,
      _principal,
      _rate,
      _maturityAmount,
      _account,
      _notes,
      _creditDay,
      _manualInterest,
    ]) {
      controller.addListener(_markDirty);
    }
    _principal.addListener(_syncMaturityAmount);
  }

  String _rateText(double rate) {
    return rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toString();
  }

  String _serializeOffsets(Set<int> offsets) =>
      (offsets.toList()..sort((a, b) => b.compareTo(a))).join(',');

  @override
  void dispose() {
    for (final controller in [
      _name,
      _issuer,
      _principal,
      _rate,
      _maturityAmount,
      _account,
      _notes,
      _creditDay,
      _manualInterest,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _syncMaturityAmount() {
    if (_maturityAmountEdited) return;
    final text = _principal.text.trim();
    if (_maturityAmount.text != text) {
      _maturityAmount.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  int? get _principalPaise => Money.parseAmountToPaise(_principal.text);

  double? get _rateValue => Money.parseRate(_rate.text);

  List<DateTime> _generatedDates() {
    final principal = _principalPaise;
    final rate = _rateValue;
    if (principal == null || rate == null || principal <= 0 || rate <= 0) {
      return const [];
    }
    return ScheduleGenerator.generate(
      purchaseDate: _purchaseDate,
      firstInterestDate: _firstInterestDate,
      maturityDate: _maturityDate,
      frequency: _frequency,
      principalPaise: principal,
      annualRate: rate,
      method: _interestMethod,
      compounding: _compoundingFrequency,
      dayCount: _dayCountConvention,
      creditDay: int.tryParse(_creditDay.text.trim()),
      manualInterestPerPeriodPaise: Money.parseAmountToPaise(
        _manualInterest.text,
      ),
    ).map((schedule) => schedule.dueDate).toList();
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
    required String helpText,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(1980),
      lastDate: lastDate ?? DateTime(2100, 12, 31),
      helpText: helpText,
    );
    if (selected != null) {
      setState(() {
        onPicked(dates.dateOnly(selected));
        _dirty = true;
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return showConfirmDialog(
      context,
      title: 'Discard changes?',
      message: 'Your edits to this bond have not been saved.',
      confirmLabel: 'Discard',
      destructive: true,
      icon: Icons.undo_rounded,
    );
  }

  Future<void> _save() async {
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final principal = Money.parseAmountToPaise(_principal.text);
    final rate = Money.parseRate(_rate.text);
    final maturityAmount =
        Money.parseAmountToPaise(_maturityAmount.text) ?? principal;
    if (principal == null || principal <= 0) {
      setState(() => _formError = 'Enter a valid principal amount.');
      return;
    }
    if (rate == null || rate <= 0 || rate > 100) {
      setState(
        () => _formError = 'Enter an annual rate between 0.01% and 100%.',
      );
      return;
    }
    if (_firstInterestDate.isBefore(_purchaseDate)) {
      setState(
        () => _formError = 'The first interest credit date cannot be before the purchase date.',
      );
      return;
    }
    if (!_maturityDate.isAfter(_purchaseDate)) {
      setState(
        () => _formError = 'The maturity date must be after the purchase date.',
      );
      return;
    }
    if (_firstInterestDate.isAfter(_maturityDate)) {
      setState(
        () => _formError =
            'The first interest credit date must be on or before maturity.',
      );
      return;
    }
    if (maturityAmount == null || maturityAmount <= 0) {
      setState(() => _formError = 'Enter a valid expected maturity amount.');
      return;
    }

    setState(() => _saving = true);
    final draft = BondDraft(
      id: widget.existing?.id,
      name: _name.text.trim(),
      issuer: _issuer.text.trim(),
      principalPaise: principal,
      annualRate: rate,
      purchaseDate: _purchaseDate,
      frequency: _frequency,
      firstInterestDate: _firstInterestDate,
      maturityDate: _maturityDate,
      expectedMaturityAmountPaise: maturityAmount,
      paymentAccount: _account.text,
      notes: _notes.text,
      status: widget.existing?.status ?? BondStatus.active,
      interestMethod: _interestMethod,
      compoundingFrequency: _compoundingFrequency,
      dayCountConvention: _dayCountConvention,
      creditDay: int.tryParse(_creditDay.text.trim()),
      manualInterestPerPeriodPaise: Money.parseAmountToPaise(
        _manualInterest.text,
      ),
      remindersEnabled: widget.existing?.remindersEnabled ?? true,
      interestReminderOffsets: _inheritInterestReminders
          ? ''
          : _serializeOffsets(_interestReminderDays),
      maturityReminderOffsets: _inheritMaturityReminders
          ? ''
          : _serializeOffsets(_maturityReminderDays),
    );

    try {
      final repository = ref.read(bondRepositoryProvider);
      if (widget.existing == null) {
        await repository.create(draft);
      } else {
        await repository.update(draft);
      }
      if (!mounted) return;
      _dirty = false;
      showAppSnackBar(
        context,
        widget.existing == null
            ? 'Bond added and interest schedule generated.'
            : 'Bond updated. Pending interest dates were refreshed.',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _formError = 'Could not save the bond: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = ref.watch(moneyFormatterProvider);
    final symbol = Money.symbolFor(formatter.currencyCode);
    final principal = _principalPaise ?? 0;
    final rate = _rateValue ?? 0;
    final manual = Money.parseAmountToPaise(_manualInterest.text);
    final perPeriod =
        manual ??
        (principal > 0 && rate > 0
            ? (principal * rate / 100 * _frequency.months / 12).round()
            : 0);
    final annual = principal > 0 && rate > 0
        ? (principal * rate / 100).round()
        : 0;
    final generatedDates = _generatedDates();
    final today = dates.today();
    final upcomingDates = generatedDates
        .where((date) => !dates.dateOnly(date).isBefore(today))
        .toList();
    final nextDate = upcomingDates.isEmpty ? null : upcomingDates.first;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AppPage(
        showBack: true,
        eyebrow: widget.existing == null ? 'New investment' : 'Edit investment',
        title: widget.existing == null ? 'Add a bond' : 'Edit bond',
        subtitle: 'BondTrack uses these details to build the interest calendar, maturity tracker and analytics.',
        actions: [
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.existing == null ? 'Save bond' : 'Save changes'),
          ),
        ],
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormSection(
                icon: Icons.badge_outlined,
                title: 'Bond identity',
                subtitle: 'How this investment appears in your portfolio',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Bond name',
                        hintText: 'e.g. 8.5% NCD 2030',
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Enter a bond name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _issuer,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Issuer',
                        hintText: 'e.g. Tata Capital Financial Services',
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Enter the issuer'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                icon: Icons.payments_outlined,
                title: 'Investment',
                subtitle: 'Principal, coupon and purchase details',
                child: _TwoFields(
                  first: TextFormField(
                    controller: _principal,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Principal amount',
                      prefixText: '$symbol ',
                      hintText: '5,00,000',
                    ),
                    validator: (value) {
                      final parsed = Money.parseAmountToPaise(value ?? '');
                      return parsed == null || parsed <= 0
                          ? 'Enter a valid amount'
                          : null;
                    },
                  ),
                  second: TextFormField(
                    controller: _rate,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Annual interest rate',
                      suffixText: '%',
                      hintText: '8.5',
                    ),
                    validator: (value) {
                      final parsed = Money.parseRate(value ?? '');
                      if (parsed == null || parsed <= 0 || parsed > 100) {
                        return 'Enter a rate from 0.01 to 100';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                icon: Icons.event_repeat_rounded,
                title: 'Interest schedule',
                subtitle: 'Choose how often interest is credited',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final frequency in InterestFrequency.values)
                          _FrequencyOption(
                            frequency: frequency,
                            selected: _frequency == frequency,
                            onTap: () {
                              setState(() {
                                _frequency = frequency;
                                _dirty = true;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<InterestMethod>(
                      initialValue: _interestMethod,
                      decoration: const InputDecoration(
                        labelText: 'Interest calculation',
                      ),
                      items: [
                        for (final method in InterestMethod.values)
                          DropdownMenuItem(
                            value: method,
                            child: Text(method.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _interestMethod = value;
                          _dirty = true;
                        });
                      },
                    ),
                    if (_interestMethod == InterestMethod.compound) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CompoundingFrequency>(
                        initialValue: _compoundingFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Compounding frequency',
                        ),
                        items: [
                          for (final frequency in CompoundingFrequency.values)
                            DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency.label),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _compoundingFrequency = value;
                            _dirty = true;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DayCountConvention>(
                      initialValue: _dayCountConvention,
                      decoration: const InputDecoration(
                        labelText: 'Day-count convention',
                      ),
                      items: [
                        for (final convention in DayCountConvention.values)
                          DropdownMenuItem(
                            value: convention,
                            child: Text(convention.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _dayCountConvention = value;
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _TwoFields(
                      first: TextFormField(
                        controller: _creditDay,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Credit day (optional)',
                          hintText: '1–31',
                          helperText: 'Month-end dates are clamped.',
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return null;
                          final day = int.tryParse(text);
                          return day == null || day < 1 || day > 31
                              ? 'Enter a day from 1 to 31'
                              : null;
                        },
                      ),
                      second: TextFormField(
                        controller: _manualInterest,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Manual coupon (optional)',
                          prefixText: '$symbol ',
                          helperText: 'Overrides the calculated coupon.',
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return null;
                          final amount = Money.parseAmountToPaise(value!);
                          return amount == null || amount <= 0
                              ? 'Enter a positive amount'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DateField(
                      label: 'Purchase date',
                      value: _purchaseDate,
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => _pickDate(
                        initial: _purchaseDate,
                        onPicked: (date) => _purchaseDate = date,
                        helpText: 'Purchase date',
                        lastDate: DateTime(2100),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DateField(
                      label: 'First interest credit date',
                      value: _firstInterestDate,
                      icon: Icons.event_available_outlined,
                      helper:
                          'The schedule repeats ${_frequency.label.toLowerCase()} from this date until maturity.',
                      onTap: () => _pickDate(
                        initial: _firstInterestDate,
                        onPicked: (date) => _firstInterestDate = date,
                        helpText: 'First interest credit date',
                        firstDate: _purchaseDate,
                        lastDate: DateTime(2100),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.scheme.primary.withValues(alpha: 0.08),
                            context.scheme.secondary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.scheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PreviewStat(
                                  label: 'Per credit',
                                  value: formatter.format(perPeriod),
                                ),
                              ),
                              Expanded(
                                child: _PreviewStat(
                                  label: 'Annual interest',
                                  value: formatter.format(annual),
                                ),
                              ),
                              Expanded(
                                child: _PreviewStat(
                                  label: 'Credits',
                                  value: '${generatedDates.length}',
                                ),
                              ),
                            ],
                          ),
                          if (nextDate != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: context.scheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Next credit ${Money.date(nextDate)}',
                                  style: context.texts.labelSmall?.copyWith(
                                    color: context.scheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                icon: Icons.flag_outlined,
                title: 'Maturity',
                subtitle: 'When principal is expected to be repaid',
                child: Column(
                  children: [
                    _DateField(
                      label: 'Maturity date',
                      value: _maturityDate,
                      icon: Icons.event_outlined,
                      onTap: () => _pickDate(
                        initial: _maturityDate,
                        onPicked: (date) => _maturityDate = date,
                        helpText: 'Maturity date',
                        firstDate: _purchaseDate,
                        lastDate: DateTime(2100),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _maturityAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) {
                        _maturityAmountEdited = true;
                        _markDirty();
                      },
                      decoration: InputDecoration(
                        labelText: 'Expected maturity amount',
                        prefixText: '$symbol ',
                        helperText: 'Defaults to principal if left blank. Add final interest if it is paid at maturity.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                icon: Icons.notifications_active_outlined,
                title: 'Bond reminders',
                subtitle: 'Choose reminder days for this bond',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use app-wide interest reminders'),
                      value: _inheritInterestReminders,
                      onChanged: (value) {
                        final defaults = ref
                            .read(settingsValueProvider)
                            .interestReminderDays;
                        setState(() {
                          _inheritInterestReminders = value;
                          if (value) _interestReminderDays = {...defaults};
                          _dirty = true;
                        });
                      },
                    ),
                    Text('Interest credits', style: context.texts.labelLarge),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final day in const [7, 3, 1, 0])
                          FilterChip(
                            label: Text(day == 0 ? 'Due day' : '$day days'),
                            selected: _interestReminderDays.contains(day),
                            onSelected: _inheritInterestReminders
                                ? null
                                : (selected) => setState(() {
                                    if (selected) {
                                      _interestReminderDays.add(day);
                                    } else {
                                      _interestReminderDays.remove(day);
                                    }
                                    _dirty = true;
                                  }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use app-wide maturity reminders'),
                      value: _inheritMaturityReminders,
                      onChanged: (value) {
                        final defaults = ref
                            .read(settingsValueProvider)
                            .maturityReminderDays;
                        setState(() {
                          _inheritMaturityReminders = value;
                          if (value) _maturityReminderDays = {...defaults};
                          _dirty = true;
                        });
                      },
                    ),
                    Text('Maturity', style: context.texts.labelLarge),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final day in const [30, 15, 7, 1, 0])
                          FilterChip(
                            label: Text(day == 0 ? 'Due day' : '$day days'),
                            selected: _maturityReminderDays.contains(day),
                            onSelected: _inheritMaturityReminders
                                ? null
                                : (selected) => setState(() {
                                    if (selected) {
                                      _maturityReminderDays.add(day);
                                    } else {
                                      _maturityReminderDays.remove(day);
                                    }
                                    _dirty = true;
                                  }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FormSection(
                icon: Icons.notes_rounded,
                title: 'Additional details',
                subtitle: 'Optional references and personal notes',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _account,
                      decoration: const InputDecoration(
                        labelText: 'Payment account reference (optional)',
                        hintText: 'e.g. HDFC savings ••••1234',
                        helperText: 'A label only. Never store passwords, PINs or banking credentials.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notes,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Coupon terms, tax notes, broker reference…',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 14),
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
                        size: 18,
                        color: context.scheme.error,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  widget.existing == null ? 'Save bond' : 'Save changes',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final discard = await _confirmDiscard();
                        if (discard && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(18),
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
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TwoFields extends StatelessWidget {
  const _TwoFields({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 520) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          );
        }
        return Column(children: [first, const SizedBox(height: 12), second]);
      },
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  const _FrequencyOption({
    required this.frequency,
    required this.selected,
    required this.onTap,
  });

  final InterestFrequency frequency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.scheme.primaryContainer : context.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? context.scheme.primary : context.borderColor,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 16,
                color: selected ? context.scheme.primary : context.mutedColor,
              ),
              const SizedBox(width: 7),
              Text(
                frequency.label,
                style: context.texts.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? context.scheme.onPrimaryContainer
                      : context.scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.helper,
  });

  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          suffixIcon: Icon(icon, size: 18),
        ),
        child: Text(
          Money.date(value),
          style: context.texts.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.texts.labelSmall?.copyWith(
            color: context.mutedColor,
            fontSize: 9.5,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
