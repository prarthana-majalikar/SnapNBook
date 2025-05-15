import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildJobCard({
  required String title,
  required String status,
  required String scheduledTime,
  required String address,
  required VoidCallback onTap,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: const Icon(Icons.build_circle, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text('Scheduled: $scheduledTime\n$address'),
      isThreeLine: true,
      trailing: Chip(
        label: Text(status),
        backgroundColor:
            status == 'In Progress' ? Colors.orange[100] : Colors.green[100],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    ),
  );
}

String formatPreferredTime(String isoTime) {
  final dateTime = DateTime.tryParse(isoTime)?.toLocal();
  if (dateTime == null) return 'Invalid time';
  return DateFormat('MMM dd, h:mm a').format(dateTime);
}
