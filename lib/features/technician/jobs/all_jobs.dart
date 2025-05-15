import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/jobs_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:snapnbook/shared/widgets/job_card.dart';

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

              return buildJobCard(
                title: '${job['appliance']} Repair',
                status: job['status'],
                scheduledTime: formatPreferredTime(job['preferredTime']),
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
}
