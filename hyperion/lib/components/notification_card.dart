import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.text, required this.date});

  final String text;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.notifications,
          color: Colors.red,
        ),
        title: Text(
            '${DateFormat.Hm().format(date)} ${DateFormat.MMMMd().format(date)}'),
        subtitle: Text(text),
      ),
    );
  }
}
