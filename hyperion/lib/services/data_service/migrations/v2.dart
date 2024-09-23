import 'package:sqflite/sqflite.dart';

// 9/22/24
// Create a table for storing and displaying received notifications
version2(Database db) async {
  await db.transaction((tx) async {
    await tx.execute('''
      CREATE TABLE IF NOT EXISTS Notifications (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date DATETIME);
    ''');

    await tx.execute('''
      INSERT INTO Version (id, date)
      SELECT 2, DATETIME('now')
      WHERE NOT EXISTS (
        SELECT 1
        FROM Version
        WHERE id = 2
      )
    ''');
  });
}
