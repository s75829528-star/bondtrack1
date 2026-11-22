import 'package:bondtrack/domain/entities/bond.dart';

abstract interface class BondRepository {
  Stream<List<Bond>> watchAll();

  Stream<Bond?> watchById(int id);

  Future<Bond?> getById(int id);

  Future<List<Bond>> getAll();

  Future<int> create(BondDraft draft);

  Future<void> update(BondDraft draft);

  Future<void> archive(int id);

  Future<void> restore(int id);

  Future<void> markMatured(int id);

  Future<void> delete(int id);

  Future<int> importAll(List<BondDraft> drafts);

  /// Applies an Excel sync atomically: creates new bonds and updates selected
  /// existing bonds together, rolling back on any failure.
  Future<int> syncImport({
    required List<BondDraft> newBonds,
    required List<BondDraft> updates,
  });

  Future<Set<String>> existingDuplicateKeys();
}
