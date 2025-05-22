import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapnbook/state/auth_provider.dart';
import '../jobs/all_jobs.dart';

class TechnicianHomeScreen extends ConsumerWidget {
  const TechnicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final technicianId = session?.userId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Dashboard'),
      ),
      body: TechnicianAllJobsScreen(technicianId: technicianId),
    );
  }
}
