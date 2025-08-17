import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createDatabase() {
  // Use in-memory database for web (no external dependencies)
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}