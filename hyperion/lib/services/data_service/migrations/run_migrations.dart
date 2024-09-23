import 'package:hyperion/services/data_service/migrations/v1.dart';
import 'package:hyperion/services/data_service/migrations/v2.dart';
import 'package:sqflite/sqflite.dart';

runMigrations(Database db, int dbVersion) async {
  await db.transaction((tx) async {
    if (dbVersion > 0) await version1(tx);
    if (dbVersion > 1) await version2(tx);
  });
}
