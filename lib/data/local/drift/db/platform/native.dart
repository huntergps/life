import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqflite_common/sqlite_api.dart';

QueryExecutor openAppDb(String dbPath) =>
    NativeDatabase.createInBackground(File(dbPath));

Future<DatabaseFactory> webQueueFactory() =>
    throw UnsupportedError('webQueueFactory not available on native');
