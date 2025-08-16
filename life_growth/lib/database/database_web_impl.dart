import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createDatabase() {
  // Use WebDatabase for web platforms
  return WebDatabase('life_growth_db');
}