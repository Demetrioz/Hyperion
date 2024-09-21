import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
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
  MqttServerClient client =
      MqttServerClient.withPort("host", "hyperion-app", 8883);

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _subscribeToTopic() {
    client.subscribe('test', MqttQos.atLeastOnce);
    print('Subscribed!');
    // client.updates!.listen(_receiveMessage);
  }

  void _subscribeToTopic2() {
    client.subscribe('test2', MqttQos.atLeastOnce);
    print('Subscribed!');
    // client.updates!.listen(_receiveMessage2);
  }

  void _publish() {
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello World');
    client.publishMessage('test', MqttQos.atLeastOnce, builder.payload!);
  }

  void _unsubscribeFromTopic() {
    client.unsubscribe('test');
    print('Unsubscribed!');
  }

  void _unsubscribeFromTopic2() {
    client.unsubscribe('test2');
    print('Unsubscribed!');
  }

  void _disconnect() {
    client.disconnect();
    print('Disconnected');
  }

  void _connectToBroker() async {
    try {
      print('Connecting...');
      await client.connect();
      client.updates!.listen(_receiveMessage);
      print('Connected.');
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  void _receiveMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final receivedMessage = c![0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
        receivedMessage.payload.message);
    print('Received messsage:$payload from topic: ${c[0].topic}');
  }

  void _receiveMessage2(messageList) {
    final receivedMessage = messageList[0];
    if (receivedMessage is! MqttReceivedMessage<MqttPublishMessage>) return;
    final publishedMessage = receivedMessage.payload;
    final payload = MqttPublishPayload.bytesToStringAsString(
        publishedMessage.payload.message);

    print('Received messsage2:$payload from topic: ${receivedMessage.topic}');
  }

  @override
  void initState() {
    super.initState();

    client.keepAlivePeriod = 60;
    final connectMessage = MqttConnectMessage()
        .authenticateAs('user', 'password')
        .withWillTopic('willTopic')
        .withWillMessage('willMessage')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connectMessage;
    client.secure = true;
    client.autoReconnect = true;
    // client.updates!.listen(_receiveMessage);

    _connectToBroker();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
                onPressed: _connectToBroker, child: const Text('Connect')),
            ElevatedButton(
                onPressed: _subscribeToTopic, child: const Text('Subscribe')),
            ElevatedButton(
                onPressed: _unsubscribeFromTopic,
                child: const Text('Unsubscribe')),
            ElevatedButton(
                onPressed: _subscribeToTopic2, child: const Text('Subscribe')),
            ElevatedButton(
                onPressed: _unsubscribeFromTopic2,
                child: const Text('Unsubscribe')),
            ElevatedButton(onPressed: _publish, child: const Text('Publish')),
            ElevatedButton(
                onPressed: _disconnect, child: const Text('Disconnect'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
