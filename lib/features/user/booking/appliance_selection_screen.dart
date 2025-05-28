import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/booking_provider.dart';
import 'package:go_router/go_router.dart';

class ApplianceSelectionScreen extends ConsumerWidget {
  final String? appliance;
  final String? issue;

  const ApplianceSelectionScreen({
    super.key,
    this.appliance,
    this.issue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appliance != null) {
      ref.read(bookingProvider).setApplianceType(appliance!);
    }
    if (issue != null) {
      ref.read(bookingProvider).setIssueDescription(issue!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detected Appliance')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              appliance?.toUpperCase() ?? 'Unknown Appliance',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                issue ?? 'No issue description provided',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/booking');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
