import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.parse(job['preferredTime']).toLocal();
    final formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appliance: ${job['appliance']}'),
            Text('Issue: ${job['issue']}'),
            Text('Address: ${job['address']}'),
            Text('Scheduled Time: $formattedTime'),
            Text('Status: ${job['status']}'),
          ],
        ),
      ),
    );
  }
}
