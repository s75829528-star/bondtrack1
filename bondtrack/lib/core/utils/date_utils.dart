/// Date helpers used across scheduling, charts and reminders.
library;

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime today() => dateOnly(DateTime.now());

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime startOfMonth(DateTime value) => DateTime(value.year, value.month);

DateTime endOfMonth(DateTime value) => DateTime(value.year, value.month + 1, 0);

DateTime startOfYear(DateTime value) => DateTime(value.year);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Adds months while clamping the day to the last valid day of the target
/// month. An anchor day is preserved so 31 Jan -> 28/29 Feb -> 31 Mar.
DateTime addMonthsClamped(DateTime date, int months, {int? anchorDay}) {
  final day = anchorDay ?? date.day;
  final zeroBasedMonth = date.month - 1 + months;
  final year = date.year + (zeroBasedMonth ~/ 12);
  final month = (zeroBasedMonth % 12) + 1;
  final clampedDay = day.clamp(1, daysInMonth(year, month));
  return DateTime(year, month, clampedDay, date.hour, date.minute, date.second);
}

DateTime addMonths(DateTime date, int months) => addMonthsClamped(date, months);

/// First occurrence of [day] on or after [from].
DateTime nextDateForDay(DateTime from, int day) {
  final candidate = DateTime(
    from.year,
    from.month,
    day.clamp(1, daysInMonth(from.year, from.month)),
  );
  if (dateOnly(candidate).isBefore(dateOnly(from))) {
    return addMonthsClamped(
      DateTime(from.year, from.month, 1),
      1,
      anchorDay: day,
    );
  }
  return candidate;
}

int daysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

int monthsBetween(DateTime from, DateTime to) {
  var months = (to.year - from.year) * 12 + (to.month - from.month);
  if (to.day < from.day) months -= 1;
  return months < 0 ? 0 : months;
}

String monthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

String yearKey(DateTime date) => '${date.year}';

DateTime monthStartFromKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

bool isWithin(DateTime value, DateTime start, DateTime end) {
  final date = dateOnly(value);
  return !date.isBefore(dateOnly(start)) && !date.isAfter(dateOnly(end));
}

String weekdayShort(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}

/// Monday-first index (0..6).
int weekdayIndex(DateTime date) => date.weekday - 1;

List<DateTime> monthGrid(DateTime month) {
  final first = startOfMonth(month);
  final leading = weekdayIndex(first);
  final gridStart = first.subtract(Duration(days: leading));
  return List<DateTime>.generate(42, (index) {
    final day = gridStart.add(Duration(days: index));
    return dateOnly(day);
  });
}
