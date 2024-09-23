import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hyperion/components/notification_card.dart';
import 'package:hyperion/main.dart';
import 'package:hyperion/services/data_service/models/notification.dart' as hn;
import 'package:hyperion/services/mqtt_service/service_events.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _isLoading = false;
  List<hn.Notification> _notifications = [];

  void _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final asyncNotifications = await dataService.getRecentNotifications();

    setState(() {
      _notifications = asyncNotifications;
      _isLoading = false;
    });
  }

  void displayNewNotification(Map<String, dynamic>? data) {
    if (kDebugMode) debugPrint('Received data? $data');

    final newNotification = hn.Notification(
        text: data?['text'] as String,
        date: DateTime.parse(data?['date'] as String));

    if (mounted) {
      setState(() {
        _notifications.insert(0, newNotification);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadNotifications();

    // Listen for new notifications while we're on this page so they can be
    // added to the list of items in real time
    FlutterBackgroundService()
        .on(kServiceEvents[ServiceEvent.notificationReceived]!)
        .listen(displayNewNotification);
  }

  @override
  Widget build(BuildContext context) {
    final listContent = _notifications.isEmpty
        ? const Center(
            child: Text('No notifications'),
          )
        : Column(
            children: _notifications.map((notification) {
              return NotificationCard(
                  text: notification.text ?? '',
                  date: notification.date ?? DateTime.now());
            }).toList(),
          );

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : listContent;
  }
}
