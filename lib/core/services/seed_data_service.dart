import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../data/seed_data.dart';

/// Inserts bundled seed data directly into Brick's local SQLite database.
/// This enables the app to work fully offline on first launch.
class SeedDataService {
  Future<void> seed({
    void Function(int step, int total, String table)? onProgress,
  }) async {
    final db = await _openDatabase();

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM Species'),
    );
    if (count != null && count > 0) {
      debugPrint('Database already seeded, skipping');
      return;
    }

    const total = 5;

    await db.transaction((txn) async {
      onProgress?.call(1, total, 'Categories');
      var batch = txn.batch();
      for (final row in seedCategories) {
        batch.insert('Category', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      onProgress?.call(2, total, 'Islands');
      batch = txn.batch();
      for (final row in seedIslands) {
        batch.insert('Island', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      onProgress?.call(3, total, 'Visit Sites');
      batch = txn.batch();
      for (final row in seedVisitSites) {
        batch.insert('VisitSite', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      onProgress?.call(4, total, 'Species');
      batch = txn.batch();
      for (final row in seedSpecies) {
        batch.insert('Species', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      onProgress?.call(5, total, 'Species Sites');
      batch = txn.batch();
      for (final row in seedSpeciesSites) {
        batch.insert('SpeciesSite', row, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    });

    debugPrint('Local database seeded with ${seedSpecies.length} species');
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase('$databasesPath/galapagos_wildlife.sqlite');
  }
}
