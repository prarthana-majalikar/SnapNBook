import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In the future, fetch technician's name from provider or token
    final technicianName = 'Technician';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $technicianName 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Section for active jobs
            const Text(
              'Your Active Jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildJobCard(
              title: 'Repair - Washing Machine',
              status: 'Assigned',
              scheduledTime: 'May 12, 10:00 AM',
            ),
            _buildJobCard(
              title: 'Service - Microwave',
              status: 'In Progress',
              scheduledTime: 'May 13, 3:00 PM',
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to all jobs list
              },
              icon: const Icon(Icons.assignment),
              label: const Text('View All Jobs'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String status,
    required String scheduledTime,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.build_circle, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text('Scheduled: $scheduledTime'),
        trailing: Chip(
          label: Text(status),
          backgroundColor:
              status == 'In Progress' ? Colors.orange[100] : Colors.green[100],
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () {
          // TODO: Navigate to job details
        },
      ),
    );
  }
}
