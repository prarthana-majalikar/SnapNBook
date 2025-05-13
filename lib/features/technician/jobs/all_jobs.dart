import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../providers/jobs_provider.dart';
import 'package:go_router/go_router.dart';

class TechnicianAllJobsScreen extends ConsumerWidget {
  const TechnicianAllJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Jobs')),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No jobs available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return _buildJobCard(
                title: '${job['appliance']} - ${job['issue']}',
                status: job['status'],
                scheduledTime: _formatTime(job['preferredTime']),
                address: job['address'],
                onTap: () {
                  context.push('/job-details', extra: job);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard({
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

  String _formatTime(String isoTime) {
    final dateTime = DateTime.parse(isoTime).toLocal();
    return DateFormat('MMM dd, h:mm a').format(dateTime);
  }
}
