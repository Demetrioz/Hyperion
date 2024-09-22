import 'package:sqflite/sqlite_api.dart';

// Create an initial version and settings table
migration1(Database db) async {
  await db.transaction((tx) async {
    await tx.execute('''
      CREATE TABLE IF NOT EXISTS Version (id INTEGER PRIMARY KEY AUTOINCREMENT, date DATETIME);
    ''');

    await tx.execute('''
      CREATE TABLE IF NOT EXISTS Settings (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT);
    ''');

    // Create a temp table so I can insert all values at once, instead of individual inserts
    await tx.execute('''
      CREATE TEMP TABLE IF NOT EXISTS TempSettings (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT);
    ''');

    await tx.execute('''
      INSERT INTO TempSettings(id, key, value)
      VALUES
      (1, 'mqtt.host', ''),
      (2, 'mqtt.port', ''),
      (3, 'mqtt.client', ''),
      (4, 'mqtt.username', ''),
      (5, 'mqtt.password', ''),
      (6, 'mqtt.channels.notifications', '')
    ''');

    await tx.execute('''
      INSERT INTO Settings(id, key, value)
      SELECT t.id, t.key, t.value
      FROM TempSettings t
      WHERE NOT EXISTS (
        SELECT 1
        FROM Settings s
        WHERE s.id = t.id
      )
    ''');

    await tx.execute('''
      INSERT INTO Version (id, date)
      SELECT 1, DATETIME('now')
      WHERE NOT EXISTS (
        SELECT 1
        FROM Version
        WHERE id = 1
      );
    ''');
  });
}
