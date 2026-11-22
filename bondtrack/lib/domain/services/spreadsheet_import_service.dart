import 'dart:typed_data';

import 'package:bondtrack/core/utils/money.dart';
import 'package:bondtrack/domain/entities/bond.dart';
import 'package:bondtrack/domain/services/bond_identity.dart';
import 'package:excel/excel.dart';

enum ImportField {
  ignore,
  name,
  issuer,
  principal,
  rate,
  purchaseDate,
  frequency,
  firstInterestDate,
  maturityDate,
  maturityAmount,
  paymentAccount,
  notes,
  status;

  String get label => switch (this) {
    ignore => 'Do not import',
    name => 'Bond name',
    issuer => 'Issuer',
    principal => 'Principal amount',
    rate => 'Annual interest rate',
    purchaseDate => 'Purchase date',
    frequency => 'Interest frequency',
    firstInterestDate => 'First credit date',
    maturityDate => 'Maturity date',
    maturityAmount => 'Maturity amount',
    paymentAccount => 'Payment account reference',
    notes => 'Notes',
    status => 'Bond status',
  };
}

class SpreadsheetTable {
  const SpreadsheetTable({
    required this.sheetName,
    required this.headers,
    required this.rows,
  });

  final String sheetName;
  final List<String> headers;
  final List<List<String>> rows;
}

class ImportPreviewRow {
  const ImportPreviewRow({
    required this.rowNumber,
    required this.values,
    this.draft,
    this.error,
    this.duplicate = false,
    this.selected = true,
    this.existingBond,
    this.updateSelected = false,
    this.duplicateWithinFile = false,
  });

  final int rowNumber;
  final List<String> values;
  final BondDraft? draft;
  final String? error;
  final bool duplicate;
  final bool selected;
  final Bond? existingBond;
  final bool updateSelected;
  final bool duplicateWithinFile;

  bool get isValid => draft != null && error == null;

  ImportPreviewRow copyWith({bool? selected, bool? updateSelected}) =>
      ImportPreviewRow(
        rowNumber: rowNumber,
        values: values,
        draft: draft,
        error: error,
        duplicate: duplicate,
        selected: selected ?? this.selected,
        existingBond: existingBond,
        updateSelected: updateSelected ?? this.updateSelected,
        duplicateWithinFile: duplicateWithinFile,
      );
}

class ImportPreview {
  const ImportPreview({
    required this.headers,
    required this.mapping,
    required this.rows,
  });

  final List<String> headers;
  final Map<int, ImportField> mapping;
  final List<ImportPreviewRow> rows;

  int get validCount => rows.where((r) => r.isValid && !r.duplicate).length;
  int get duplicateCount => rows.where((r) => r.duplicate).length;
  int get invalidCount => rows.where((r) => !r.isValid).length;
  int get selectedCount => rows
      .where(
        (r) =>
            r.isValid &&
            ((r.selected && !r.duplicate) ||
                (r.updateSelected && r.existingBond != null)),
      )
      .length;
  int get updateCount => rows
      .where((r) => r.isValid && r.updateSelected && r.existingBond != null)
      .length;

  ImportPreview copyWith({
    Map<int, ImportField>? mapping,
    List<ImportPreviewRow>? rows,
  }) => ImportPreview(
    headers: headers,
    mapping: mapping ?? this.mapping,
    rows: rows ?? this.rows,
  );
}

/// Reads arbitrary XLSX layouts by discovering a likely header row and
/// matching aliases. The user can override the suggested mapping.
class SpreadsheetImportService {
  SpreadsheetImportService._();

  static List<String> sheetNames(Uint8List bytes) =>
      Excel.decodeBytes(bytes).tables.keys.toList();

  static SpreadsheetTable readSheet(Uint8List bytes, String sheetName) {
    final sheet = Excel.decodeBytes(bytes).tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      throw const FormatException('The selected worksheet is empty.');
    }
    final rows = sheet.rows.map((row) => row.map(_cellText).toList()).toList();
    var headerIndex = -1;
    var bestScore = 0;
    for (var i = 0; i < rows.length && i < 30; i++) {
      final score = rows[i]
          .map(matchHeader)
          .whereType<ImportField>()
          .toSet()
          .length;
      if (score > bestScore) {
        bestScore = score;
        headerIndex = i;
      }
    }
    if (headerIndex < 0 || bestScore < 2) {
      throw const FormatException(
        'Could not detect the header row. Choose a worksheet with column headings.',
      );
    }
    final headers = rows[headerIndex].asMap().entries.map((entry) {
      final value = entry.value.trim();
      return value.isEmpty ? 'Column ${entry.key + 1}' : value;
    }).toList();
    final data = rows
        .skip(headerIndex + 1)
        .where((row) => row.any((cell) => cell.trim().isNotEmpty))
        .map(
          (row) => List<String>.generate(
            headers.length,
            (i) => i < row.length ? row[i].trim() : '',
          ),
        )
        .toList();
    return SpreadsheetTable(sheetName: sheetName, headers: headers, rows: data);
  }

  static Map<int, ImportField> suggestMapping(List<String> headers) {
    final used = <ImportField>{};
    return {
      for (var i = 0; i < headers.length; i++)
        i: _uniqueMatch(headers[i], used),
    };
  }

  static ImportField _uniqueMatch(String header, Set<ImportField> used) {
    final match = matchHeader(header);
    if (match == null || used.contains(match)) return ImportField.ignore;
    used.add(match);
    return match;
  }

  static ImportField? matchHeader(String header) {
    final text = header
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    if (text == 'name' ||
        text.contains('bond name') ||
        text == 'security' ||
        text == 'instrument') {
      return ImportField.name;
    }
    if (text.contains('issuer') ||
        text.contains('company') ||
        text.contains('borrower')) {
      return ImportField.issuer;
    }
    if (text.contains('principal') ||
        text.contains('investment amount') ||
        text.contains('face value') ||
        text == 'amount invested') {
      return ImportField.principal;
    }
    if (text.contains('interest rate') ||
        text.contains('coupon') ||
        text.contains('yield') ||
        text.contains('rate')) {
      return ImportField.rate;
    }
    if (text.contains('purchase date') ||
        text.contains('investment date') ||
        text.contains('date of purchase') ||
        text == 'buy date') {
      return ImportField.purchaseDate;
    }
    if (text.contains('frequency') ||
        text.contains('payment interval') ||
        text.contains('coupon frequency')) {
      return ImportField.frequency;
    }
    if ((text.contains('interest') ||
            text.contains('credit') ||
            text.contains('payment')) &&
        (text.contains('date') || text.contains('day'))) {
      return ImportField.firstInterestDate;
    }
    if (text.contains('maturity date') ||
        text.contains('matures on') ||
        text.contains('redemption date') ||
        text.contains('due date')) {
      return ImportField.maturityDate;
    }
    if (text.contains('maturity amount') ||
        text.contains('redemption amount') ||
        text.contains('maturity value')) {
      return ImportField.maturityAmount;
    }
    if (text.contains('account')) return ImportField.paymentAccount;
    if (text.contains('note') ||
        text.contains('remark') ||
        text.contains('comment')) {
      return ImportField.notes;
    }
    if (text.contains('status')) return ImportField.status;
    return null;
  }

  static ImportPreview preview({
    required SpreadsheetTable table,
    required Map<int, ImportField> mapping,
    required Set<String> existingDuplicateKeys,
    List<Bond> existingBonds = const [],
  }) {
    final existingByKey = <String, Bond>{
      for (final bond in existingBonds)
        bondDuplicateKey(
          name: bond.name,
          issuer: bond.issuer,
          purchaseDate: bond.purchaseDate,
        ): bond,
    };
    final seenInFile = <String>{};
    final rows = <ImportPreviewRow>[];
    for (var i = 0; i < table.rows.length; i++) {
      final values = table.rows[i];
      try {
        final draft = _draft(values, mapping);
        final key = bondDuplicateKey(
          name: draft.name,
          issuer: draft.issuer,
          purchaseDate: draft.purchaseDate,
        );
        final duplicateWithinFile = !seenInFile.add(key);
        final matchingBond = existingByKey[key];
        final duplicate =
            duplicateWithinFile ||
            matchingBond != null ||
            existingDuplicateKeys.contains(key);
        rows.add(
          ImportPreviewRow(
            rowNumber: i + 1,
            values: values,
            draft: draft,
            duplicate: duplicate,
            selected: !duplicate,
            existingBond: duplicateWithinFile ? null : matchingBond,
            duplicateWithinFile: duplicateWithinFile,
          ),
        );
      } catch (error) {
        rows.add(
          ImportPreviewRow(
            rowNumber: i + 1,
            values: values,
            error: error.toString().replaceFirst('FormatException: ', ''),
            selected: false,
          ),
        );
      }
    }
    return ImportPreview(
      headers: table.headers,
      mapping: Map.unmodifiable(mapping),
      rows: rows,
    );
  }

  static BondDraft _draft(List<String> cells, Map<int, ImportField> mapping) {
    final values = <ImportField, String>{};
    for (final entry in mapping.entries) {
      if (entry.value == ImportField.ignore || entry.key >= cells.length) {
        continue;
      }
      values[entry.value] = cells[entry.key].trim();
    }
    String required(ImportField field) {
      final value = values[field] ?? '';
      if (value.isEmpty) throw FormatException('${field.label} is required.');
      return value;
    }

    final name = required(ImportField.name);
    final issuer = required(ImportField.issuer);
    final principal = _amount(required(ImportField.principal));
    final rate = Money.parseRate(required(ImportField.rate));
    if (rate == null || rate <= 0 || rate > 100) {
      throw const FormatException('Rate must be between 0.01% and 100%.');
    }
    final purchase = _date(required(ImportField.purchaseDate));
    final maturity = _date(required(ImportField.maturityDate));
    if (!maturity.isAfter(purchase)) {
      throw const FormatException('Maturity must be after purchase date.');
    }
    final frequency = InterestFrequency.fromText(values[ImportField.frequency]);
    final rawCredit = values[ImportField.firstInterestDate] ?? '';
    final firstCredit = rawCredit.trim().isEmpty
        ? DateTime(
            purchase.year,
            purchase.month + frequency.months,
            purchase.day.clamp(1, 28),
          )
        : _date(rawCredit);
    if (firstCredit.isBefore(purchase) || firstCredit.isAfter(maturity)) {
      throw const FormatException(
        'First credit date must fall between purchase and maturity.',
      );
    }
    final rawMaturityAmount = values[ImportField.maturityAmount] ?? '';
    final maturityAmount = rawMaturityAmount.trim().isEmpty
        ? principal
        : _amount(rawMaturityAmount);
    if (name.length > 160 || issuer.length > 160) {
      throw const FormatException(
        'Name and issuer must be 160 characters or fewer.',
      );
    }
    return BondDraft(
      name: name,
      issuer: issuer,
      principalPaise: principal,
      annualRate: rate,
      purchaseDate: purchase,
      frequency: frequency,
      firstInterestDate: firstCredit,
      maturityDate: maturity,
      expectedMaturityAmountPaise: maturityAmount,
      paymentAccount: values[ImportField.paymentAccount],
      notes: values[ImportField.notes],
      status: BondStatus.fromText(values[ImportField.status]),
    );
  }

  static int _amount(String value) {
    final amount = Money.parseAmountToPaise(value);
    if (amount == null || amount <= 0) {
      throw FormatException('Invalid positive amount "$value".');
    }
    return amount;
  }

  static DateTime _date(String input) {
    final value = input.trim();
    final iso = DateTime.tryParse(value);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    final serial = double.tryParse(value);
    if (serial != null && serial > 1000 && serial < 100000) {
      final date = DateTime.utc(
        1899,
        12,
        30,
      ).add(Duration(days: serial.floor()));
      return DateTime(date.year, date.month, date.day);
    }
    final numeric = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$')
        .firstMatch(value);
    if (numeric != null) {
      var year = int.parse(numeric.group(3)!);
      if (year < 100) year += year >= 50 ? 1900 : 2000;
      // Spreadsheet portfolio dates conventionally use Indian dd/mm/yyyy.
      return _validDate(
        year,
        int.parse(numeric.group(2)!),
        int.parse(numeric.group(1)!),
        input,
      );
    }
    final named = RegExp(r'^(\d{1,2})\s+([a-zA-Z]{3,9})\s+(\d{4})$')
        .firstMatch(value);
    if (named != null) {
      const months = {
        'jan': 1,
        'january': 1,
        'feb': 2,
        'february': 2,
        'mar': 3,
        'march': 3,
        'apr': 4,
        'april': 4,
        'may': 5,
        'jun': 6,
        'june': 6,
        'jul': 7,
        'july': 7,
        'aug': 8,
        'august': 8,
        'sep': 9,
        'sept': 9,
        'september': 9,
        'oct': 10,
        'october': 10,
        'nov': 11,
        'november': 11,
        'dec': 12,
        'december': 12,
      };
      final month = months[named.group(2)!.toLowerCase()];
      if (month != null) {
        return _validDate(
          int.parse(named.group(3)!),
          month,
          int.parse(named.group(1)!),
          input,
        );
      }
    }
    throw FormatException(
      'Invalid date "$input". Use dd/mm/yyyy or yyyy-mm-dd.',
    );
  }

  static DateTime _validDate(int year, int month, int day, String raw) {
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > DateTime(year, month + 1, 0).day) {
      throw FormatException('Invalid date "$raw".');
    }
    return DateTime(year, month, day);
  }

  static String _cellText(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    if (value is TextCellValue) return value.value.toString();
    if (value is DateCellValue) return Money.isoDate(value.asDateTimeLocal());
    if (value is DateTimeCellValue) {
      return Money.isoDate(value.asDateTimeLocal());
    }
    return value.toString();
  }
}
