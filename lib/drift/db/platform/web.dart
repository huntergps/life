import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Opens a persistent Wasm database stored in IndexedDB (or OPFS when
/// available). Falls back gracefully to in-memory if storage is unavailable.
/// sqlite3.wasm and drift_worker.dart.js must be present in the web/ folder.
QueryExecutor openAppDb(String dbPath) => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: 'wildlife_db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
});

Future<DatabaseFactory> webQueueFactory() async => databaseFactoryFfiWebNoWebWorker;
