import 'package:hyperion/services/data_service/migrations.dart';
import 'package:hyperion/services/mqtt_service/broker_settings.dart';
import 'package:sqflite/sqflite.dart';

class DataService {
  Database? _db;

  // Allow multiple connection so there can be an instance available to the main
  // app as well as the background service
  Future<void> initialize() async {
    _db = await openDatabase('hyperion-db.db',
        version: 1, singleInstance: false, onCreate: (db, version) async {
      if (version == 1) await migration1(db);
    });
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
      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.host}'
        WHERE key = 'mqtt.host'
      ''');

      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.port}'
        WHERE key = 'mqtt.port'
      ''');

      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.client}'
        WHERE key = 'mqtt.client'
      ''');

      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.user}'
        WHERE key = 'mqtt.username'
      ''');

      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.password}'
        WHERE key = 'mqtt.password'
      ''');

      await tx.execute('''
        UPDATE SETTINGS
        SET value = '${settings.notificationChannel}'
        WHERE key = 'mqtt.channels.notifications'
      ''');
    });

    return settings;
  }
}
