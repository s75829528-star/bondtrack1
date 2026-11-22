import 'package:bondtrack/core/utils/date_utils.dart' as dates;

/// Stable identity used for duplicate detection during Excel import.
String bondDuplicateKey({
  required String name,
  required String issuer,
  required DateTime purchaseDate,
}) {
  String normalise(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  return '${normalise(name)}|${normalise(issuer)}|${dates.dateOnly(purchaseDate).toIso8601String()}';
}
