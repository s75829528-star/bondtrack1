# BondTrack

**Personal Bond Investment Manager** — an offline-first Flutter application for tracking bond principal, coupons, maturity dates and payment history.

## Implementation plan

1. Inspect the repository and install/check Flutter and Android tooling.
2. Build the domain model and centralized financial/date calculations.
3. Add a relational Drift/SQLite store and repository layer.
4. Build the Material 3 design system, navigation and portfolio screens.
5. Implement bond CRUD, schedule/payment tracking, Excel import/export, reminders and backup/restore.
6. Run analysis, tests and an Android debug build; fix issues found.

All six foundation steps are implemented in this repository.

## Implemented

- Dashboard with portfolio totals, coupon income chart, issuer distribution, upcoming payments/maturities and recent activity.
- Bond create, read, update, archive/restore and confirmed delete; search, status filters and sorting.
- Bond details with coupon schedule, payment history, milestone timeline, edit and lifecycle actions.
- Monthly, quarterly, half-yearly and annual coupon schedules, with month-end date clamping.
- Interest calendar, payment history, maturity tracker and portfolio analytics.
- XLSX import wizard: worksheet selection, header detection, manual column mapping, row validation, duplicate detection, preview and non-destructive transactional import.
- XLSX portfolio export, including bonds, schedules and payments.
- JSON backup/restore for bonds, schedules, payments, notifications and preferences. Restore explicitly warns before replacing local data.
- Offline Drift/SQLite persistence, theme/currency/reminder settings, in-app reminders and opt-in Android notifications.
- Light/dark Material 3 themes, responsive Android navigation and local Manrope typography.
- Custom adaptive Android launcher icon matching the BondTrack brand.

## Project structure

```text
lib/
  core/                  Theme, router, providers, formatting and reusable widgets
  data/
    database/            Drift tables, migrations and generated schema
    repositories/        SQLite repository implementations
  domain/
    entities/            Bond, schedule, payment, notification and settings
    models/              Dashboard and analytics result models
    repositories/        Repository contracts
    services/            Financial calculations, scheduling and XLSX parsing
  features/
    analytics/
    bonds/
    calendar/
    dashboard/
    import_export/
    maturity/
    more/
    notifications/
    payments/
    settings/
test/                    Domain and import validation tests
```

## Dependencies

- Flutter / Dart
- `flutter_riverpod`, `go_router`
- `drift`, `drift_flutter`, `drift_dev`, `build_runner`
- `fl_chart`, `intl`
- `file_picker`, `excel`, `share_plus`
- `flutter_local_notifications`, `flutter_timezone`, `timezone`

Use the committed `pubspec.lock` for reproducible resolution.

## Development

```sh
flutter pub get
dart run build_runner build
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Step 2 follow-up

- Add on-device end-to-end tests for file-picker, Android notification permission and notification delivery behavior.
- Verify import against real-world spreadsheets with mixed date formats, merged headers and multiple portfolio-specific layouts.
- Add an explicit payment-history import mapping (the current Excel wizard imports bond records and generates their future schedules).
- Add database migration tests and larger-portfolio performance testing.
- Add release signing, app icon/branding assets and Play Store metadata.
- Confirm currency semantics with the product owner before enabling non-INR display (principal is stored as INR paise; no FX conversion is performed).
