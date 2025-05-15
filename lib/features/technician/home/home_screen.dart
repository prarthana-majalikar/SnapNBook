import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For formatting datetime
import 'package:go_router/go_router.dart';
import "../../../providers/jobs_provider.dart";

class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicianName = 'Technician';
    final jobAsync = ref.watch(jobsProvider);

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
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (jobs) {
          final today = DateTime.now();
          final activeTodayJobs =
              jobs.where((job) {
                final preferredTime = DateTime.tryParse(
                  job['preferredTime'] ?? '',
                );
                if (preferredTime == null) return false;
                return preferredTime.day == today.day &&
                    preferredTime.month == today.month &&
                    preferredTime.year == today.year &&
                    (job['status'] == 'Assigned' ||
                        job['status'] == 'In Progress');
              }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $technicianName 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Your Active Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                if (activeTodayJobs.isEmpty)
                  const Text('No active jobs for today.'),
                for (var job in activeTodayJobs)
                  _buildJobCard(
                    context: context,
                    title: '${job['type']} - ${job['appliance']}',
                    status: job['status'],
                    scheduledTime: DateFormat(
                      'MMM dd, hh:mm a',
                    ).format(DateTime.parse(job['preferredTime']).toLocal()),
                    onTap: () {
                      context.push('/tech/job/${job['bookingId']}', extra: job);
                    },
                  ),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/tech/jobs');
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('View All Jobs'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required String title,
    required String status,
    required String scheduledTime,
    required VoidCallback onTap,
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
        onTap: onTap,
      ),
    );
  }
}
