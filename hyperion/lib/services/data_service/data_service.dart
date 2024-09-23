import 'package:hyperion/services/data_service/migrations/run_migrations.dart';
import 'package:hyperion/services/data_service/models/notification.dart';
import 'package:hyperion/services/mqtt_service/broker_settings.dart';
import 'package:sqflite/sqflite.dart';

class DataService {
  final dbVersion = 2;
  Database? _db;

  // Allow multiple connection so there can be an instance available to the main
  // app as well as the background service
  Future<void> initialize() async {
    _db = await openDatabase(
      'hyperion-db.db',
      version: dbVersion,
      singleInstance: false,
      onCreate: (db, version) async {
        await runMigrations(db, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await runMigrations(db, newVersion);
      },
    );
  }

  Future<BrokerSettings> getSettings() async {
    if (_db == null) throw Exception('Database has not been initialized!');

    final dbSettings = await _db!.rawQuery('''
      SELECT * FROM Settings
    ''');

    final host = dbSettings.firstWhere((item) => item['key'] == 'mqtt.host');
    final port = dbSettings.firstWhere((item) => item['key'] == 'mqtt.port');
    final client =
        dbSettings.firstWhere((item) => item['key'] == 'mqtt.client');
    final username =
        dbSettings.firstWhere((item) => item['key'] == 'mqtt.username');
    final password =
        dbSettings.firstWhere((item) => item['key'] == 'mqtt.password');
    final channel = dbSettings
        .firstWhere((item) => item['key'] == 'mqtt.channels.notifications');

    final portNumber = int.tryParse(port['value'] as String) ?? 0;

    return BrokerSettings(
        host: host['value'] as String,
        port: portNumber,
        client: client['value'] as String,
        user: username['value'] as String,
        password: password['value'] as String,
        notificationChannel: channel['value'] as String);
  }

  Future<BrokerSettings> updateSettings(BrokerSettings settings) async {
    if (_db == null) throw Exception('Database has not been initialized!');

    await _db!.transaction((tx) async {
      await tx.update('Settings', {'value': settings.host},
          where: 'key = ?', whereArgs: ['mqtt.host']);

      await tx.update('Settings', {'value': settings.host},
          where: 'key = ?', whereArgs: ['mqtt.host']);

      await tx.update('Settings', {'value': settings.port.toString()},
          where: 'key = ?', whereArgs: ['mqtt.port']);

      await tx.update('Settings', {'value': settings.client},
          where: 'key = ?', whereArgs: ['mqtt.client']);

      await tx.update('Settings', {'value': settings.user},
          where: 'key = ?', whereArgs: ['mqtt.username']);

      await tx.update('Settings', {'value': settings.password},
          where: 'key = ?', whereArgs: ['mqtt.password']);

      await tx.update('Settings', {'value': settings.notificationChannel},
          where: 'key = ?', whereArgs: ['mqtt.channels.notifications']);
    });

    return settings;
  }

  Future<Notification> insertNotification(Notification notification) async {
    if (_db == null) throw Exception('Database has not been initialized!');

    final dateString = notification.date?.toIso8601String() ??
        DateTime.now().toIso8601String();

    await _db!.insert(
        'Notifications', {'text': notification.text, 'date': dateString});

    return notification;
  }

  Future<List<Notification>> getRecentNotifications() async {
    if (_db == null) throw Exception('Database has not been initialized');

    final recentNotifications = await _db!.rawQuery('''
      SELECT
        text,
        date
      FROM Notifications
      ORDER BY date DESC
      LIMIT 50
    ''');

    final results = recentNotifications.map((notification) {
      return Notification(
          text: notification['text'] as String,
          date: DateTime.parse('${notification['date']}'));
    }).toList();

    return results;
  }
}
