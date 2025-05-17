import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/info_tile.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.tryParse(job['preferredTime'] ?? '')?.toLocal();
    final formattedTime =
        time != null
            ? DateFormat('MMM dd, yyyy - hh:mm a').format(time)
            : 'Invalid Time';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoTile(Icons.tv, 'Appliance', job['appliance']),
                // _infoRow('Issue', job['issue']),
                infoTile(Icons.home, 'Address', job['address']),
                infoTile(Icons.calendar_today, 'Scheduled Time', formattedTime),
                infoTile(Icons.info_outline, 'Status', job['status']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _infoRow(String label, String? value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
  //         Expanded(child: Text(value ?? 'N/A')),
  //       ],
  //     ),
  //   );
  // }
}
