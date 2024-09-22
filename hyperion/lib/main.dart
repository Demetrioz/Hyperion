import 'package:flutter/material.dart';
import 'package:hyperion/hyperion.dart';
import 'package:hyperion/services/data_service/data_service.dart';
import 'package:hyperion/services/mqtt_service/mqtt_service.dart';
import 'package:hyperion/services/notification_service/notification_service.dart';

// Allow dataservice to be accessed from other areas of the app
final dataService = DataService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dataService.initialize();
  await NotificationService.initialize();
  await MqttService.initialize();

  runApp(const Hyperion());
}
