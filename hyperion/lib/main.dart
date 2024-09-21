import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hyperion/background_service/mqtt_service.dart';
import 'package:hyperion/background_service/service_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MqttService().initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _hostController;
  late TextEditingController _channelController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _clientIdController;

  // void _publish() {
  //   final builder = MqttClientPayloadBuilder();
  //   builder.addString('Hello World');
  //   client.publishMessage('test', MqttQos.atLeastOnce, builder.payload!);
  // }

  // void _unsubscribeFromTopic() {
  //   client.unsubscribe('test');
  //   print('Unsubscribed!');
  // }

  // void _disconnect() {
  //   client.disconnect();
  //   print('Disconnected');
  // }

  void _handleSubscribeToTopic() {
    if (kDebugMode) debugPrint('Attempting to subscribe');

    final topic = _channelController.text;

    FlutterBackgroundService()
        .invoke(kServiceEvents[ServiceEvent.subscribe]!, {'topic': topic});
  }

  void _handleConnectToHost() {
    if (kDebugMode) debugPrint('Attempting to connect...');

    final host = _hostController.text;
    final clientId = _clientIdController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    FlutterBackgroundService()
        .invoke(kServiceEvents[ServiceEvent.initialize]!, {
      'host': host,
      'clientId': clientId,
      'port': 8883,
      'username': username,
      'password': password
    });
  }

  @override
  void initState() {
    super.initState();

    _hostController = TextEditingController();
    _channelController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _clientIdController = TextEditingController();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _channelController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _clientIdController,
                decoration: const InputDecoration(labelText: 'Client Id'),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(labelText: 'Host'),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _handleConnectToHost,
                      child: const Text('Connect'))
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _channelController,
                      decoration: const InputDecoration(labelText: 'Topic'),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _handleSubscribeToTopic,
                      child: const Text('Subscribe'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
