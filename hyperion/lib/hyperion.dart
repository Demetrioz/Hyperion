import 'package:flutter/material.dart';
import 'package:hyperion/pages/root.dart';
import 'package:hyperion/services/notification_service/notification_service.dart';

class Hyperion extends StatefulWidget {
  const Hyperion({super.key});

  @override
  State<Hyperion> createState() => _HyperionState();
}

class _HyperionState extends State<Hyperion> {
  @override
  void initState() {
    super.initState();

    NotificationService.requestNotificationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyperion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Root(),
    );
  }
}
