import 'package:intl/intl.dart';

/// Centralised money, rate and date formatting. Every screen uses these
/// helpers so amounts are always rendered consistently in the selected
/// currency (INR by default, with Indian digit grouping).
class Money {
  Money._();

  static const _symbols = <String, String>{
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'د.إ',
  };

  static String symbolFor(String currencyCode) =>
      _symbols[currencyCode] ?? currencyCode;

  static String formatPaise(
    int paise, {
    String currencyCode = 'INR',
    bool compact = false,
    bool showSymbol = true,
    bool showDecimals = false,
  }) {
    final rupees = paise / 100;
    final symbol = showSymbol ? symbolFor(currencyCode) : '';
    if (compact) {
      return '$symbol${_compact(rupees, currencyCode)}';
    }
    final formatter = NumberFormat.currency(
      locale: currencyCode == 'INR' ? 'en_IN' : 'en_US',
      symbol: symbol,
      decimalDigits: showDecimals ? 2 : 0,
    );
    return formatter.format(rupees);
  }

  static String formatRupees(
    double rupees, {
    String currencyCode = 'INR',
    bool compact = false,
    bool showSymbol = true,
    bool showDecimals = false,
  }) {
    return formatPaise(
      (rupees * 100).round(),
      currencyCode: currencyCode,
      compact: compact,
      showSymbol: showSymbol,
      showDecimals: showDecimals,
    );
  }

  static String _compact(double value, String currencyCode) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (currencyCode == 'INR') {
      if (abs >= 10000000) {
        return '$sign${_trim(abs / 10000000)} Cr';
      }
      if (abs >= 100000) {
        return '$sign${_trim(abs / 100000)} L';
      }
      if (abs >= 1000) {
        return '$sign${_trim(abs / 1000)} K';
      }
      return '$sign${_trim(abs)}';
    }
    if (abs >= 1000000000) return '$sign${_trim(abs / 1000000000)}B';
    if (abs >= 1000000) return '$sign${_trim(abs / 1000000)}M';
    if (abs >= 1000) return '$sign${_trim(abs / 1000)}K';
    return '$sign${_trim(abs)}';
  }

  static String _trim(double value) {
    final fixed = value >= 100
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }

  static String rate(double value) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
    return '$text%';
  }

  static String date(DateTime value) => DateFormat('d MMM yyyy').format(value);

  static String dateShort(DateTime value) => DateFormat('d MMM').format(value);

  static String dateWithWeekday(DateTime value) =>
      DateFormat('EEE, d MMM yyyy').format(value);

  static String monthYear(DateTime value) =>
      DateFormat('MMM yyyy').format(value);

  static String monthShort(DateTime value) => DateFormat('MMM').format(value);

  static String dayNumber(DateTime value) => DateFormat('d').format(value);

  static String weekday(DateTime value) => DateFormat('EEE').format(value);

  static String dateTime(DateTime value) =>
      DateFormat('d MMM yyyy, h:mm a').format(value);

  static String isoDate(DateTime value) =>
      DateFormat('yyyy-MM-dd').format(value);

  /// Parses user-typed amounts such as "₹1,20,000.50", "2.5L" or "1 crore".
  static int? parseAmountToPaise(String input) {
    var text = input
        .toLowerCase()
        .replaceAll(RegExp(r'[₹$€£,\s]'), '')
        .replaceAll('inr', '')
        .trim();
    if (text.isEmpty) return null;
    var multiplier = 1.0;
    if (text.endsWith('crore') || text.endsWith('cr')) {
      multiplier = 10000000;
      text = text.replaceAll(RegExp(r'crore$|cr$'), '');
    } else if (text.endsWith('lakh') ||
        text.endsWith('lac') ||
        text.endsWith('l')) {
      multiplier = 100000;
      text = text.replaceAll(RegExp(r'lakh$|lac$|l$'), '');
    } else if (text.endsWith('k')) {
      multiplier = 1000;
      text = text.replaceAll(RegExp(r'k$'), '');
    }
    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return (value * multiplier * 100).round();
  }

  static double? parseRate(String input) {
    final text = input.replaceAll(RegExp(r'[%\s]'), '').trim();
    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }
}
