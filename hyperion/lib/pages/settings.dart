import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hyperion/components/error_dialog.dart';
import 'package:hyperion/main.dart';
import 'package:hyperion/services/mqtt_service/broker_settings.dart';
import 'package:hyperion/services/mqtt_service/service_events.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late BrokerSettings _settings;

  bool _obscurePassword = true;
  IconData _passwordIcon = Icons.visibility;

  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _notificationChannelController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _clientIdController;

  void _loadSettings() async {
    _settings = await dataService.getSettings();

    setState(() {
      _hostController.text = _settings.host;
      _portController.text = _settings.port.toString();
      _clientIdController.text = _settings.client;
      _usernameController.text = _settings.user;
      _passwordController.text = _settings.password;
      _notificationChannelController.text = _settings.notificationChannel;
    });
  }

  void _handleSave() async {
    // Make sure we have values
    if (_hostController.text.isEmpty ||
        _portController.text.isEmpty ||
        _clientIdController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _notificationChannelController.text.isEmpty) {
      showErrorDialog(
          context, 'Error Saving', 'All settings must have a value');

      return;
    }

    // Save the new information
    final portNumber = int.tryParse(_portController.text) ?? 0;
    setState(() {
      _settings = BrokerSettings(
          host: _hostController.text,
          port: portNumber,
          client: _clientIdController.text,
          user: _usernameController.text,
          password: _passwordController.text,
          notificationChannel: _notificationChannelController.text);
    });

    await dataService.updateSettings(_settings);

    if (kDebugMode) debugPrint('Trying to initialize?');
    // Re-initialize the broker with the new connection settings
    FlutterBackgroundService().invoke(kServiceEvents[ServiceEvent.initialize]!);
  }

  void _togglePasswordObscurity() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      _passwordIcon =
          _obscurePassword ? Icons.visibility : Icons.visibility_off;
    });
  }

  // void _handleNotification() {
  //   NotificationService.showNotification(
  //       0, 'Testing', 'This is a notification');
  // }

  // void _handleSubscribeToTopic() {
  //   if (kDebugMode) debugPrint('Attempting to subscribe');

  //   final topic = _notificationChannelController.text;

  //   FlutterBackgroundService()
  //       .invoke(kServiceEvents[ServiceEvent.subscribe]!, {'topic': topic});
  // }

  @override
  void initState() {
    super.initState();

    _hostController = TextEditingController();
    _portController = TextEditingController();
    _notificationChannelController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _clientIdController = TextEditingController();

    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _notificationChannelController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _clientIdController,
          decoration: const InputDecoration(labelText: 'Client Id'),
        ),
        TextField(
          controller: _hostController,
          decoration: const InputDecoration(labelText: 'Host'),
        ),
        TextField(
          controller: _portController,
          decoration: const InputDecoration(labelText: 'Port'),
        ),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                  onPressed: _togglePasswordObscurity,
                  icon: Icon(_passwordIcon))),
        ),
        TextField(
          controller: _notificationChannelController,
          decoration: const InputDecoration(labelText: 'Notification Channel'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              ElevatedButton(onPressed: _handleSave, child: const Text('Save')),
        )
      ],
    );
  }
}
