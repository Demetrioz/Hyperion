import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hyperion/services/data_service/data_service.dart';
import 'package:hyperion/services/data_service/models/notification.dart' as hn;
import 'package:hyperion/services/mqtt_service/service_events.dart';
import 'package:hyperion/services/notification_service/notification_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// onStart logic for initializing the MQTT Client
@pragma('vm:entry-point')
void onMqttServiceStart(ServiceInstance service) async {
  if (kDebugMode) debugPrint('Starting MQTT Service...');

  final mqttService = MqttService();
  mqttService._backgroundService = service;

  if (kDebugMode) debugPrint('Creating dedicated database connection...');
  await mqttService._dataService.initialize();

  if (kDebugMode) debugPrint('Performing first initialization...');
  mqttService._loadSettingsAndConnect();

  // Register handlers for the background service
  service.on(kServiceEvents[ServiceEvent.initialize]!).listen((data) async {
    if (kDebugMode) debugPrint('Re-initializing the MQTT client');

    mqttService._loadSettingsAndConnect();
  });

  // service.on(kServiceEvents[ServiceEvent.subscribe]!).listen((data) {
  //   // Make sure we have the correct payload before proceeding
  //   if (data == null) {
  //     if (kDebugMode) {
  //       debugPrint('data is null');
  //     }

  //     return;
  //   }

  //   final topic = data['topic'];

  //   mqttService._subscribeToTopic(topic);
  // });
}

// iOS-specific function for starting the background service
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

// Encapsulated MQTT Service that runs in the background and interacts
// with an MQTT broker to send and receive messages
class MqttService {
  static final MqttService _instance = MqttService._internal();
  MqttServerClient? _client;
  final _dataService = DataService();
  ServiceInstance? _backgroundService;

  factory MqttService() => _instance;
  MqttService._internal();

  // Handle incoming messages from the MQTT Broker
  void _handleIncomingMessage(
      List<MqttReceivedMessage<MqttMessage?>>? messageList) {
    final receivedMessage = messageList![0];

    final publishedMessage = receivedMessage.payload as MqttPublishMessage;
    final topic = receivedMessage.topic;
    final payload = MqttPublishPayload.bytesToStringAsString(
        publishedMessage.payload.message);

    _handleMessage(topic, payload);
  }

  // Routes messages from a subscribed MQTT topic to the correct handler
  void _handleMessage(String topic, String payload) async {
    if (kDebugMode) debugPrint('Received $payload from $topic');

    final notification = hn.Notification(text: payload, date: DateTime.now());
    await NotificationService.showNotification(0, 'MQTT Service', payload);
    await _dataService.insertNotification(notification);
    _backgroundService?.invoke(
        kServiceEvents[ServiceEvent.notificationReceived]!, {
      'text': notification.text,
      'date': notification.date!.toIso8601String()
    });
  }

  // Initializes the MQTT Background Service on iOS and Android
  static Future<void> initialize() async {
    if (kDebugMode) debugPrint('Initializing MQTT Service...');

    final service = FlutterBackgroundService();
    final serviceIsRunning = await service.isRunning();

    if (serviceIsRunning) {
      if (kDebugMode) debugPrint('Service is already initialized');
    } else {
      await service.configure(
          iosConfiguration: IosConfiguration(
            autoStart: true,
            onForeground: onMqttServiceStart,
            onBackground: onIosBackground,
          ),
          androidConfiguration: AndroidConfiguration(
            autoStart: true,
            isForegroundMode: false,
            autoStartOnBoot: true,
            onStart: onMqttServiceStart,
          ));
    }
  }

  // Load connection settings from the database and attempt to connect to the
  // MQTT broker
  Future<void> _loadSettingsAndConnect() async {
    if (kDebugMode) debugPrint('Loading...');
    final settings = await _dataService.getSettings();

    if (settings.host.isNotEmpty &&
        settings.port > 0 &&
        settings.client.isNotEmpty &&
        settings.user.isNotEmpty &&
        settings.password.isNotEmpty) {
      if (kDebugMode) debugPrint('we have values...');
      // Disconnect before trying to connect with new settings
      if (_clientIsConnected()) _client!.disconnect();

      if (kDebugMode) debugPrint('initializing again...');
      // Re-initialize the client and attempt to connect
      _initializeClient(settings.host, settings.client, settings.port);
      await _connectToBroker(settings.user, settings.password);

      // if we conencted succesfully and have a notification channel, subscribe
      // to the notifications
      if (_clientIsConnected() && settings.notificationChannel.isNotEmpty) {
        if (kDebugMode) debugPrint('Subscribing to channel...');
        _subscribeToTopic(settings.notificationChannel);
      }
    }
  }

  // Initialize the MQTT client
  void _initializeClient(String host, String clientId, int port) {
    _client = MqttServerClient.withPort(host, clientId, port);
  }

  // Connect to the MQTT Broker
  Future<void> _connectToBroker(String username, String password) async {
    if (kDebugMode) debugPrint('Attempting to connect to broker...');

    try {
      if (_client == null) {
        throw Exception('MQTT Client has not been initialized');
      }

      final connectMessage = MqttConnectMessage()
          .authenticateAs(username, password)
          .withWillTopic('willTopic')
          .withWillMessage('willMessage')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.keepAlivePeriod = 60;
      _client!.secure = true;
      _client!.autoReconnect = true;
      _client!.connectionMessage = connectMessage;

      await _client!.connect();

      _client!.updates!.listen(_handleIncomingMessage);

      if (kDebugMode) debugPrint('Connected to broker!');
    } catch (e) {
      if (kDebugMode) debugPrint('Error connecing to broker: $e');

      _client?.disconnect();
    }
  }

  void _subscribeToTopic(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (kDebugMode) debugPrint('Subscribing... $topic');

    if (_clientIsConnected()) {
      if (kDebugMode) debugPrint('we have a client! $topic');
      _client!.subscribe(topic, qos);
    }
  }

  bool _clientIsConnected() =>
      _client?.connectionStatus?.state == MqttConnectionState.connected ||
      _client?.connectionStatus?.state == MqttConnectionState.connecting;
}
