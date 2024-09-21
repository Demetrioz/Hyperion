import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hyperion/background_service/service_events.dart';
import 'package:hyperion/notification_service/notification_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// onStart logic for initializing the MQTT Client
@pragma('vm:entry-point')
void onMqttServiceStart(ServiceInstance service) async {
  if (kDebugMode) debugPrint('Starting MQTT Service...');

  // TODO: Don't re-create if already running? Restarting seems to cause cause
  // a disconnect
  final mqttService = MqttService();

  // TODO: If we have connection details saved locally, initialize
  // the MQTT client using those
  // MqttService.instance.initializeClient(connectionDetails)
  // await MqttService.instance._connectToBroker();

  // Register handlers for the background service
  service.on(kServiceEvents[ServiceEvent.initialize]!).listen((data) async {
    if (kDebugMode) debugPrint('data: $data');

    // Make sure we have the correct payload before proceeding
    if (data == null) {
      if (kDebugMode) {
        debugPrint('data is null');
      }

      return;
    }

    final host = data['host'];
    final clientId = data['clientId'];
    final port = data['port'];
    final username = data['username'];
    final password = data['password'];

    if (mqttService._clientIsConnected()) {
      if (kDebugMode) debugPrint('Client is already connected');

      return;
    }

    mqttService._initializeClient(host, clientId, port);
    mqttService._connectToBroker(username, password);
  });

  service.on(kServiceEvents[ServiceEvent.subscribe]!).listen((data) {
    // Make sure we have the correct payload before proceeding
    if (data == null) {
      if (kDebugMode) {
        debugPrint('data is null');
      }

      return;
    }

    final topic = data['topic'];

    mqttService._subscribeToTopic(topic);
  });
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

    await NotificationService.showNotification(0, 'MQTT Service', payload);
  }

  // Initializes the MQTT Background Service on iOS and Android
  static Future<void> initialize() async {
    if (kDebugMode) debugPrint('Initializing MQTT Service...');

    final service = FlutterBackgroundService();

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
